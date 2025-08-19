namespace :aws do
  task go_live: :environment do
    raise 'Not the correct server type.' unless ['WEB', 'TRACK'].include?(SERVER_TYPE)

    aws = DotOne::Aws::Worker.new
    aws.go_live!
  end
end
