require 'rails_helper'
require 'jwt'

RSpec.shared_context 'auth_headers', shared_context: :metadata do
  def authenticated_headers_for(user)
    payload = { user_id: user.id }
    secret_key = Rails.application.credentials.secret_key_base
    token = JWT.encode(payload, secret_key, 'HS256')
    sign_in(user)
    { 'Authorization' => "Bearer #{token}" }
  end
end
