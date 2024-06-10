require "rails_helper"

RSpec.describe IngestiblesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/ingestibles").to route_to("ingestibles#index")
    end

    it "routes to #new" do
      expect(get: "/ingestibles/new").to route_to("ingestibles#new")
    end

    it "routes to #show" do
      expect(get: "/ingestibles/1").to route_to("ingestibles#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/ingestibles/1/edit").to route_to("ingestibles#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/ingestibles").to route_to("ingestibles#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/ingestibles/1").to route_to("ingestibles#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/ingestibles/1").to route_to("ingestibles#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/ingestibles/1").to route_to("ingestibles#destroy", id: "1")
    end
  end
end
