module Api
  module V1
    class FraudFeedbacksController < ApplicationController
      before_action :authenticate_user!
      before_action :set_evaluation

      # POST /api/v1/transactions/:transaction_id/feedback
      def create
        # 1. Require params first to trigger 400 if missing
        feedback_data = feedback_params

        # 2. Check if already submitted
        if @evaluation.is_accurate != nil
          return render_error("Feedback has already been submitted for this transaction", :unprocessable_entity)
        end

        ActiveRecord::Base.transaction do
          @evaluation.update!(feedback_data)

          AuditLog.create!(
            event_type: "FRAUD_FEEDBACK_SUBMITTED",
            entity_type: "Transaction",
            entity_id: @evaluation.transaction_id.to_s,
            description: "User submitted feedback for transaction: #{@evaluation.is_accurate ? 'Accurate' : 'Inaccurate'}. Feedback: #{@evaluation.user_feedback}"
          )
        end

        render_success(
          serialize_evaluation(@evaluation),
          "Feedback submitted successfully"
        )
      rescue ActiveRecord::RecordInvalid => e
        render_error(
          "Failed to submit feedback",
          :unprocessable_entity,
          e.message
        )
      end

      private

      def set_evaluation
        # Ensure user can only feedback on their own transactions
        transaction = current_user.transactions.find(params[:transaction_id])
        @evaluation = transaction.fraud_evaluation

        render_error("No evaluation found for this transaction", :not_found) unless @evaluation
      rescue ActiveRecord::RecordNotFound
        render_error("Transaction not found", :not_found)
      end

      def feedback_params
        params.require(:feedback).permit(:is_accurate, :user_feedback)
      end

      def serialize_evaluation(evaluation)
        {
          id: evaluation.id,
          transaction_id: evaluation.transaction_id,
          risk_score: evaluation.risk_score,
          is_accurate: evaluation.is_accurate,
          user_feedback: evaluation.user_feedback,
          updated_at: evaluation.updated_at
        }
      end
    end
  end
end
