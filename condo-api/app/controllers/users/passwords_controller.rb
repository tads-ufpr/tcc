# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  respond_to :json

  wrap_parameters :user, include: [:email, :password, :password_confirmation, :reset_password_token]

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      render json: { status: 200, message: "Password reset instructions sent successfully." }, status: :ok
    else
      render json: { status: :unprocessable_content, message: resource.errors.full_messages.to_sentence }, status: :unprocessable_content
    end
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      render json: { status: 200, message: "Password updated successfully." }, status: :ok
    else
      render json: { status: :unprocessable_content, message: resource.errors.full_messages.to_sentence }, status: :unprocessable_content
    end
  end
end
