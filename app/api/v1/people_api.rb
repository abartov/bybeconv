class V1::PeopleAPI < V1::ApplicationApi
  resources :people do
    route_param :id do
      desc 'Return person by id' do
        success V1::Entities::Person
      end
      params do
        use :key_param
        requires :id, type: Integer, desc: 'Person ID'
        optional :authorDetail, type: String, default: 'metadata', values: %w(metadata enriched works original_works translations full), desc: <<~DESC
          how much detail to return:
          `metadata` returns personal metadata; 
          `enriched` returns personal metadata plus works about this person (backlinks); 
          `works` returns a list of IDs of this works this person was involved in, with their role in each; 
          `original_works` returns that list filtered only to works where this person is the original author; 
          `translations` returns the works list filtered only to works where this person translated; 
          `full` returns enriched metadata plus all works'
        DESC
      end
      get do
        person = Person.find(params[:id])
        present person, with: V1::Entities::Person, detail: params[:authorDetail]
      end
    end
  end
end