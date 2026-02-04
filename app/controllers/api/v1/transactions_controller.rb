require 'digest'

module Api
  module V1
    class TransactionsController < ApplicationController
      before_action :authenticate_user!

      # POST /api/v1/transactions
      def create
        transaction = current_user.transactions.new(transaction_params)
        transaction.ip_address = request.remote_ip
        
        # Secure Hashing for Device ID (SHA-256)
        # Using MAC ID or other identifier provided in device_id param
        device_identifier = params.dig(:transaction, :device_id) || request.user_agent + request.remote_ip
        transaction.device_id = Digest::SHA256.hexdigest(device_identifier)

        if transaction.save
          status = TransactionRiskEvaluator.new(transaction).evaluate
          
          message = case status
                   when :success then "Transaction processed successfully"
                   when :flagged then "Transaction flagged for review"
                   when :blocked then "Transaction blocked due to high risk"
                   end

          render_success(serialize_transaction(transaction), message, status == :blocked ? :forbidden : :created)
        else
          render_error("Transaction creation failed", :unprocessable_entity, transaction.errors.full_messages)
        end
      end

      # GET /api/v1/transactions
      def index
        page = params[:page] || 1
        per_page = params[:per_page] || 20

        transactions = current_user.transactions.order(created_at: :desc).page(page).per(per_page)
        
        # Calculate/Fetch stats for efficient frontend
        stats = current_user.user_transaction_stat

        render_success({
          transactions: transactions.map { |t| serialize_transaction(t) },
          pagination: {
            current_page: transactions.current_page,
            total_pages: transactions.total_pages,
            total_count: transactions.total_count
          },
          user_stats: stats ? serialize_stats(stats) : nil
        })
      end

      private

      def transaction_params
        params.require(:transaction).permit(:amount, :device_id, :payment_method)
      end

      def serialize_transaction(transaction)
        {
          id: transaction.id,
          amount: transaction.amount,
          payment_method: transaction.payment_method,
          device_id: transaction.device_id, # This is now the SHA-256 hash
          status: transaction.status,
          risk_score: transaction.risk_score,
          ip_address: transaction.ip_address,
          created_at: transaction.created_at,
          rules_triggered: transaction.fraud_evaluation&.rules_triggered
        }
      end

      def serialize_stats(stats)
        {
          total_transactions: stats.total_txns,
          total_volume: stats.total_amount,
          average_spending: stats.avg_amount,
          last_active: stats.last_updated_at
        }
      end
    end
  end
end
