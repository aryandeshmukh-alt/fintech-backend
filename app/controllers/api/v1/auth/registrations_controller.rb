module Api
  module V1
    module Auth
      class RegistrationsController < ApplicationController
        # POST /api/v1/auth/register
        def create
          user = User.new(registration_params)

          if user.save
            # Set session immediately after registration
            session[:user_id] = user.id

            render_success(
              serialize_user(user),
              "User registered successfully",
              :created
            )
          else
            render_error(
              "Registration failed",
              :unprocessable_entity,
              user.errors.full_messages
            )
          end
        end

        private

        def registration_params
          params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
        end

        def serialize_user(user)
          {
            id: user.id,
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name,
            role: user.role,
            status: user.status,
            created_at: user.created_at
          }
        end
      end
    end
  end
end
