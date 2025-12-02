require 'rails_helper'

RSpec.describe "Apartments::ReservationsController", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let!(:condo) { create(:condominium, :with_staff, :with_residents, residents_count: 2) }
  let!(:facility) { create(:facility, condominium: condo) }

  describe "GET /apartments/:apartment_id/reservations" do
    before do |test|
      2.times do |i|
        create(:reservation,
             facility: facility,
             apartment: condo.apartments.first,
             creator: condo.residents.first.user,
             scheduled_date: Date.today + i.days)
      end

      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get apartment_reservations_url(condo.apartments.first.id), headers: headers
    end

    context "when unauthenticated" do
      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated", :auth do
      context "with resident of the apartment" do
        let(:user) { condo.residents.first.user }

        it "returns upcoming reservations for the apartment" do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body.count).to eq(2)
        end
      end

      context "with resident of another apartment" do
        let(:user) { condo.residents.last.user }

        it "returns forbidden" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "with an unrelated user" do
        let(:user) { create(:user) }

        it "returns forbidden" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "with as employee" do
        let(:user) { condo.employees.first.user }

        it "returns upcoming reservations for the apartment" do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body.count).to eq(2)
        end
      end
    end
  end
end
