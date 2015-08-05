Bybeconv::Application.routes.draw do
  get "user/list"
  get "user/:id/make_editor" => 'user#make_editor', as: 'user_make_editor'
  get "user/:id/make_admin" => 'user#make_admin', as: 'user_make_admin'
  get "user/:id/unmake_editor" => 'user#unmake_editor', as: 'user_unmake_editor'

  get "welcome/index"

  get "session/create"
  get "session/destroy"
  get "session/login"
  post "session/do_login"

  match '/auth/:provider/callback', to: 'session#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'session#destroy', as: 'signout', via: [:get, :post]

  resources :html_dirs

  get "proof/list"
  get "proof/purge" => 'proof#purge', as: 'proof_purge'
  get "proof/:id/resolve" => 'proof#resolve', as: 'proof_resolve'
  resources :proof

  get "recommendation/list"
  get "recommendation/purge" => 'recommendation#purge', as: 'recommendation_purge'
  get "recommendation/:id/resolve" => 'recommendation#resolve', as: 'recommendation_resolve'
  resources :recommendation

  get "html_file/analyze"
  match "html_file/:id/edit" => 'html_file#edit', as: 'html_file_edit', via: [:get, :post]
  post "html_file/:id/update" => 'html_file#update'
  get "html_file/analyze_all"

  get "html_file/list"
  match "html_file/list_for_editor"
  get "html_file/publish"
  post "html_file/list"
  get "html_file/parse"
  get "html_file/render_html"
  post "html_file/render_html"
  get "html_file/unsplit"
  get "html_file/chop1"
  get "html_file/chop2"
  get "html_file/chop3"
  get "html_file/poetry"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  #
  # match legacy BY urls
  match '*path' => "html_file#render_by_legacy_url"
end
