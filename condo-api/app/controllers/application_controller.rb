class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions

  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: exception.message }, status: :unauthorized
  end

  protected

  def current_user
    @current_user ||= find_current_user_from_jwt
  end

  private

  def find_current_user_from_jwt
    token = request.headers["Authorization"]&.split(" ")&.last

    return nil unless token

    begin
      payload = JWT.decode(
        token,
        Rails.application.credentials.devise_jwt_secret_key!
      ).first

      User.find_by(jti: payload["jti"])
    rescue JWT::DecodeError
      nil
    end
  end
end
