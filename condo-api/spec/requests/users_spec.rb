require 'rails_helper'

RSpec.describe "Users", type: :request do
  include_context "json_requests"
  include_context "auth_headers"

  let(:user_params) { { user: params } }
  let(:params) { {
      name: "Test Tester",
      email: "test@test.com",
      birthdate: "15/12/2000",
      password: "test123",
      password_confirmation: "test123",
      document: Faker::IdNumber.brazilian_citizen_number
  }}

  describe "POST /users" do
    describe "with missing parameters" do
      before do |test|
        params.delete(test.metadata[:missing].to_sym)

        post users_url, params: user_params.to_json, headers: json_headers
      end

      it "deny creating without password", missing: "password" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "deny creating without email", missing: "email" do
        response_json = JSON.parse(response.body)

        expect(response_json["errors"]).to have_key("email")
      end

      it "deny crearting without document", missing: "document" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "happy path" do
      it "creates an User" do
        expect {
          post users_url, params: user_params.to_json, headers: json_headers
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(201)
      end
      it "returns a token" do
        post users_url, params: user_params.to_json, headers: json_headers

        expect(response.headers).to have_key("Authorization")
      end
    end
  end
end
