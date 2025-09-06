require 'rails_helper'

RSpec.describe "Condominia", type: :request do
  describe "GET /index" do
    before do
      get condominia_url
    end

    it "returns a list of condominium" do
      json_response = JSON.parse(response.body)

      expect(json_response).to be_an(Array)
    end
  end
end
