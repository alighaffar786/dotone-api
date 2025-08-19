require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount ActionCable.server => '/cable'

  # TODO: - Use authlogic
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      # Protect against timing attacks:
      # - See https://codahale.com/a-lesson-in-timing-attacks/
      # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
      ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(username),
        Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_WEB_USERNAME', nil))) &
        ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(password),
          Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_WEB_PASSWORD', nil)))
    end
  end
  mount Sidekiq::Web, at: '/sidekiq'

  match '/ping' => 'application#ping', as: :ping, via: :get

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api, defaults: { format: 'json' } do
    draw 'v2/all'
    draw 'client/all'

    constraints DotOne::Constraints::TrackingConstraint do
      match '/advertisers/orders/nine_one_app' => 'v2/advertisers/orders#nine_one_app', via: [:get, :post]
      match '/advertisers/orders/modify' => 'v2/advertisers/orders#modify', via: [:get, :post]
    end
  end

  namespace :client, path: '/', constraints: DotOne::Constraints::SkinDomainConstraint.new do
    get '/', to: 'pages#index'

    match '/en-us(/*path)', to: redirect { |params, _req| "/en-US/#{params[:path]}" }, via: :all
    match '/zh-tw(/*path)', to: redirect { |params, _req| "/zh-TW/#{params[:path]}" }, via: :all

    scope '/:locale', locale: /en-US|zh-TW/ do
      get '/', to: 'pages#home', as: :home
      get '/affiliates', to: 'pages#affiliates', as: :affiliates
      get '/events', to: 'pages#events', as: :events
      get '/advertisers', to: 'pages#advertisers', as: :advertisers
      get '/agencies', to: 'pages#agencies', as: :agencies

      resources :blogs, path: :blog, only: :index do
        collection do
          get '/post/s-:slug', to: 'blogs#show', as: :post
          get '/search', to: 'blogs#index', as: :search
          get '/tag/tag-:slug', to: 'blogs#tag', as: :tag
          get '/page/p-:slug', to: 'blogs#page', as: :page
          get '/author/a-:slug', to: 'blogs#author', as: :author
        end
      end
    end
  end

  get 'r/:campaign_id', to: 'track/clicks#campaign', as: :campaign

  draw 'track/all'
  draw 'track/js'
  draw 'public/all'
end
