
require "rails_helper"

RSpec.describe EmployeesController, type: :routing do
  describe "routing" do
    describe "nested /condominia routes" do
      it "routes to #index" do
        expect(get: "/condominia/1/employees").to route_to("employees#index", condominium_id: '1')
      end

      it "routes to #create" do
        expect(post: "/condominia/1/employees").to route_to("employees#create", condominium_id: '1')
      end
    end

    it "routes to #update via PUT" do
      expect(put: "/employees/1").to route_to("employees#update", id: '1')
    end

    it "routes to #update via PATCH" do
      expect(patch: "/employees/1").to route_to("employees#update", id: '1')
    end

    it "routes to #destroy" do
      expect(delete: "/employees/1").to route_to("employees#destroy", id: '1')
    end
  end
end
