class TransactionRiskEvaluator
  def initialize(transaction)
    @transaction = transaction
    @user = transaction.user
  end

  def evaluate
    # Ensure atomicity: if any step fails (e.g. AuditLog creation), 
    # all changes (Transaction status, FraudEvaluation) are rolled back.
    ActiveRecord::Base.transaction do
      stats = @user.user_transaction_stat || @user.create_user_transaction_stat

      # 1. Processing Risk Rules
      rule_results = RiskRulesProcessor.new(@transaction, @user, stats).process

      # 2. Post-Evaluation Actions (DB updates, Notifications, Logging)
      TransactionPostProcessor.new(@transaction, @user, stats, rule_results).process

      # Return the final status
      rule_results[:status]
    end
  rescue ActiveRecord::RecordInvalid => e
    # Optionally log the error or handle it as needed
    # Rails transactions automatically roll back on exceptions.
    Rails.logger.error("Transaction evaluation failed: #{e.message}")
    raise e
  end
end
