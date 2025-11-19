require 'rails_helper'

RSpec.describe "/apartments", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let!(:condo) { create(:condominium, :with_staff, :with_residents, residents_count: 3) }
  let(:query_params) { {} }

  describe "GET /condominia/:condominium_id/apartments" do
    let!(:old_apartment) { create(:apartment, :approved, condominium: condo, created_at: 3.days.ago) }
    let!(:pending_apartment) { create(:apartment, condominium: condo) }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]
      params = {}
      params = params.merge(query_params) if test.metadata[:query_param]

      get condominium_apartments_url(condo.id), params:, headers:
    end

    describe "when unauthenticated" do
      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when authenticated as Employee", :auth do
      let(:user) { condo.employees.first.user }

      it "succeed" do
        expect(response).to have_http_status(:ok)
      end

      it "displays all apartments" do
        expect(response.parsed_body).to be_an(Array)
        expect(response.parsed_body.count).to eq(5)
      end

      it "displays the residents" do
        expect(response.parsed_body.first).to have_key("status")
        expect(response.parsed_body.first).to have_key("residents")
      end

      describe "with query_params for created_after", :query_param do
        let(:query_params) { { created_after: 1.day.ago.iso8601 } }

        it "returns only newer apartments" do
          expect(response.parsed_body.count).to eq(4)
          expect(response.parsed_body.pluck(:id)).not_to include(old_apartment.id)
        end
      end

      describe "with query_params for created_before", :query_param do
        let(:query_params) { { created_before: 1.day.ago.iso8601 } }

        it "returns only older apartments" do
          expect(response.parsed_body.count).to eq(1)
          expect(response.parsed_body.pluck(:id)).to include(old_apartment.id)
        end
      end

      describe "with query_params for approveds only", :query_param do
        let(:query_params) { { status: "approved" } }

        it "displays only approveds if sent 'approved'" do
          expect(response.parsed_body.count).to eq(4)
          expect(response.parsed_body.pluck(:id)).not_to include(pending_apartment.id)
        end
      end

      describe "with query_params for pending only", :query_param do
        let(:query_params) { { status: "pending" } }

        it "displays only pending if sent 'pending'" do
          expect(response.parsed_body.count).to eq(1)
          expect(response.parsed_body.pluck(:id)).to include(pending_apartment.id)
        end
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

  describe "PATCH /apartments/:id/approve" do
    let!(:apartment) { create(:apartment, condominium: condo) }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      patch approve_apartment_url(apartment.id), headers:
    end

    describe "when unauthenticated" do
      it "deny access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when authenticated", :auth do
      describe "as resident" do
        let(:user) { condo.residents.first.user }

        it "deny access" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "as colaborator" do
        let(:user) { create(:employee, :colaborator, condominium: condo).user }

        it "deny access" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "as manager" do
        let(:user) { create(:employee, :manager, condominium: condo).user }

        it "approves the apartment" do
          expect(response).to have_http_status(:ok)
          expect(apartment.reload.status).to eq("approved")
        end
      end

      describe "as admin" do
        let(:user) { create(:employee, :admin, condominium: condo).user }

        it "approves the apartment" do
          expect(response).to have_http_status(:ok)
          expect(apartment.reload.status).to eq("approved")
        end
      end
    end
  end

  describe "PATCH /apartments/:id" do
    let!(:apartment) { create(:apartment, :with_residents, condominium: condo) }
    let(:params) do
      { apartment: { tower: "New Tower" } }
    end

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      patch apartment_url(apartment.id), params: params.to_json, headers:
    end

    describe "when unauthenticated" do
      it "deny access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when authenticated", :auth do
      describe "as a random user" do
        let(:user) { create(:user) }

        it "forbids access" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "as a resident of another apartment" do
        let(:user) { condo.residents.first.user }

        it "forbids access" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "as a non-owner resident of the apartment" do
        let(:user) do
          resident = create(:resident, apartment: apartment, owner: false)
          resident.user
        end

        it "forbids access" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "as a resident of the apartment" do
        let(:user) { apartment.residents.find_by(owner: true).user }

        it "updates the apartment" do
          expect(response).to have_http_status(:ok)
          expect(apartment.reload.tower).to eq("New Tower")
          expect(response.parsed_body).not_to have_key("residents")
        end
      end

      describe "as a colaborator of the condo" do
        let(:user) { create(:employee, :colaborator, condominium: condo).user }

        it "forbids access" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "as a manager of the condo" do
        let(:user) { create(:employee, :manager, condominium: condo).user }

        it "forbids access" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "as an admin of the condo" do
        let(:user) { create(:employee, :admin, condominium: condo).user }

        it "updates the apartment" do
          expect(response).to have_http_status(:ok)
          expect(apartment.reload.tower).to eq("New Tower")
          expect(response.parsed_body).not_to have_key("residents")
        end
      end
    end
  end

  describe "DELETE /apartments/:id" do
    let!(:apartment) { create(:apartment, :with_residents, condominium: condo) }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      delete apartment_url(apartment.id), headers:
    end

    describe "when unauthenticated" do
      it "deny access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when authenticated", :auth do
      describe "as a random user" do
        let(:user) { create(:user) }

        it "forbids access" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "as a resident of another apartment" do
        let(:user) { condo.residents.first.user }

        it "forbids access" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "as a non-owner resident of the apartment" do
        let(:user) do
          resident = create(:resident, apartment: apartment, owner: false)
          resident.user
        end

        it "forbids access" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "as owner of the apartment" do
        let(:user) { apartment.residents.find_by(owner: true).user }

        it "updates the apartment" do
          expect(response).to have_http_status(:success)
        end
      end

      describe "as a colaborator of the condo" do
        let(:user) { create(:employee, :colaborator, condominium: condo).user }

        it "forbids access" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "as a manager of the condo" do
        let(:user) { create(:employee, :manager, condominium: condo).user }

        it "forbids access" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe "as an admin of the condo" do
        let(:user) { create(:employee, :admin, condominium: condo).user }

        it "updates the apartment" do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "GET /apartments/:apartment_id" do
    let!(:apartment) { create(:apartment, :with_residents, condominium: condo) }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get apartment_url(apartment.id), headers:
    end

    describe "when unauthenticated" do
      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when authenticated as Employee", :auth do
      let(:user) { condo.employees.first.user }

      it "succeed" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the residents" do
        expect(response.parsed_body).to have_key("status")
        expect(response.parsed_body).to have_key("residents")
      end
    end

    describe "when authenticated as unrelated user", :auth do
      let(:user) { create(:user) }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when authenticated as non-owner resident", :auth do
      let(:user) do
        user = create(:user)
        create(:resident, apartment: apartment, user: user)
        user
      end

      it "allows access" do
        expect(response).to have_http_status(:success)
      end
    end

    describe "when authenticated as unrelated administrator", :auth do
      let(:user) do
        condo = create(:condominium, :with_staff)
        condo.employees.first.user
      end

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
