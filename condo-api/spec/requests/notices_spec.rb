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
end
