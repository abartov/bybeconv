# frozen_string_literal: true

module V1
  # Endpoint to retrieve information about Authorities (people and corporate bodies)
  class AuthoritiesAPI < V1::ApplicationApi
    resources :authorities do
      route_param :id do
        desc 'Return Authority by ID' do
          success V1::Entities::Authority
        end
        params do
          use :key_param
          requires :id, type: Integer, desc: 'Authority ID'
          optional :author_detail, type: String, default: 'metadata', values: %w(metadata texts enriched), desc: <<~DESC
            how much detail to return:
            `metadata` returns metadata;
            `texts` returns IDs of texts this authority was involved in, with its role in each;#{' '}
            `enriched` returns metadata plus works about this authority (backlinks);#{' '}
          DESC
        end
        get do
          authority = Authority.find(params[:id])
          present authority, with: V1::Entities::Authority, detail: params[:author_detail]
        end
      end
    end
  end
end
