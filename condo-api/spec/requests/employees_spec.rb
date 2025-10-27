require 'rails_helper'

RSpec.describe "Employees", type: :request do
  include_context 'json_requests'
  include_context 'auth_headers'

  let!(:condo) {
    create(:condominium, :with_staff, :with_residents, residents_count: 5)
  }
  let(:condominium_id) { condo.id }

  describe "GET /condominia/:id/employees" do
    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get condominium_employees_url(condominium_id), headers:
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
        condo_2 = create(:condominium, :with_staff)
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

  describe "POST /condominia/:condominium_id/employees" do
    let(:params) {
      attributes_for(:employee,
                     condominium_id: condominium_id,
                     user_id: condo.residents.first.user.id
      ).to_json
    }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      post condominium_employees_url(condominium_id), params:, headers:
    end

    describe "unauthenticated" do
      it "deny access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when :resident", :auth do
      let(:user) { condo.residents.first.user }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee from unrelated Condominium", :auth do
      let(:user) do
        condo_2 = create(:condominium, :with_staff)
        condo_2.employees.first.user
      end

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee", :auth do
      let(:user) { condo.employees.first.user }

      context "with empty params" do
        let(:params) { {}.to_json }

        it "invalidate the request" do
          expect(response).to have_http_status(:bad_request)
        end
      end

      context "with invalid parameters" do
        let(:params) do
          p = attributes_for(:employee, condominium_id: condominium_id)
          p[:user_id] = "OK"
          p.to_json
        end

        it "deny the employee creation" do
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "describes the error" do
          expect(response.parsed_body["errors"]).to have_key("user")
        end
      end

      it "allows the request" do
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /employees/:id" do
    let(:employee_id) { condo.employees.first.id }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get employee_url(employee_id), headers:
    end

    describe "when unauthenticated" do
      it "deny access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when :resident", :auth do
      let(:user) { condo.residents.first.user }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee from unrelated Condominium", :auth do
      let(:user) do
        condo_2 = create(:condominium, :with_staff)
        condo_2.employees.first.user
      end

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee", :auth do
      let(:user) { condo.employees.first.user }

      it "allows the request" do
        expect(response).to have_http_status(:success)
      end

      it "display the employee's name" do
        expect(response.parsed_body).to have_key("user")
      end
    end
  end
end
