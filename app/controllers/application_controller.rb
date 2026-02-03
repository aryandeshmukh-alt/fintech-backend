class ApplicationController < ActionController::API
  include Pundit::Authorization
  
  # Include cookies for session management
  include ActionController::Cookies

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    render json: {
      status: "error",
      message: "Not authorized",
      data: nil,
      error: "unauthorized"
    }, status: :forbidden
  end
end

