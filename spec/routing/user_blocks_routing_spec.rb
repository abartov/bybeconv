require "rails_helper"

RSpec.describe UserBlocksController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/user_blocks").to route_to("user_blocks#index")
    end

    it "routes to #new" do
      expect(get: "/user_blocks/new").to route_to("user_blocks#new")
    end

    it "routes to #show" do
      expect(get: "/user_blocks/1").to route_to("user_blocks#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/user_blocks/1/edit").to route_to("user_blocks#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/user_blocks").to route_to("user_blocks#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/user_blocks/1").to route_to("user_blocks#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/user_blocks/1").to route_to("user_blocks#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/user_blocks/1").to route_to("user_blocks#destroy", id: "1")
    end
  end
end
