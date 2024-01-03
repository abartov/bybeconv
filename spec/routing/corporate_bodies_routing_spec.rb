require "rails_helper"

RSpec.describe CorporateBodiesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/corporate_bodies").to route_to("corporate_bodies#index")
    end

    it "routes to #new" do
      expect(get: "/corporate_bodies/new").to route_to("corporate_bodies#new")
    end

    it "routes to #show" do
      expect(get: "/corporate_bodies/1").to route_to("corporate_bodies#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/corporate_bodies/1/edit").to route_to("corporate_bodies#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/corporate_bodies").to route_to("corporate_bodies#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/corporate_bodies/1").to route_to("corporate_bodies#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/corporate_bodies/1").to route_to("corporate_bodies#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/corporate_bodies/1").to route_to("corporate_bodies#destroy", id: "1")
    end
  end
end
