class ApplicationController < ActionController::API
  include Pundit::Authorization
  
  # Include cookies for session management
  include ActionController::Cookies

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    return if current_user

    render_error("Authentication required", :unauthorized)
  end

  protected

  def render_success(data, message = "Success", status = :ok)
    render json: {
      status: "success",
      message: message,
      data: data,
      error: nil
    }, status: status
  end

  def render_error(message, status = :bad_request, error = nil)
    render json: {
      status: "error",
      message: message,
      data: nil,
      error: error || status
    }, status: status
  end

  private

  def user_not_authorized
    render_error("Not authorized", :forbidden, "pundit_unauthorized")
  end
end

