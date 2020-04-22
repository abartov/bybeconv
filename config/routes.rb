include BybeUtils
Bybeconv::Application.routes.draw do
  resources :anthology_texts do
    post 'mass_create', on: :collection
  end

  resources :anthologies
  match "anthologies/print/:id" => 'anthologies#print', as: 'anthology_print', via: [:get, :post]
  match "anthologies/download/:id" => 'anthologies#download', as: 'anthology_download', via: [:get, :post]
  match "anthologies/seq/:id" => 'anthologies#seq', as: 'anthology_seq', via: [:get, :post]
  match "anthologies/clone/:id" => 'anthologies#clone', as: 'anthology_clone', via: [:get]

  resources :news_items
  resources :mooses
  resources :bib_sources
  resources :holdings
  resources :publications
  get 'bib/index'
  get 'bib/scans' => 'bib#scans', as: 'bib_scans'
  get 'bib/person/:person_id' => 'bib#person', as: 'bib_person'
  match 'bib/pubs_by_person', via: [:get, :post]

  get 'bib/todo_by_location'
  get 'bib/holding_status/:id' => 'bib#holding_status', as: 'holding_status'
  post 'bib/make_author_page'
  match 'bib/shopping/:source_id' => 'bib#shopping', as: 'bib_shopping', via: [:get, :post]

  get 'aboutnesses/remove'

  get 'static_pages/render'

  get 'realizers/remove'

  get 'creations/add'
  get 'creations/remove'

  get 'admin/index'
  get 'admin/missing_languages'
  get 'admin/missing_genres'
  get 'admin/missing_copyright'
  get 'admin/missing_images'
  get 'admin/messy_tocs'
  get 'admin/tocs_missing_links'
  get 'admin/incongruous_copyright'
  get 'admin/suspicious_headings'
  get 'admin/similar_titles'
  get 'admin/periodless'
  get 'admin/suspicious_translations'
  get 'admin/mark_similar_as_valid/:id' => 'admin#mark_similar_as_valid', as: 'mark_similar_as_valid'
  get 'admin/translated_from_multiple_languages'
  get 'admin/raw_tocs'
  get 'admin/my_convs/:id' => 'admin#my_convs', as: 'my_convs'
  get 'admin/conversion_verification'
  get 'admin/assign_conversion_verification' => 'admin#assign_conversion_verification', as: 'assign_conversion_verification'
  get 'admin/assign_proofs' => 'admin#assign_proofs', as: 'assign_proofs'
  get 'admin/static_pages_list'
  get 'admin/static_page/new' => 'admin#static_page_new', as: 'static_page_new'
  post 'admin/static_page/create' => 'admin#static_page_create', as: 'static_page_create'
  get 'admin/static_page/edit/:id' => 'admin#static_page_edit', as: 'static_page_edit'
  patch 'admin/static_page/update' => 'admin#static_page_update', as: 'static_page_update'
  get 'admin/static_page/:id' => 'admin#static_page_show', as: 'static_page_show'
  get 'admin/volunteer_profiles_list'
  get 'admin/volunteer_profile/new' => 'admin#volunteer_profile_new', as: 'volunteer_profile_new'
  post 'admin/volunteer_profile/create' => 'admin#volunteer_profile_create', as: 'volunteer_profile_create'
  get 'admin/volunteer_profile/edit/:id' => 'admin#volunteer_profile_edit', as: 'volunteer_profile_edit'
  patch 'admin/volunteer_profile/update' => 'admin#volunteer_profile_update', as: 'volunteer_profile_update'
  post 'admin/volunteer_profile/add_feature' => 'admin#volunteer_profile_add_feature', as: 'volunteer_profile_add_feature'
  get 'admin/volunteer_profile/delete_feature/:id' => 'admin#volunteer_profile_delete_feature', as: 'volunteer_profile_delete_feature'
  get 'admin/volunteer_profile/:id' => 'admin#volunteer_profile_show', as: 'volunteer_profile_show'
  get 'admin/volunteer_profile/destroy/:id' => 'admin#volunteer_profile_destroy', as: 'volunteer_profile_destroy'
  get 'admin/featured_content_list'
  get 'admin/featured_content/new' => 'admin#featured_content_new', as: 'featured_content_new'
  post 'admin/featured_content/create' => 'admin#featured_content_create', as: 'featured_content_create'
  get 'admin/featured_content/edit/:id' => 'admin#featured_content_edit', as: 'featured_content_edit'
  patch 'admin/featured_content/update' => 'admin#featured_content_update', as: 'featured_content_update'
  post 'admin/featured_content/add_feature' => 'admin#featured_content_add_feature', as: 'featured_content_add_feature'
  get 'admin/featured_content/delete_feature/:id' => 'admin#featured_content_delete_feature', as: 'featured_content_delete_feature'
  get 'admin/featured_content/:id' => 'admin#featured_content_show', as: 'featured_content_show'
  get 'admin/featured_content/destroy/:id' => 'admin#featured_content_destroy', as: 'featured_content_destroy'
  get 'autocomplete_manifestation_title' => 'admin#autocomplete_manifestation_title', as: 'autocomplete_manifestation_title'
  get 'autocomplete_person_name' => 'admin#autocomplete_person_name', as: 'autocomplete_person_name'
  get 'autocomplete_tag_name' => 'manifestation#autocomplete_tag_name', as: 'autocomplete_tag_name'
  get 'admin/featured_author_list'
  get 'admin/featured_author/new' => 'admin#featured_author_new', as: 'featured_author_new'
  post 'admin/featured_author/create' => 'admin#featured_author_create', as: 'featured_author_create'
  get 'admin/featured_author/edit/:id' => 'admin#featured_author_edit', as: 'featured_author_edit'
  patch 'admin/featured_author/update' => 'admin#featured_author_update', as: 'featured_author_update'
  get 'admin/featured_author/destroy/:id' => 'admin#featured_author_destroy', as: 'featured_author_destroy'
  post 'admin/featured_author/add_feature' => 'admin#featured_author_add_feature', as: 'featured_author_add_feature'
  get 'admin/featured_author/delete_feature/:id' => 'admin#featured_author_delete_feature', as: 'featured_author_delete_feature'
  get 'admin/featured_author/:id' => 'admin#featured_author_show', as: 'featured_author_show'
  get 'admin/sitenotice_list'
  get 'admin/sitenotice/new' => 'admin#sitenotice_new', as: 'sitenotice_new'
  post 'admin/sitenotice/create' => 'admin#sitenotice_create', as: 'sitenotice_create'
  get 'admin/sitenotice/edit/:id' => 'admin#sitenotice_edit', as: 'sitenotice_edit'
  patch 'admin/sitenotice/update' => 'admin#sitenotice_update', as: 'sitenotice_update'
  get 'admin/sitenotice/destroy/:id' => 'admin#sitenotice_destroy', as: 'sitenotice_destroy'
  get 'admin/sitenotice/:id' => 'admin#sitenotice_show', as: 'sitenotice_show'
  get 'volunteer/:id' => 'user#show', as: 'volunteer_show'

  get '/search_results' => 'application#search_results'
  get "search/index"
  get '/mobile_search' => 'application#mobile_search'
  match "search/results", via: [:get, :post], as: 'search_results_internal'
  get "search/advanced"
  get 'authors/all', as: 'all_authors'
  get 'authors/genre'
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
  match 'author/:id/create_toc' => 'authors#create_toc', as: 'authors_create_toc', via: [:get]
  get '/page/:tag' => 'static_pages#view', as: 'static_pages_by_tag', via: [:get]
  get "read/:id" => 'manifestation#read', as: 'manifestation_read'
  get "read/:id/read" => 'manifestation#readmode', as: 'manifestation_readmode'
  get 'periods' => 'manifestation#periods', as: 'periods'
  match 'works', to: 'manifestation#browse', as: 'works', via: [:get, :post]
  match 'works/all', to: 'manifestation#all', as: 'all_works', via: [:get, :post]
  match 'manifestation/genre' => 'manifestation#genre', as: 'genre', via: [:get, :post]
  match 'period/:period' => 'manifestation#period', as: 'period', via: [:get, :post]
  match 'translations' => 'manifestation#translations', as: 'translations', via: [:get, :post]
  get 'whatsnew' => 'manifestation#whatsnew', as: 'whatsnew'
  match 'tag/:id' => 'manifestation#by_tag', as: 'tag', via: [:get, :post]
  match 'author/:id' => 'authors#toc', as: 'author_toc', via: [:get, :post]
  match "download/:id" => 'manifestation#download', as: 'manifestation_download', via: [:get, :post]
  match "print/:id" => 'manifestation#print', as: 'manifestation_print', via: [:get, :post]
  get "manifestation/show/:id" => 'manifestation#show', as: 'manifestation_show'
  get "manifestation/render_html"
  get "manifestation/edit/:id" => 'manifestation#edit', as: 'manifestation_edit'
  get "manifestation/remove_image/:id" => 'manifestation#remove_image'
  get "manifestation/edit_metadata/:id" => 'manifestation#edit_metadata', as: 'manifestation_edit_metadata'
  match "manifestation/list", via: [:get, :post]
  get "manifestation/genre" => 'manifestation#genre', as: 'manifestation_genre'
  get "manifestation/index", as: 'manifestation_index'
  get "manifestation/remove_link"
  post "manifestation/update"
  patch "manifestation/update"
  post "manifestation/add_images"
  get 'manifestation/get_random'
  get 'manifestation/like'
  get 'manifestation/unlike'
  get 'manifestation/surprise_work'
  get 'manifestation/autocomplete_works_by_author'
  get 'work/show/:id' => 'manifestation#workshow', as: 'work_show' # temporary, until we have a works controller
  get 'manifestation/add_aboutnesses/:id' => 'manifestation#add_aboutnesses'

  get "api/query"
  resources :api_keys
  get "taggings/render_tags"
  resources :taggings
  resources :aboutnesses

  match 'user/list', via: [:get, :post]
  post 'user/set_editor_bit'
  get "user/:id/make_editor" => 'user#make_editor', as: 'user_make_editor'
  get "user/:id/make_admin" => 'user#make_admin', as: 'user_make_admin'
  get "user/:id/unmake_editor" => 'user#unmake_editor', as: 'user_unmake_editor'
  get 'user/:id' => 'user#show', as: 'user_show'
  post 'user/set_pref'
  get "welcome/index"

  get "session/create"
  get "session/destroy"
  get "session/login"
  get 'session/dismiss_sitenotice'
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

  get "legacy_recommendation/list"
  get "legacy_recommendation/purge" => 'legacy_recommendation#purge', as: 'legacy_recommendation_purge'
  match "legacy_recommendation/:id/resolve" => 'legacy_recommendation#resolve', as: 'legacy_recommendation_resolve', via: [:get, :post]
  resources :legacy_recommendations
  resources :recommendations

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
  get 'html_file/new'
  get 'html_file/mark_superseded'
  match 'html_file/edit_markdown', via: [:get, :post]
  post 'html_file/create'
  get 'html_file/destroy'
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
  # match legacy BY urls, but *only* those
  match '*path' => "html_file#render_by_legacy_url", via: [:get], constraints: lambda {|req|
    is_legacy_url(req.path)
  }
end
