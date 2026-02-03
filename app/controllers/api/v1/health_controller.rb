module Api
  module V1
    class HealthController < ApplicationController
      # GET /api/v1/health
      def check
        render json: {
          status: "ok",
          timestamp: Time.current,
          environment: Rails.env,
          database: check_database_connection
        }, status: :ok
      end

      private

      def check_database_connection
        ActiveRecord::Base.connection.execute("SELECT 1")
        "connected"
      rescue StandardError => e
        "disconnected (#{e.message})"
      end
    end
  end
end
