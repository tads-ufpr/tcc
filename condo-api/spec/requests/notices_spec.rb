require 'rails_helper'

RSpec.describe '/notices', type: :request do
  include_context 'json_requests'
  include_context 'auth_headers'

  let!(:condo) {
    create(:condominium,
      :with_staff,
      :with_residents,
      residents_count: 3
    )
  }

  before do
    create(:notice,
           :delivery,
           creator: condo.employees.first,
           apartment: condo.apartments.first)
  end

  describe 'GET /condominia/:condominium_id/notices' do
    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get condominium_notices_url(condo_id), headers:
    end

    describe "when unauthenticated" do
      let(:condo_id) { condo.id }

      it "deny the access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when :resident", :auth do
      let(:condo_id) { condo.id }
      let(:user) { condo.residents.first.user }

      it "deny the access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee from unrelated Condominium", :auth do
      let(:condo_2) { create(:condominium, :with_staff) }
      let(:condo_id) { condo.id }
      let(:user) { condo_2.employees.first.user }

      it "deny the access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee", :auth do
      let(:condo_id) { condo.id }
      let(:user) { condo.employees.first.user }

      it "allows the request" do
        expect(response).to have_http_status(:success)
      end

      it "returns a list of Condominium's Notices" do
        expect(response.parsed_body).to be_an_instance_of(Array)
        expect(response.parsed_body.count).to eq(1)
      end
    end
  end

  describe 'GET /apartments/:apartment_id/notices' do
    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get apartment_notices_url(apartment_id), headers:
    end

    describe "when unauthenticated" do
      let(:apartment_id) { condo.apartments.first.id }

      it "deny the access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when :employee from unrelated Condominium", :auth do
      let(:apartment_id) { condo.apartments.first.id }
      let(:condo_2) { create(:condominium, :with_staff) }
      let(:user) { condo_2.employees.first.user }

      it "deny the access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee", :auth do
      let(:apartment_id) { condo.apartments.first.id }
      let(:user) { condo.employees.first.user }

      it "allows the request" do
        expect(response).to have_http_status(:success)
      end

      it "returns a list of Apartments Notices" do
        expect(response.parsed_body).to be_an_instance_of(Array)
      end
    end

    describe "when :resident from unrelated Apartment", :auth do
      let(:apartment_id) { condo.apartments.first.id }
      let(:user) { condo.apartments.second.residents.first.user }

      it "deny the access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :resident", :auth do
      let(:apartment_id) { condo.apartments.first.id }
      let(:user) { condo.apartments.first.residents.first.user }

      it "allows the request" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST /apartments/:apartment_id/notices' do
    let(:notice_params) {
      attributes_for(:notice,
                     :delivery,
                     creator: condo.employees.first,
                     apartment: condo.apartments.first
      ).to_json
    }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      post apartment_notices_url(apartment_id), params: notice_params, headers:
    end

    describe "when unauthenticated", auth: false do
      let(:apartment_id) { condo.apartments.first.id }

      it "returns :unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when :resident", :auth do
      let(:user) { condo.residents.first.user }
      let(:apartment_id) { condo.residents.first.apartment.id }

      it "returns :forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee from unrelated Condominium", :auth do
      let(:user) { condo.employees.first.user }
      let(:condo_2) { create(:condominium, :with_residents) }
      let(:apartment_id) { condo_2.apartments.first.id }

      it "deny creation for unrelated apartment" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee", :auth do
      let(:user) { condo.employees.first.user }
      let(:apartment_id) { condo.apartments.first.id }

      it "allows the creation" do
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'GET /notices/:id' do
    let(:notice) {
      create(:notice,
             :delivery,
             creator: condo.employees.first,
             apartment: condo.apartments.first)
    }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get notice_url(notice.id), headers:
    end

    describe "when :unauthenticated" do
      it "deny access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when :resident from unrelated Apartment", :auth do
      let(:user) { condo.apartments.second.residents.first.user }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :resident", :auth do
      let(:user) { notice.apartment.residents.first.user }

      it "allows the access" do
        expect(response).to have_http_status(:success)
      end
    end

    describe "when :employee from unrelated Condominium", :auth do
      let(:condo_2) { create(:condominium, :with_staff) }
      let(:user) { condo_2.employees.first.user }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee", :auth do
      let(:user) { condo.employees.first.user }

      it "allows the acess" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'PUT /notices/:id' do
    let(:notice) {
      create(:notice,
             :delivery,
             creator: condo.employees.first,
             apartment: condo.apartments.first)
    }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      params = { status: "acknowledged" }.to_json

      put notice_url(notice.id), params:, headers:
    end

    describe "when :unauthenticated" do
      it "deny access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when :resident from unrelated Apartment", :auth do
      let(:user) { condo.apartments.second.residents.first.user }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :resident", :auth do
      let(:user) { notice.apartment.residents.first.user }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee from unrelated Condominium", :auth do
      let(:condo_2) { create(:condominium, :with_staff) }
      let(:user) { condo_2.employees.first.user }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee", :auth do
      let(:user) { condo.employees.first.user }

      it "allows the acess" do
        expect(response).to have_http_status(:success)
      end

      it "update the entity" do
        expect(response.parsed_body["status"]).to eq("acknowledged")
        expect(notice.reload.status).to eq("acknowledged")
      end
    end
  end

  describe 'DELETE /notices/:id' do
    let(:notice) {
      create(:notice,
             :delivery,
             creator: condo.employees.first,
             apartment: condo.apartments.first)
    }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      delete notice_url(notice.id), headers:
    end

    describe "when :unauthenticated" do
      it "deny access" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "when :resident from unrelated Apartment", :auth do
      let(:user) { condo.apartments.second.residents.first.user }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :resident", :auth do
      let(:user) { notice.apartment.residents.first.user }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee from unrelated Condominium", :auth do
      let(:condo_2) { create(:condominium, :with_staff) }
      let(:user) { condo_2.employees.first.user }

      it "deny access" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "when :employee", :auth do
      let(:user) { condo.employees.first.user }

      it "allows the acess" do
        expect(response).to have_http_status(:success)
      end

      it "delete the entity" do
        expect(Notice.find_by(id: notice.id)).to be_nil
      end
    end
  end
end
