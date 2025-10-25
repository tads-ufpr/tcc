require 'rails_helper'

RSpec.describe "Employees", type: :request do
  include_context 'json_requests'
  include_context 'auth_headers'

  let(:condo) {
    create(:condominium, :with_staff, :with_residents, residents_count: 5)
  }

  describe "GET /condominia/:id/employees" do
    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get condominium_employees_url(condo.id), headers:
    end

    describe "unauthenticated" do
      it "deny access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "with Condominium's unrelated :user", :auth do
      let(:user) { create(:user) }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "with Condominium's unrelated :employee", :auth do
      let(:user) do
        condo_2 = create(:condomininium, :with_staff)
        condo_2.employees.first.user
      end

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "with Condominium's unrelated :resident", :auth do
      let(:user) do
        condo_2 = create(:condominium, :with_staff, :with_residents)
        condo_2.residents.first.user
      end

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "with Condomininium's :resident", :auth do
      let(:user) { condo.residents.first.user }

      it "allows the request" do
        expect(response).to have_http_status(:success)
      end
    end

    describe "with Condominium's :employee", :auth do
      let(:user) { condo.employees.first.user }

      it "allows the request" do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
