require 'rails_helper'

RSpec.describe "/reservations", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let!(:condo) { create(:condominium, :with_staff, :with_residents, residents_count: 1) }
  let!(:facility) { create(:facility, condominium: condo) }
  let!(:past_reservation) do
    reservation = build(:reservation,
                        facility: facility,
                        apartment: condo.apartments.first,
                        creator: condo.residents.first.user,
                        scheduled_date: 1.week.ago)

    reservation.save(validate: false)
    reservation
  end
  let!(:future_reservation) do
    create(:reservation,
           facility: facility,
           apartment: condo.apartments.first,
           creator: condo.residents.first.user,
           scheduled_date: 1.week.from_now)
  end

  describe "GET /facilities/:facility_id/reservations" do
    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      params = test.metadata[:until].present? ? { until: test.metadata[:until] } : {}

      get facility_reservations_url(facility.id), params:, headers:
    end

    context "when unauthenticated" do
      it "deny access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when unrelated to condo", :auth do
      let(:user) { create(:user) }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when authenticated as resident", :auth do
      let(:user) { condo.residents.first.user }

      it "succeed the request" do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body.first["id"]).to eq(future_reservation.id)
      end
    end

    context "when authenticated as employee", :auth do
      let(:user) { condo.employees.first.user }

      it "succeed the request" do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body.first["id"]).to eq(future_reservation.id)
      end
    end

    context "with 'until' parameter", :auth do
      let(:user) { condo.residents.first.user }

      it "returns past reservations", until: 2.weeks.ago.to_s do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body.first["id"]).to eq(past_reservation.id)
      end
    end
  end
end
