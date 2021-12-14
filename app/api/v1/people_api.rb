class V1::PeopleAPI < V1::ApplicationApi
  resources :people do
    route_param :id do
      desc 'Return person by id' do
        success V1::Entities::Person
      end
      params do
        use :key_param
        requires :id, type: Integer, desc: 'Person ID'
        optional :author_detail, type: String, default: 'metadata', values: %w(metadata texts enriched), desc: <<~DESC
          how much detail to return:
          `metadata` returns personal metadata;
          `texts` returns IDs of texts this person was involved in, with his role in each; 
          `enriched` returns personal metadata plus works about this person (backlinks); 
        DESC
      end
      get do
        person = Person.find(params[:id])
        present person, with: V1::Entities::Person, detail: params[:author_detail]
      end
    end
  end
end