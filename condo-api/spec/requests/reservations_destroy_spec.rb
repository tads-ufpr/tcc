require 'rails_helper'

RSpec.describe "/reservations", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let!(:condo) { create(:condominium, :with_staff, :with_residents, residents_count: 2) }
  let!(:facility) { create(:facility, condominium: condo) }
  let!(:resident_user) { condo.residents.first.user }
  let!(:another_resident) { condo.residents.second.user }
  let!(:apartment) { resident_user.apartments.first }
  let!(:another_user) { create(:user) }
  let!(:reservation) { create(:reservation, facility: facility, apartment: apartment, creator: resident_user) }

  describe "DELETE /reservations/:id" do
    let(:url) { reservation_url(reservation.id) }

    context "when unauthenticated" do
      it "returns unauthorized" do
        delete url, headers: json_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      context "as an unrelated user" do
        let(:headers) { json_headers.merge(authenticated_headers_for(another_user)) }

        it "returns forbidden" do
          delete url, headers: headers
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "as another resident of the condo" do
        let(:headers) { json_headers.merge(authenticated_headers_for(another_resident)) }

        it "returns forbidden" do
          delete url, headers: headers
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "as the creator of the reservation" do
        let(:headers) { json_headers.merge(authenticated_headers_for(resident_user)) }

        it "destroys the reservation" do
          expect {
            delete url, headers: headers
          }.to change(Reservation, :count).by(-1)
          expect(response).to have_http_status(:no_content)
        end

        context "when the reservation is in the past" do
          before do
            reservation.update!(scheduled_date: 1.day.ago)
          end

          it "returns unprocessable_content" do
            delete url, headers: headers
            expect(response).to have_http_status(:unprocessable_content)
            expect(response.parsed_body["message"]).to eq("base Cannot delete a reservation in the past;")
          end

          it "does not destroy the reservation" do
            expect {
              delete url, headers: headers
            }.not_to change(Reservation, :count)
          end
        end
      end

      context "as an admin of the condo" do
        let(:admin_user) { condo.employees.find_by(role: :admin).user }
        let(:headers) { json_headers.merge(authenticated_headers_for(admin_user)) }

        it "destroys the reservation" do
          expect {
            delete url, headers: headers
          }.to change(Reservation, :count).by(-1)
          expect(response).to have_http_status(:no_content)
        end
      end
    end
  end
end
