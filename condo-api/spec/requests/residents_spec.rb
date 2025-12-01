require 'rails_helper'

RSpec.describe "/apartments/:apartment_id/residents", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let!(:condo) { create(:condominium, :with_staff, :with_residents, residents_count: 3) }
  let(:ap) { condo.apartments.first }

  describe "GET /apartments/:apartment_id/residents" do
    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get apartment_residents_url(ap.id), headers:
    end

    describe "when unauthenticated" do
      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when authenticated as an unrelated user", :auth do
      let(:user) { create(:user) }

      it "returns forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when authenticated as a resident of another condominium", :auth do
      let(:user) do
        other_condo = create(:condominium, :with_residents)
        other_condo.residents.first.user
      end

      it "returns forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when authenticated as a resident of another apartment in the same condo", :auth do
      let(:user) { condo.residents.second.user }

      it "returns forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when authenticated as a resident of the apartment", :auth do
      let(:user) { ap.residents.first.user }

      it "returns success" do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body.size).to eq(ap.residents.count)
      end
    end

    describe "when authenticated as a collaborator of the condominium", :auth do
      let(:user) do
        create(:employee, :collaborator, condominium: condo).user
      end

      it "returns success" do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body.size).to eq(ap.residents.count)
      end
    end

    describe "when authenticated as an admin of the condominium", :auth do
      let(:user) do
        admin = condo.employees.find_by(role: :admin)
        admin.user
      end

      it "returns success" do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body.size).to eq(ap.residents.count)
      end
    end
  end

  describe "GET /residents/:id" do
    let(:resident_to_show) { ap.residents.first }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get resident_url(resident_to_show.id), headers:
    end

    describe "when unauthenticated" do
      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when authenticated as an unrelated user", :auth do
      let(:user) { create(:user) }

      it "returns forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when authenticated as a resident of another condominium", :auth do
      let(:user) do
        other_condo = create(:condominium, :with_residents)
        other_condo.residents.first.user
      end

      it "returns forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when authenticated as a resident of another apartment in the same condo", :auth do
      let(:user) { condo.residents.second.user }

      it "returns success" do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body["id"]).to eq(resident_to_show.id)
      end
    end

    describe "when authenticated as the resident being shown", :auth do
      let(:user) { resident_to_show.user }

      it "returns success" do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body["id"]).to eq(resident_to_show.id)
      end
    end

    describe "when authenticated as a collaborator of the condominium", :auth do
      let(:user) do
        create(:employee, :collaborator, condominium: condo).user
      end

      it "returns success" do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body["id"]).to eq(resident_to_show.id)
      end
    end

    describe "when authenticated as an admin of the condominium", :auth do
      let(:user) do
        admin = condo.employees.find_by(role: :admin)
        admin.user
      end

      it "returns success" do
        expect(response).to have_http_status(:success)
        expect(response.parsed_body["id"]).to eq(resident_to_show.id)
      end
    end
  end

  describe "POST /apartments/:apartment_id/residents" do
    let(:params) do
      u = FactoryBot.create(:user)
      { resident: attributes_for(:resident, user_id: u.id, apartment_id: ap.id) }
    end

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      create(:resident)

      post apartment_residents_url(ap.id), params: params.to_json, headers:
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

    describe "when authenticated as non-owner resident", :auth do
      let(:user) do
        resident = create(:user)
        create(:resident, user: resident, apartment: ap)
        resident
      end

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when authenticated as apartment's owner", :auth do
      let(:user) { ap.residents.first.user }

      it "succeeds" do
        expect(response).to have_http_status(:success)
      end
    end

    describe "when authenticated as condominum's adminstrator", :auth do
      let(:user) do
        condo.employees.first.update(role: :admin)
        condo.employees.first.user
      end

      it "succeeds" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /residents/:id" do
    let!(:resident_to_update) { create(:resident, apartment: ap, owner: false) }
    let(:params) { { resident: { owner: true } } }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      patch apartment_resident_url(ap.id, resident_to_update.id), params: params.to_json, headers:
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

    describe "when authenticated as non-owner resident", :auth do
      let(:user) do
        resident = create(:user)
        create(:resident, user: resident, apartment: ap)
        resident
      end

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when authenticated as apartment's owner", :auth do
      let(:user) { ap.residents.first.user }

      it "succeeds" do
        expect(response).to have_http_status(:success)
        expect(resident_to_update.reload.owner).to be(true)
      end
    end

    describe "when authenticated as condominum's adminstrator", :auth do
      let(:user) do
        condo.employees.first.update(role: :admin)
        condo.employees.first.user
      end

      it "succeeds" do
        expect(response).to have_http_status(:success)
        expect(resident_to_update.reload.owner).to be(true)
      end
    end
  end

  describe "DELETE /residents/:id" do
    let!(:resident_to_delete) { create(:resident, apartment: ap) }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      delete apartment_resident_url(ap.id, resident_to_delete.id), headers:
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

    describe "when authenticated as non-owner resident", :auth do
      let(:user) do
        resident = create(:user)
        create(:resident, user: resident, apartment: ap)
        resident
      end

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when authenticated as apartment's owner", :auth do
      let(:user) { ap.residents.first.user }

      it "succeeds" do
        expect(response).to have_http_status(:no_content)
        expect { resident_to_delete.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "when authenticated as condominum's adminstrator", :auth do
      let(:user) do
        condo.employees.first.update(role: :admin)
        condo.employees.first.user
      end

      it "succeeds" do
        expect(response).to have_http_status(:no_content)
        expect { resident_to_delete.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "when authenticated and deleting own resident profile", :auth do
      let(:user) do
        non_owner_resident_user = create(:user)
        create(:resident, user: non_owner_resident_user, apartment: ap, owner: false)
        non_owner_resident_user
      end
      let!(:resident_to_delete) { user.residents.first }

      it "succeeds" do
        expect(response).to have_http_status(:no_content)
        expect { resident_to_delete.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
