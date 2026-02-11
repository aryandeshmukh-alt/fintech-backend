class RiskRulesProcessor
  # Risk Score Constants
  BLOCKED_SCORE_THRESHOLD = 70
  FLAGGED_SCORE_THRESHOLD = 30

  # Rule Score Constants
  FIRST_TXN_HIGH_RISK = 30
  AMOUNT_DEVIATION_HIGH = 40
  AMOUNT_DEVIATION_MEDIUM = 30
  AMOUNT_DEVIATION_LOW = 20
  RAPID_VELOCITY_LOW = 20
  RAPID_VELOCITY_MEDIUM = 30
  RAPID_VELOCITY_HIGH = 40
  UNTRUSTED_DEVICE_RISK = 30
  MISSING_DEVICE_RISK = 50

  # Business Logic Constants
  HIGH_AMOUNT_LIMIT = 100_000
  DEVIATION_MULTIPLIER_HIGH = 10
  DEVIATION_MULTIPLIER_MEDIUM = 5
  DEVIATION_MULTIPLIER_LOW = 2
  VELOCITY_WINDOW = 1.minute
  
  MEDIUM_AMOUNT_RANGE = 1_000...10_000
  LARGE_AMOUNT_RANGE = 10_000...50_000
  VERY_LARGE_AMOUNT_MIN = 50_000

  def initialize(transaction, user, stats)
    @transaction = transaction
    @user = user
    @stats = stats
    @risk_score = 0
    @triggered_rules = []
  end

  def process
    evaluate_first_transaction
    evaluate_amount_deviation
    evaluate_velocity
    evaluate_device_security

    {
      risk_score: @risk_score,
      triggered_rules: @triggered_rules,
      status: determine_status
    }
  end

  private

  def add_risk(score, rule)
    @risk_score += score
    @triggered_rules << rule
  end

  def evaluate_first_transaction
    if @stats.total_txns == 0 && @transaction.amount > HIGH_AMOUNT_LIMIT
      add_risk(FIRST_TXN_HIGH_RISK, "FIRST_TRANSACTION_HIGH_AMOUNT")
    end
  end

  def evaluate_amount_deviation
    return if @stats.avg_amount <= 0

    if @transaction.amount >= @stats.avg_amount * DEVIATION_MULTIPLIER_HIGH
      add_risk(AMOUNT_DEVIATION_HIGH, "AMOUNT_DEVIATION_HIGH")
    elsif @transaction.amount >= @stats.avg_amount * DEVIATION_MULTIPLIER_MEDIUM
      add_risk(AMOUNT_DEVIATION_MEDIUM, "AMOUNT_DEVIATION_MEDIUM")
    elsif @transaction.amount >= @stats.avg_amount * DEVIATION_MULTIPLIER_LOW
      add_risk(AMOUNT_DEVIATION_LOW, "AMOUNT_DEVIATION_LOW")
    end
  end

  def evaluate_velocity
    recent_txns = @user.transactions.where("created_at > ?", VELOCITY_WINDOW.ago)
    recent_txn_count = recent_txns.count

    if MEDIUM_AMOUNT_RANGE.cover?(@transaction.amount) && recent_txn_count >= 4
      add_risk(RAPID_VELOCITY_LOW, "RAPID_MEDIUM_AMOUNT")
    elsif LARGE_AMOUNT_RANGE.cover?(@transaction.amount) && recent_txn_count >= 3
      add_risk(RAPID_VELOCITY_MEDIUM, "RAPID_LARGE_AMOUNT")
    elsif @transaction.amount >= VERY_LARGE_AMOUNT_MIN && recent_txn_count >= 2
      add_risk(RAPID_VELOCITY_HIGH, "RAPID_VERY_LARGE_AMOUNT")
    end
  end

  def evaluate_device_security
    # Rule 4: Device mismatch check
    trusted_device = @user.devices.first
    if trusted_device.present? && trusted_device.device_id != @transaction.device_id
      add_risk(UNTRUSTED_DEVICE_RISK, "UNTRUSTED_DEVICE")
    end

    # Rule 5: Missing device guard
    if @transaction.device_id.blank?
      add_risk(MISSING_DEVICE_RISK, "MISSING_DEVICE_ID")
    end
  end

  def determine_status
    if @risk_score >= BLOCKED_SCORE_THRESHOLD
      :blocked
    elsif @risk_score >= FLAGGED_SCORE_THRESHOLD
      :flagged
    else
      :success
    end
  end
end
