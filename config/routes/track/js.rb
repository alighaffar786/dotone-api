constraints DotOne::Constraints::JsTrackingConstraint do
  namespace :track do
    with_options via: [:get, :post] do |opt|
      opt.match "imp/mkt_site/:wl_id/:mkt_site_id" => "impressions#mkt_site", as: :mkt_site

      opt.match 'slot' => 'ad_slots#index', as: :ad_slot
    end
  end
end
