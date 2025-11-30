require 'rails_helper'

RSpec.describe "/apartments/:apartment_id/residents", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let!(:condo) { create(:condominium, :with_staff, :with_residents, residents_count: 3) }
  let(:ap) { condo.apartments.first }

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

  describe "GET /residents/:id" do
    let!(:resident_to_show) { create(:resident, apartment: ap) }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get apartment_resident_url(ap.id, resident_to_show.id), headers:
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

    describe "when authenticated as any resident from the same condo", :auth do
      let(:user) { ap.residents.second.user }

      it "succeeds" do
        expect(response).to have_http_status(:success)

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

    describe "when authenticated as condominum's employee", :auth do
      let(:user) { condo.employees.first.user }

      it "succeeds" do
        expect(response).to have_http_status(:success)

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
end
