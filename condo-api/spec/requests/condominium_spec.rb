require 'rails_helper'

RSpec.describe "Condominia", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let(:user) { FactoryBot.create(:user) }

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
      let(:auth_headers) { authenticated_headers_for(user) }

      it "should create the new Condominium" do
        expect {
          post condominia_url,
          params: { condominium: condo_attributes },
          as: :json,
          headers: authenticated_headers_for(user)
        }.to change(Condominium, :count).by(1)

        expect(response).to have_http_status(201)
      end

      it "should create the Employee entity for the User" do
        expect {
          post condominia_url,
          params: { condominium: condo_attributes },
          as: :json,
          headers: authenticated_headers_for(user)
        }.to change(Employee, :count).by(1)

        expect(response).to have_http_status(201)
      end
    end
  end
end
