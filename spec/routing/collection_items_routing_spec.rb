require "rails_helper"

RSpec.describe CollectionItemsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/collection_items").to route_to("collection_items#index")
    end

    it "routes to #new" do
      expect(get: "/collection_items/new").to route_to("collection_items#new")
    end

    it "routes to #show" do
      expect(get: "/collection_items/1").to route_to("collection_items#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/collection_items/1/edit").to route_to("collection_items#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/collection_items").to route_to("collection_items#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/collection_items/1").to route_to("collection_items#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/collection_items/1").to route_to("collection_items#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/collection_items/1").to route_to("collection_items#destroy", id: "1")
    end
  end
end
