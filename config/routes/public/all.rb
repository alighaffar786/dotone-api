namespace :public, constraints: DotOne::Constraints::PublicConstraint do
  resource :mailer, only: [] do
    post :contact, on: :collection
  end
  resources :event_offers, only: :index
end
