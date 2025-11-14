require "rails_helper"

RSpec.describe ApartmentsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "condominia/1/apartments").to route_to("apartments#index", condominium_id: "1")
    end

    it "routes to #show" do
      expect(get: "/apartments/1").to route_to("apartments#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "condominia/1/apartments").to route_to("apartments#create", condominium_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/apartments/1").to route_to("apartments#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/apartments/1").to route_to("apartments#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/apartments/1").to route_to("apartments#destroy", id: "1")
    end
  end
end
