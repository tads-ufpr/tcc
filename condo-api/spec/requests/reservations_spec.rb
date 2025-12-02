require 'rails_helper'

RSpec.describe "/reservations", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let!(:condo) { create(:condominium, :with_staff, :with_residents, residents_count: 1) }
  let!(:facility) { create(:facility, condominium: condo) }
  let!(:resident_user) { condo.residents.first.user }
  let!(:apartment) { resident_user.apartments.first }
  let!(:another_user) { create(:user) }

  describe "POST /facilities/:facility_id/reservations" do
    let(:url) { facility_reservations_url(facility.id) }
    let(:params) do
      { reservation: attributes_for(:reservation, apartment_id: apartment.id) }
    end

    context "when unauthenticated" do
      let(:user) { nil }

      before do
        post url, params: params.to_json, headers: json_headers
      end

      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated", :auth do
      let(:headers) { json_headers.merge(authenticated_headers_for(user)) }

      context "as an unrelated user" do
        let(:user) { another_user }

        before do
          post url, params: params.to_json, headers: headers
        end

        it "returns forbidden" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "as a resident" do
        let(:user) { resident_user }

        context "with valid params" do
          before do
            post url, params: params.to_json, headers: headers
          end

          it "creates the new reservation" do
            expect(response).to have_http_status(:created)
          end

          it "returns the created reservation" do
            expect(response.parsed_body).to include("id", "facility_id", "apartment_id", "creator_id")
          end

          it "sets the creator to the current user" do
            expect(response.parsed_body["creator_id"]).to eq(user.id)
          end
        end

        context "without defining the apartment" do
          let(:params) do
            { reservation: attributes_for(:reservation, apartment_id: nil) }
          end

          before do
            post url, params: params.to_json, headers: headers
          end

          it "returns unprocessable_content" do
            expect(response).to have_http_status(:unprocessable_content)
          end
        end

        context "when apartment has 2 pending reservations" do
          before do
            reservations = build_list(:reservation, 2, apartment: apartment, scheduled_date: 1.day.from_now)
            reservations.each { |r| r.save(validate: false) }
            post url, params: params.to_json, headers: headers
          end

          it "returns unprocessable_content" do
            expect(response).to have_http_status(:unprocessable_content)
            expect(response.parsed_body["apartment"]).to include("has reached the limit of pending reservations")
          end
        end

        context "when apartment has 2 concluded reservations" do
          before do
            reservations = build_list(:reservation, 2, apartment: apartment, scheduled_date: 1.day.ago)
            reservations.each { |r| r.save(validate: false) }
            post url, params: params.to_json, headers: headers
          end

          it "creates the new reservation" do
            expect(response).to have_http_status(:created)
          end
        end
      end
    end
  end
end
