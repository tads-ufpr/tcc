require 'rails_helper'

RSpec.describe "/residents", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let!(:condo) { create(:condominium, :with_staff, :with_apartments) }
  let(:ap) { condo.apartments.first }
  let!(:resident1) { create(:resident, apartment: ap) }
  let!(:resident2) { create(:resident, apartment: ap) }

  describe "GET /residents/:id" do
    let!(:resident_to_show) { ap.residents.first }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get resident_url(resident_to_show.id), headers:
    end

    describe "when unauthenticated" do
      it "deny access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when authenticated as unrelated employee", :auth do
      let(:user) do
        condo_2 = create(:condominium, :with_staff)
        condo_2.employees.first.user
      end

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when authenticated as condo unrelated resident", :auth do
      let(:user) do
        resident = create(:user)
        condo_2 = create(:condominium)
        ap_2 = create(:apartment, condominium: condo_2)
        create(:resident, user: resident, apartment: ap_2)
        resident
      end

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when authenticated as any resident from the same condo" do
      describe "" do
        let(:user) { ap.residents.second.user }

        it "succeeds", :auth do
          expect(response).to have_http_status(:success)
        end

        it "retuns the resident entity", :auth do
          parsed_body = response.parsed_body

          expect(parsed_body["id"]).to eq(resident_to_show.id)
          expect(parsed_body["apartment_id"]).to eq(resident_to_show.apartment_id)
          expect(parsed_body["owner"]).to eq(resident_to_show.owner)
          expect(parsed_body["created_at"]).to be_present
          expect(parsed_body["updated_at"]).to be_present

          user_data = parsed_body["user"]
          expect(user_data["id"]).to eq(resident_to_show.user.id)
          expect(user_data["name"]).to eq(resident_to_show.user.name)
        end
      end
    end

    describe "when authenticated as condominum's employee", :auth do
      let(:user) { condo.employees.first.user }

      it "succeeds" do
        expect(response).to have_http_status(:success)
      end
    end
  end
end