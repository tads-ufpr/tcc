require 'rails_helper'

RSpec.describe "/apartments", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let(:user) { FactoryBot.create(:user) }
  let!(:condo) { FactoryBot.create(:condominium, :with_staff) }
  let!(:employee) { condo.employees.first.user }

  let(:user_headers) { json_headers.merge(authenticated_headers_for(user)) }
  let(:employee_headers) { json_headers.merge(authenticated_headers_for(employee)) }

  describe "GET /apartments" do
    describe "when unauthenticated" do
      it "should return unauthorized" do
        get apartments_url, headers: json_headers

        expect(response).to have_http_status(401)
      end
    end
  end
end
