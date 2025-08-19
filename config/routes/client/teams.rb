namespace :teams, defaults: { format: :json } do
  namespace :reports do
    resources :affiliations, only: :index

    resources :affiliate_logs, only: [] do
      get :sales_summary, on: :collection
    end

    resources :affiliates, only: nil do
      collection do
        get :inactive
        get :performance
        post :download_inactive
        post :download_performance
      end
    end

    resources :network_offers, only: [] do
      get :campaign_count, on: :collection
    end

    resources :referrals, only: :index do
      get :details, on: :collection
    end

    resources :stat_summaries, only: :index do
      collection do
        post :download
        get :top_performers
        get :delta_summary
        get :overview
      end
    end

    resources :stats, only: [] do
      get :channel_summary, on: :collection
    end

    resources :tasks, only: [:index]
  end

  resources :ad_slots, only: [:index, :create, :update]

  resources :advertiser_balances, only: [:index, :create, :update] do
    collection do
      post :download
      get :remaining
      post :download_remaining
      post :import
    end
  end

  resources :affiliates, only: [:index, :create, :update, :show] do
    collection do
      get :search
      get :overview
      post :download
      post :bulk_update
    end

    post :generate_auto_auth_token, on: :member
  end

  resources :affiliate_feeds, only: [:index, :create, :update, :destroy]

  resources :affiliate_logs, only: :create do
    get :sales_logs, on: :collection
  end

  resources :affiliate_offers, only: [:index, :create, :update] do
    post :bulk_update, on: :collection
    post :generate_url, on: :member
  end

  resources :affiliate_payments, only: [:index, :create, :update] do
    collection do
      post :bulk_edit
      post :bulk_delete
      post :download
      post :import
      post :create_proposal
    end
  end

  resources :affiliate_prospects, only: [:index, :create, :update, :destroy]

  resources :affiliate_payment_infos, only: [:index, :update] do
    post :download, on: :collection
  end

  resources :affiliate_payment_infos, only: :show, param: :affiliate_id

  resources :affiliate_search_logs, only: [] do
    collection do
      get :offer_summary
      get :product_summary
    end
  end

  data_types = /clicks|captured|converted|published/
  resources :affiliate_stats, only: [:show, :create, :update] do
    collection do
      get ':data_type', action: :index, data_type: data_types
      get ':data_type/recent', action: :recent, data_type: data_types
      post ':data_type/download', action: :download, data_type: data_types
      post :bulk_update
      post :fire_s2s
      post :fire_confirmed_s2s
      post :import
    end

    member do
      get :conversions
      post :calculate
    end
  end

  resources :click_abuse_reports, only: [:index] do
    get :summary, on: :collection
    post :block, on: :member
  end

  resources :postbacks, only: [:index] do
    collection do
      post :bulk_repost
      post :bulk_reflect_time
    end

    member do
      post :repost
      post :reflect_time
    end
  end

  resources :affiliate_tags, only: [:index, :create, :update, :destroy]

  resources :affiliate_users, only: [:index, :show, :create, :update] do
    get :current, on: :collection
    post :generate_auto_auth_token, on: :member
  end

  resources :alternative_domains, only: [:index, :create, :update, :destroy] do
    post :bulk_deploy, on: :collection
  end

  resources :api_keys, only: [:index, :create, :update, :destroy] do
    get :active, on: :collection
  end

  resources :app_configs, only: [:index, :create, :update, :destroy]

  resources :attachments, only: [:index, :create, :update, :destroy]

  resources :blogs, only: [:index, :create, :update] do
    get :get_sites, on: :collection
  end

  resources :blog_images, only: [:index, :create, :update, :destroy]

  resources :blog_pages, only: [:index, :create, :update]

  resources :blog_contents, only: [:index, :create, :update, :destroy]

  resources :bot_stats, only: [:index]

  resources :campaigns, only: [:index, :create, :update] do
    get :search, on: :collection
  end

  resources :category_parkings, only: :index

  resources :channels, only: [:index, :create, :update, :destroy] do
    get :search, on: :collection
  end

  resources :client_apis, only: [:index, :create, :update, :destroy] do
    post :import, on: :member
  end

  resources :contact_lists, only: [:index, :create, :update, :destroy]

  resources :chatbot_search_logs, only: [:index]

  resources :chatbot_steps, only: [:index, :create, :update, :destroy]

  resources :conversion_steps, only: [:index, :create, :update] do
    get :search, on: :collection
  end

  resources :downloads, only: [:index, :destroy]

  resources :easy_store_setups, only: [:index, :destroy]

  resources :event_affiliate_offers, only: [:index, :update, :create] do
    collection do
      post :bulk_update
      post :download
    end
  end

  resources :event_offers, only: [:index, :show, :update, :create] do
    get :search, on: :collection
    post :duplicate, on: :member
  end

  resources :faq_feeds, only: [:index, :create, :update, :destroy] do
    put :sort, on: :collection
  end

  resources :email_templates, only: [:index, :update] do
    get :types, on: :collection
  end

  resources :image_creatives, only: [:index, :create, :update, :destroy] do
    collection do
      get :search
      put :bulk_update
    end
  end

  resources :jobs, only: [:index, :destroy] do
    post :bulk_delete, on: :collection
  end

  resources :job_status_checks, only: [:index]

  resources :link_tracers, only: :index

  resources :missing_orders, only: [:index, :update]

  resources :mkt_sites, only: [:index, :create, :update, :destroy] do
    get :search, on: :collection
  end

  resources :networks, only: [:index, :show, :create, :update] do
    member do
      get :current_balance
      post :generate_auto_auth_token
      post :deliver_stat_summary
    end

    collection do
      get :search
      get :overview
      post :bulk_update
      post :download
    end
  end

  resources :network_offers, only: [:index, :update, :show, :create] do
    collection do
      get :search
      get :recent
      post :download
    end
    post :duplicate, on: :member
  end

  resources :newsletters, only: [:index, :create, :update, :destroy] do
    member do
      get :recipients
      get :preview
      post :deliver
    end
  end

  resources :offer_variants, only: [:index, :create, :update] do
    collection do
      get :search
      get :test_urls
    end
  end

  resources :orders, only: [:index, :show, :update, :create] do
    collection do
      post :finalize_cj
    end
  end

  resources :owner_has_tags, only: [:index, :create, :destroy] do
    collection do
      put :sort
    end
  end

  resource :password, only: [:create, :update] do
    post :reset
  end

  resources :pay_schedules, only: [:index, :update]

  resource :platform, only: [:update, :show]

  resources :sessions, only: :create do
    collection do
      post :create_by_token
      post :refresh_token
    end
  end

  resources :site_infos, only: [:index, :show, :create, :update, :destroy]

  resources :snippets, only: [:index, :create, :update, :destroy] do
    get :search_keys, on: :collection
  end

  resources :terms, only: [:index, :create, :update, :destroy] do
    get :search, on: :collection
  end

  resources :text_creatives, only: [:index, :create, :update, :destroy] do
    collection do
      put :bulk_update
    end
  end

  resources :traces, only: :index do
    get ':target_type/types', action: :types, on: :collection
  end

  resources :uploads, only: [:index, :create, :destroy]

  resources :popup_feeds, only: [:index, :create, :update, :destroy]

  resources :unique_view_stats, only: :index

  resources :uploads, only: [:index, :create, :destroy]
  resources :vtm_channels, only: [:index, :update]
end
