require "rails_helper"

RSpec.describe InvolvedAuthoritiesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/involved_authorities").to route_to("involved_authorities#index")
    end

    it "routes to #new" do
      expect(get: "/involved_authorities/new").to route_to("involved_authorities#new")
    end

    it "routes to #show" do
      expect(get: "/involved_authorities/1").to route_to("involved_authorities#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/involved_authorities/1/edit").to route_to("involved_authorities#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/involved_authorities").to route_to("involved_authorities#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/involved_authorities/1").to route_to("involved_authorities#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/involved_authorities/1").to route_to("involved_authorities#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/involved_authorities/1").to route_to("involved_authorities#destroy", id: "1")
    end
  end
end
