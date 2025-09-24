require 'rails_helper'
require 'jwt'

RSpec.shared_context 'auth_headers', shared_context: :metadata do
  def authenticated_headers_for(user)
    payload = { jti: user.jti }
    secret_key = Rails.application.credentials.devise_jwt_secret_key
    token = JWT.encode(payload, secret_key, 'HS256')
    { 'Authorization' => "Bearer #{token}" }
  end
end
