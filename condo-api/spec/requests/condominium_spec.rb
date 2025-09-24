require 'rails_helper'

RSpec.describe "Condominia", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let(:user) { FactoryBot.create(:user) }
  let!(:condo) { FactoryBot.create(:condominium, :with_staff) }
  let!(:employee) { condo.employees.first.user }
  let(:user_headers) { json_headers.merge(authenticated_headers_for(user)) }
  let(:employee_headers) { json_headers.merge(authenticated_headers_for(employee)) }

  describe "GET /condominia" do
    describe "when unauthenticated" do
      before do
        get condominia_url, headers: json_headers
      end

      it "should returns success" do
        expect(response).to have_http_status(200)
      end
      it "returns a list of condominium" do
        json_response = JSON.parse(response.body)

        expect(json_response).to be_kind_of(Array)
      end
    end
  end
  describe "POST /condiminia" do
    let(:condo_attributes) { FactoryBot.attributes_for(:condominium) }

    describe "when unauthenticated" do
      it "should be forbidden" do
        post condominia_url,
          params: { condominium: condo_attributes },
          as: :json

        expect(response).to have_http_status(401)
      end
    end
    describe "when authenticated" do
      it "should create the new Condominium" do
        expect {
          post condominia_url,
          params: { condominium: condo_attributes },
          as: :json,
          headers: user_headers
        }.to change(Condominium, :count).by(1)

        expect(response).to have_http_status(201)
      end

      it "should create the Employee entity for the User" do
        expect {
          post condominia_url,
          params: { condominium: condo_attributes },
          as: :json,
          headers: user_headers
        }.to change(Employee, :count).by(1)

        expect(response).to have_http_status(201)
      end
    end
  end
  describe "GET /condominia/:id" do
    describe "as guest" do
      it "should be allowed" do
        get condominia_url, params: { id: condo.id }, headers: json_headers

        expect(response).to have_http_status(200)
      end
      it "should not display sensitive data" do
        get condominium_path(condo), params: { id: condo.id }, headers: json_headers

        response_json = JSON.parse(response.body)
        expect(response_json).not_to have_key("apartments")
      end
    end
    describe "as admin or resident" do
      # TODO: should display the apartments and it's residents
    end
  end
  describe "DEL /condominia/:id" do
    describe "as guest" do
      it "should be unauthorized" do
        delete condominium_path(condo), headers: json_headers

        expect(response).to have_http_status(401)
      end
    end
    describe "as admin" do
      it "should be authorized" do
        delete condominium_path(condo), headers: employee_headers

        expect(response).to have_http_status(204)
      end

      it "should decrease the number of condominiums by 1" do
        expect {
          delete condominium_path(condo), headers: employee_headers
        }.to change(Condominium, :count).by(-1)
      end

      it "should delete the employee relation aswell" do
        expect {
          delete condominium_path(condo), headers: employee_headers
        }.to change(Employee, :count).by(-1)
      end
    end
  end
end
