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
    let(:valid_params) do
      { reservation: attributes_for(:reservation, apartment_id: apartment.id) }
    end
    let(:invalid_params_without_apartment) do
      { reservation: attributes_for(:reservation, apartment_id: nil) }
    end

    context "when unauthenticated" do
      it "returns unauthorized" do
        post url, params: valid_params.to_json, headers: json_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      let(:headers) { json_headers.merge(authenticated_headers_for(user)) }

      context "and user is unrelated" do
        let(:user) { another_user }

        it "returns forbidden" do
          post url, params: valid_params.to_json, headers: headers
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "and user is a resident" do
        let(:user) { resident_user }

        context "with valid parameters" do
          it "creates the new reservation" do
            post url, params: valid_params.to_json, headers: headers
            expect(response).to have_http_status(:created)
          end

          it "returns the created reservation" do
            post url, params: valid_params.to_json, headers: headers
            expect(response.parsed_body).to include("id", "facility_id", "apartment_id", "creator_id")
          end

          it "sets the creator to the current user" do
            post url, params: valid_params.to_json, headers: headers
            expect(response.parsed_body["creator_id"]).to eq(user.id)
          end
        end

        context "with invalid parameters (without apartment)" do
          it "returns unprocessable_content" do
            post url, params: invalid_params_without_apartment.to_json, headers: headers
            expect(response).to have_http_status(:unprocessable_content)
            expect(response.parsed_body["message"]).to include("apartment must exist;")
            expect(response.parsed_body["message"]).to include("apartment can't be blank;")
          end
        end

        context "when apartment has 2 pending reservations" do
          before do
            reservations = build_list(:reservation, 2, apartment: apartment, creator: user, scheduled_date: 1.day.from_now)
            reservations.each { |r| r.save(validate: false) }
            post url, params: valid_params.to_json, headers: headers
          end

          it "returns unprocessable_content" do
            expect(response).to have_http_status(:unprocessable_content)
            expect(response.parsed_body["message"]).to include("apartment has reached the limit of pending reservations;")
          end
        end

        context "when apartment has 2 concluded reservations" do
          before do
            reservations = build_list(:reservation, 2, apartment: apartment, creator: user, scheduled_date: 1.day.ago)
            reservations.each { |r| r.save(validate: false) }
            post url, params: valid_params.to_json, headers: headers
          end

          it "creates the new reservation" do
            expect(response).to have_http_status(:created)
          end
        end
      end
    end
  end
end
