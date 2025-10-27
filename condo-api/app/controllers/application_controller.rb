class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions

  rescue_from CanCan::AccessDenied do |e|
    status = current_user ? :forbidden : :unauthorized

    if status == :forbidden
      message = { authorization: e.message }
    else
      message = { authentication: "Resource requires authentication" }
    end

    render_error(message, status)
  end

  protected

  def current_user
    @current_user ||= find_current_user_from_jwt
  end

  def render_error(errors, status)
    render json: {
      message: string_error(errors),
      status:,
      code: Rack::Utils.status_code(status)
    }, status:
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render json: {
      message: "Required parameter is missing: #{exception.param}",
      status: Rack::Utils.status_code(:bad_request),
      code: :bad_request
    }, status: :bad_request
  end

  private

  # TODO - Remove this junk later
  def string_error(errors)
    m = ""
    if errors.class.name == "ActiveModel::Errors"
      errors.each do |e|
        m = "#{e.attribute} #{e.message};#{m}"
      end
    else
      errors.each do |k, v|
        m = "#{v}"
      end
    end
    m
  end

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
