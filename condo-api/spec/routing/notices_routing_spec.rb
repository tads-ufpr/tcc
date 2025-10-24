require "rails_helper"

RSpec.describe NoticesController, type: :routing do
  describe "routing" do
    describe "nested /condominia routes" do
      it "routes to #index" do
        expect(get: "/condominia/1/notices").to route_to("notices#index", condominium_id: '1')
      end
    end

    describe "nested /apartment routes" do
      it "routes to #index" do
        expect(get: "/apartments/1/notices").to route_to("notices#index", apartment_id: '1')
      end

      it "routes to #create" do
        expect(post: "/apartments/1/notices").to route_to("notices#create", apartment_id: '1')
      end
    end

    it "routes to #update via PUT" do
      expect(put: "/notices/1").to route_to("notices#update", id: '1')
    end

    it "routes to #update via PATCH" do
      expect(patch: "/notices/1").to route_to("notices#update", id: '1')
    end

    it "routes to #destroy" do
      expect(delete: "/notices/1").to route_to("notices#destroy", id: '1')
    end
  end
end
