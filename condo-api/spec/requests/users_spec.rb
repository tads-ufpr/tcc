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
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "deny creating without email", missing: "email" do
        expect(response.parsed_body["message"]).to include("email can't be blank;")
      end

      it "deny crearting without document", missing: "document" do
        expect(response).to have_http_status(:unprocessable_content)
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

    describe "when sending camelCase params" do
      let(:params) do
        {
          firstName: "Tester",
          lastName: "Camelized",
          email: "test@test.com",
          birthdate: "15/12/2000",
          password: "test123",
          passwordConfirmation: "test123",
          document: Faker::IdNumber.brazilian_citizen_number
        }
      end

      before do |test|
        headers = json_headers
        headers = headers.merge({ "Key-Inflection": "camel" }) if test.metadata[:inflection]

        post users_url, params: params.to_json, headers:
      end

      context "without the Key-Inflection header" do
        it "doesn't creates the entity" do
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "with the Key-Inflection header" do
        it "creates the user", :inflection do
          expect(response).to have_http_status(:created)
        end
      end
    end
  end
end
