require 'rails_helper'

RSpec.describe "Condominia", type: :request do
  include_context "json_requests"

  describe "GET /condominia" do
    before do
      get condominia_url, headers: json_headers
    end

    describe "when unauthenticated" do
      it "should returns success" do
        expect(response).to have_http_status(200)
      end
      it "returns a list of condominium" do
        json_response = JSON.parse(response.body)

        expect(json_response).to be_kind_of(Array)
      end
    end
  end
  describe "POST /condiminia" do
    describe "when unauthenticated" do
      let(:condo_1) { FactoryBot.build(:condominium) }

      it "should be forbidden" do
        post condominia_url, params: { condominium: condo_1 }, as: :json

        expect(response).to have_http_status(401)
      end
    end
  end
end
