require 'rails_helper'

RSpec.describe '/facilities', type: :request do
  include_context 'json_requests'
  include_context 'auth_headers'

  let(:condo) { create(:condominium, :with_staff, :with_residents) }
  let!(:facility) { create(:facility, condominium: condo) }

  describe 'GET /condominia/:condominium_id/facilities' do
    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get condominium_facilities_url(condo.id), headers: headers
    end

    context 'when unauthenticated' do
      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated', :auth do
      context 'with admin' do
        let(:user) { condo.employees.first.user }

        it 'succeeds' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns only facilities for the condominium' do
          expect(response.parsed_body.size).to eq(1)
          expect(response.parsed_body.first['id']).to eq(facility.id)
        end
      end

      context "with related resident", :auth do
        let(:user) { condo.residents.first.user }

        it "succeeds" do
          expect(response).to have_http_status(:success)
        end
      end

      context "with unrelated user", :auth do
        let(:user) { create(:user) }

        it "deny access" do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe 'GET /facilities/:id' do
    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      get facility_url(facility.id), headers:
    end

    context 'when unauthenticated' do
      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated', :auth do
      context 'with admin' do
        let(:user) { condo.employees.first.user }

        it 'succeeds' do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['id']).to eq(facility.id)
        end
      end

      context 'with collaborator' do
        let(:user) do
          u = create(:user)
          create(:employee, condominium: condo, user: u, role: :collaborator)
          u
        end

        it 'succeeds' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'with resident' do
        let(:user) { condo.residents.first.user }

        it 'succeeds' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when unrelated user' do
        let(:user) { create(:user) }

        it 'returns forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe 'POST /condominia/:condominium_id/facilities' do
    let(:params) do
      { facility: attributes_for(:facility) }
    end

    context 'when unauthenticated' do
      it 'returns unauthorized' do
        post condominium_facilities_url(condo.id), params: params.to_json, headers: json_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated', :auth do
      let(:headers) { json_headers.merge(authenticated_headers_for(user)) }

      context 'with admin' do
        let(:user) { condo.employees.first.user }

        it 'creates the facility' do
          post condominium_facilities_url(condo.id), params: params.to_json, headers: headers
          expect(response).to have_http_status(:created)
        end
      end

      context 'with collaborator' do
        let(:user) do
          u = create(:user)
          create(:employee, condominium: condo, user: u, role: :collaborator)
          u
        end

        it 'returns forbidden' do
          post condominium_facilities_url(condo.id), params: params.to_json, headers: headers
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "with resident" do
        let(:user) { condo.residents.first.user }

        it "deny access" do
          post condominium_facilities_url(condo.id), params: params.to_json, headers: headers
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe 'PUT /facilities/:id' do
    let(:params) do
      { facility: { tax: "100" } }
    end

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      put facility_url(facility.id), params: params.to_json, headers:
    end

    context 'when unauthenticated' do
      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated', :auth do
      context 'with admin' do
        let(:user) { condo.employees.first.user }

        it 'updated the facility' do
          expect(response).to have_http_status(:success)
          expect(facility.reload.tax).to eq(100)
        end
      end

      context 'with collaborator' do
        let(:user) do
          u = create(:user)
          create(:employee, condominium: condo, user: u, role: :collaborator)
          u
        end

        it 'returns forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "with resident" do
        let(:user) { condo.residents.first.user }

        it "deny access" do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe 'DELETE /facilities/:id' do
    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      delete facility_url(facility.id), headers:
    end

    context 'when unauthenticated' do
      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated', :auth do
      context 'with admin' do
        let(:user) { condo.employees.first.user }

        it 'deletes the facility' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'with collaborator' do
        let(:user) do
          u = create(:user)
          create(:employee, condominium: condo, user: u, role: :collaborator)
          u
        end

        it 'returns forbidden' do
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "with resident" do
        let(:user) { condo.residents.first.user }

        it "deny access" do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
