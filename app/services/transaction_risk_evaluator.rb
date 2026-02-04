class TransactionRiskEvaluator
  def initialize(transaction)
    @transaction = transaction
    @user = transaction.user
    @risk_score = 0
    @triggered_rules = []
  end

  def evaluate
    # 1. Load user spending baseline
    stats = @user.user_transaction_stat || @user.create_user_transaction_stat

    # RULE 1: First transaction safety check
    if stats.total_txns == 0 && @transaction.amount > 100_000
      add_risk(30, "FIRST_TRANSACTION_HIGH_AMOUNT")
    end

    # RULE 2: Amount deviation
    if stats.avg_amount > 0
      if @transaction.amount >= stats.avg_amount * 10
        add_risk(40, "AMOUNT_DEVIATION_HIGH")
      elsif @transaction.amount >= stats.avg_amount * 5
        add_risk(30, "AMOUNT_DEVIATION_MEDIUM")
      elsif @transaction.amount >= stats.avg_amount * 2
        add_risk(20, "AMOUNT_DEVIATION_LOW")
      end
    end

    # RULE 3: Velocity (amount-aware) - last 1 minute
    recent_txns = @user.transactions.where("created_at > ?", 1.minute.ago)
    recent_txn_count = recent_txns.count

    if @transaction.amount >= 1_000 && @transaction.amount < 10_000 && recent_txn_count >= 4
      add_risk(20, "RAPID_MEDIUM_AMOUNT")
    end

    if @transaction.amount >= 10_000 && @transaction.amount < 50_000 && recent_txn_count >= 3
      add_risk(30, "RAPID_LARGE_AMOUNT")
    end

    if @transaction.amount >= 50_000 && recent_txn_count >= 2
      add_risk(40, "RAPID_VERY_LARGE_AMOUNT")
    end

    # RULE 4: Device mismatch check
    trusted_device = @user.devices.first
    if trusted_device.present? && trusted_device.device_id != @transaction.device_id
      add_risk(30, "UNTRUSTED_DEVICE")
    end

    # RULE 5: Missing device guard
    if @transaction.device_id.blank?
      add_risk(50, "MISSING_DEVICE_ID")
    end

    # Determine status base on risk score
    status = if @risk_score > 70
               :blocked
             elsif @risk_score >= 30
               :flagged
             else
               :success
             end

    # Save evaluation
    FraudEvaluation.create!(
      financial_transaction: @transaction,
      risk_score: @risk_score,
      rules_triggered: @triggered_rules.join(',')
    )

    # Update transaction
    @transaction.update!(status: status, risk_score: @risk_score)

    # Audit logging
    AuditLog.create!(
      event_type: "TRANSACTION_#{status.upcase}",
      entity_type: 'Transaction',
      entity_id: @transaction.id,
      description: "Triggered rules: #{@triggered_rules.join(',')}"
    )

    # Learn behavior ONLY on success
    if status == :success
      update_user_stats(stats)
      store_device_if_none(trusted_device)
    end

    status
  end

  private

  def add_risk(score, rule)
    @risk_score += score
    @triggered_rules << rule
  end

  def update_user_stats(stats)
    new_total_txns = stats.total_txns + 1
    new_total_amount = stats.total_amount + @transaction.amount
    new_avg_amount = new_total_amount / new_total_txns

    stats.update!(
      total_txns: new_total_txns,
      total_amount: new_total_amount,
      avg_amount: new_avg_amount,
      last_updated_at: Time.current
    )
  end

  def store_device_if_none(trusted_device)
    return if trusted_device.present? || @transaction.device_id.blank?

    @user.devices.create!(
      device_id: @transaction.device_id,
      first_seen_at: Time.current
    )
  end
end
