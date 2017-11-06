Bybeconv::Application.routes.draw do
  get 'realizers/remove'

  get 'creations/add'

  get 'creations/remove'

  get 'admin/index'
  get 'admin/missing_languages'
  get 'admin/volunteer_profiles_list'
  get 'admin/volunteer_profile/new' => 'admin#volunteer_profile_new', as: 'volunteer_profile_new'
  post 'admin/volunteer_profile/create' => 'admin#volunteer_profile_create', as: 'volunteer_profile_create'
  get 'admin/volunteer_profile/edit/:id' => 'admin#volunteer_profile_edit', as: 'volunteer_profile_edit'
  patch 'admin/volunteer_profile/update' => 'admin#volunteer_profile_update', as: 'volunteer_profile_update'
  post 'admin/volunteer_profile/add_feature' => 'admin#volunteer_profile_add_feature', as: 'volunteer_profile_add_feature'
  get 'admin/volunteer_profile/delete_feature/:id' => 'admin#volunteer_profile_delete_feature', as: 'volunteer_profile_delete_feature'
  get 'admin/volunteer_profile/:id' => 'admin#volunteer_profile_show', as: 'volunteer_profile_show'
  get 'admin/featured_content_list'
  get 'admin/featured_content/new' => 'admin#featured_content_new', as: 'featured_content_new'
  post 'admin/featured_content/create' => 'admin#featured_content_create', as: 'featured_content_create'
  get 'admin/featured_content/edit/:id' => 'admin#featured_content_edit', as: 'featured_content_edit'
  patch 'admin/featured_content/update' => 'admin#featured_content_update', as: 'featured_content_update'
  post 'admin/featured_content/add_feature' => 'admin#featured_content_add_feature', as: 'featured_content_add_feature'
  get 'admin/featured_content/delete_feature/:id' => 'admin#featured_content_delete_feature', as: 'featured_content_delete_feature'
  get 'admin/featured_content/:id' => 'admin#featured_content_show', as: 'featured_content_show'
  get 'autocomplete_manifestation_title' => 'admin#autocomplete_manifestation_title', as: 'autocomplete_manifestation_title'
  get 'autocomplete_person_name' => 'admin#autocomplete_person_name', as: 'autocomplete_person_name'

  get "search/index"
  get "search/results"
  get "search/advanced"
  get "authors/index"
  get "authors/show"
  get "authors/new", as: 'authors_new'
  get "authors/edit"
  match "authors/list", via: [:get, :post]
  get "authors/print"
  post "authors/update"
  get "authors/destroy", as: 'authors_destroy'
  post "authors/create"
  patch "authors/update"
  get 'authors/get_random_author'
  match 'author/:id/edit_toc' => 'authors#edit_toc', as: 'authors_edit_toc', via: [:get, :post]

  get "read/:id" => 'manifestation#read', as: 'manifestation_read'
  get "read/:id/read" => 'manifestation#readmode', as: 'manifestation_readmode'
  get 'works' => 'manifestation#works', as: 'works'
  get 'whatsnew' => 'manifestation#whatsnew', as: 'whatsnew'
  match 'author/:id' => 'authors#toc', as: 'author_toc', via: [:get, :post]
  match "download/:id" => 'manifestation#download', as: 'manifestation_download', via: [:get, :post]
  match "print/:id" => 'manifestation#print', as: 'manifestation_print', via: [:get, :post]
  get "manifestation/show/:id" => 'manifestation#show', as: 'manifestation_show'
  get "manifestation/render_html"
  get "manifestation/edit/:id" => 'manifestation#edit', as: 'manifestation_edit'
  get "manifestation/edit_metadata/:id" => 'manifestation#edit_metadata', as: 'manifestation_edit_metadata'
  match "manifestation/list", via: [:get, :post]
  get "manifestation/genre" => 'manifestation#genre', as: 'manifestation_genre'
  get "manifestation/index", as: 'manifestation_index'
  get "manifestation/remove_link"
  post "manifestation/update"
  patch "manifestation/update"
  get 'manifestation/get_random'

  get "api/query"
  resources :api_keys

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
  match "html_dirs/:id/guess_author" => 'html_dirs#guess_author', via: [:get, :post]
  match "html_dirs/:id/associate_viaf" => 'html_dirs#associate_viaf', as: 'html_dirs_associate_viaf', via: [:get, :post]

  get "proof/list"
  get "proof/purge" => 'proof#purge', as: 'proof_purge'
  get "proof/:id/resolve" => 'proof#resolve', as: 'proof_resolve'
  resources :proof

  get "recommendation/list"
  get "recommendation/purge" => 'recommendation#purge', as: 'recommendation_purge'
  match "recommendation/:id/resolve" => 'recommendation#resolve', as: 'recommendation_resolve', via: [:get, :post]
  resources :recommendation

  get "html_file/analyze"
  match "html_file/:id/edit" => 'html_file#edit', as: 'html_file_edit', via: [:get, :post]
  post "html_file/:id/update" => 'html_file#update'
  match "html_file/:id/confirm_html_dir_person" => 'html_file#confirm_html_dir_person', as: 'html_file_confirm_html_dir_person', via: [:get, :post]
  get "html_file/analyze_all"
  match "html_file/:id/frbrize" => 'html_file#frbrize', as: 'html_file_frbrize', via: [:get]

  get "html_file/list"
  get "html_file/list_for_editor"
  get "html_file/publish"
  post "html_file/list"
  get "html_file/publish"
  get "html_file/parse"
  get "html_file/render_html"
  post "html_file/render_html"
  get "html_file/unsplit"
  get "html_file/chop1"
  get "html_file/choplast1"
  get "html_file/chop2"
  get "html_file/choplast2"
  get "html_file/chop3"
  get "html_file/chop_title"
  get "html_file/poetry"
  get 'html_file/mark_manual'

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
  match '*path' => "html_file#render_by_legacy_url", via: [:get]
end
