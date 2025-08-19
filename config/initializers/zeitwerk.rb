Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    'omniauth' => 'OmniAuth',
  )
end
