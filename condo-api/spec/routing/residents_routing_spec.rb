require "rails_helper"

RSpec.describe ResidentsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/apartments/1/residents").to route_to("residents#index", apartment_id: "1", format: :json)
    end

    it "routes to #show" do
      expect(get: "/residents/1").to route_to("residents#show", id: "1", format: :json)
    end

    it "routes to #create" do
      expect(post: "/apartments/1/residents").to route_to("residents#create", apartment_id: "1", format: :json)
    end

    it "routes to #update via PUT" do
      expect(put: "/apartments/1/residents/1").to route_to("residents#update", apartment_id: "1", id: "1", format: :json)
    end

    it "routes to #update via PATCH" do
      expect(patch: "/apartments/1/residents/1").to route_to("residents#update", apartment_id: "1", id: "1", format: :json)
    end

    it "routes to #destroy" do
      expect(delete: "/apartments/1/residents/1").to route_to("residents#destroy", apartment_id: "1", id: "1", format: :json)
    end
  end
end
