require 'rails_helper'

RSpec.describe "Employees", type: :request do
  include_context 'json_requests'
  include_context 'auth_headers'

  describe "GET /employees" do
    before do |test|
      headers = json_headers
      headers = headers.merge(authentication_headers_for(user)) if test.metadata[:auth]

      get employees_url, headers:
    end

    it "requires authentication" do
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
