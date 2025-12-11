require 'rails_helper'

RSpec.describe 'Condominia', type: :request do
  include_context 'json_requests'
  include_context 'auth_headers'

  let(:user) { create(:user) }
  let!(:condo) { create(:condominium, :with_staff, name: 'Lorem', city: "Los Angeles") }
  let(:employee) { condo.employees.first.user }

  describe 'GET /condominia' do
    context 'with no query string' do
      before do
        get condominia_url, headers: json_headers
      end

      it 'returns success' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a list of condominium' do
        expect(response.parsed_body).to be_a(Array)
      end

      it 'does not bring apartments info' do
        expect(response.parsed_body[0]["apartments"]).to be_empty
      end
    end

    context 'with query string' do
      before do |test|
        create(:condominium, city: 'Curitiba')
        create(:condominium, name: "Loremar")
        create(:condominium, name: "Loremar", city: 'Curitiba')
      end

      it 'returns filtered response for name' do
        get condominia_url, params: { q: 'Lorem' }, headers: json_headers

        expect(response.parsed_body.count).to eq(3)
      end

      it 'returns filtered response for city', city: 'Curitiba' do
        get condominia_url, params: { q: 'Curitiba' }, headers: json_headers

        expect(response.parsed_body.count).to eq(2)
      end
    end

    context 'when authenticated' do
      before do
        headers = json_headers.merge(authenticated_headers_for(employee))

        get condominia_url, headers:
      end

      it "succeeds" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST /condiminia' do
    let(:params) { { condominium: attributes_for(:condominium) } }

    before do |test|
      headers = json_headers
      headers = headers.merge(authenticated_headers_for(user)) if test.metadata[:auth]

      post condominia_url, params: params.to_json, headers:
    end

    context 'when unauthenticated' do
      it 'deny access' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated', :auth do
      it 'creates the new Condominium' do
        expect(response).to have_http_status(:created)
      end

      it 'creates a new employee with current_user as :admin' do
        last_created_employee = Employee.last

        expect(last_created_employee.user_id).to eq(user.id)
        expect(last_created_employee.role).to eq("admin")
      end
    end
  end

  describe 'GET /condominia/:id' do
    let(:user_headers) { json_headers.merge(authenticated_headers_for(user)) }
    let(:employee_headers) { json_headers.merge(authenticated_headers_for(employee)) }

    context 'when a guest' do
      before do
        get condominium_path(condo), params: { id: condo.id }, headers: json_headers
      end

      it 'is allowed' do
        expect(response).to have_http_status(:ok)
      end

      it 'does not display sensitive data' do
        expect(response.parsed_body['apartments']).to be_empty
      end
    end

    context 'with an admin or resident' do
      it 'displays the related apartments on it' do
        get condominium_path(condo), headers: employee_headers

        expect(response.parsed_body).to have_key('apartments')
      end
    end

    context 'with a user without relation with the condominium' do
      it 'does not display the related apartments' do
        get condominium_path(condo), headers: user_headers

        expect(response.parsed_body['apartments']).to be_empty
      end
    end
  end

  describe 'DEL /condominia/:id' do
    let(:employee_headers) { json_headers.merge(authenticated_headers_for(employee)) }

    context 'when a guest' do
      it 'is unauthorized' do
        delete condominium_path(condo), headers: json_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with an admin' do
      it 'is authorized and deletes the condominium and employee relations' do
        expect do
          delete condominium_path(condo), headers: employee_headers
        end.to change(Condominium, :count).by(-1).and change(Employee, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
