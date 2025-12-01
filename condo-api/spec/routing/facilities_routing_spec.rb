require "rails_helper"

RSpec.describe FacilitiesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/condominia/1/facilities").to route_to("facilities#index", condominium_id: '1', format: :json)
    end

    it "routes to #show" do
      expect(get: "/facilities/1").to route_to("facilities#show", id: "1", format: :json)
    end


    it "routes to #create" do
      expect(post: "/condominia/1/facilities").to route_to("facilities#create", condominium_id: '1', format: :json)
    end

    it "routes to #update via PUT" do
      expect(put: "/facilities/1").to route_to("facilities#update", id: "1", format: :json)
    end

    it "routes to #update via PATCH" do
      expect(patch: "/facilities/1").to route_to("facilities#update", id: "1", format: :json)
    end

    it "routes to #destroy" do
      expect(delete: "/facilities/1").to route_to("facilities#destroy", id: "1", format: :json)
    end
  end
end
