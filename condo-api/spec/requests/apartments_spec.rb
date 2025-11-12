require 'rails_helper'

RSpec.describe "/apartments", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let!(:condo) { create(:condominium, :with_staff) }

  describe "GET /condominia/:condominium_id/apartments" do
    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get condominium_apartments_url(condo.id), headers:
    end

    describe "when unauthenticated" do
      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /condominia/:condominium_id/apartments" do
    let(:params) do
      { apartment: attributes_for(:apartment, condominium: condo) }
    end

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      post condominium_apartments_url(condo.id), params: params.to_json, headers:
    end

    describe "when unauthenticated" do
      it "deny access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when authenticated", :auth do
      describe "as simple user" do
        let(:user) { create(:user) }

        it "creates the new apartment" do
          expect(response).to have_http_status(:created)
        end

        it "relates itself with the Condominium" do
          expect(condo.apartments.last.id).to eq(response.parsed_body["id"])
        end

        it "sets the current_user as Resident" do
          ap = Apartment.find(response.parsed_body["id"])
          expect(ap.residents.first.user_id).to eq(user.id)
        end
      end
    end
  end
end
