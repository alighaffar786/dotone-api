require 'erb'

namespace :wl do
  namespace :server do
    task :cp_nginx, [:server_type] => :environment do |t, args|
      server_type = args[:server_type]
      raise "Please provide a server type (WEB or TRACK)" if server_type.nil? || ['TRACK', 'WEB'].exclude?(server_type)

      server_names = {
        'TRACK' => [DotOne::Setup.tracking_host, DotOne::Setup.advertiser_api_host, DotOne::Setup.affiliate_api_host],
        'WEB' => [DotOne::Setup.client_api_host, ENV.fetch('HOST')]
      }

      available_paths = {
        'TRACK' => ['/ping', '/sidekiq', '/track', '/api/v2', '/terminal', 'test', '/robots.txt'],
        'WEB' => ['/ping', '/api/client', '/r']
      }

      disabled_paths = {
        'TRACK' => [],
        'WEB' => []
      }

      params = {
        app_path: '/var/www/dotone-api',
        server_type: server_type,
        server_names: server_names[server_type],
        available_paths: available_paths[server_type],
        disabled_paths: disabled_paths[server_type],
      }

      template_path = Rails.root.join('lib', 'templates', 'nginx.conf')
      destination_path = '/etc/nginx/sites-available/default.conf'

      template = File.read(template_path)
      result = ERB.new(template).result_with_hash(params)

      File.open(destination_path, 'w') do |file|
        file.write(result)
      end

      puts "Nginx configuration file created at #{destination_path}"
    end
  end
end
