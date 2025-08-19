require 'faker'
require 'populator'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    task :refresh_sample_images do
      RakeWl.when_populator_can_run do
        [[300, 300]].each do |dimension|
          image_path = "#{Rails.root}/public/images/samples"
          1.upto(50).each do |idx|
            File.binwrite("#{image_path}/image-#{dimension.first}x#{dimension.last}-#{idx}.jpg", open("https://picsum.photos/#{dimension.first}/#{dimension.last}").read)
          end
        end
      end
    end
  end
end
