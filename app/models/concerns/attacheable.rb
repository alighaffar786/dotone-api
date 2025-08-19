module Attacheable
  extend ActiveSupport::Concern

  module ClassMethods
    def attachment_attrs(*args)
      args.each do |arg|
        define_method "#{arg}_filename" do
          send(arg).file.try(:filename) || 'Unknown.jpg'
        end

        define_method "#{arg}_data" do
          open(send("#{arg}_url")).read rescue nil
        end

        define_method "download_#{arg}" do |dir_path|
          return unless data = send("#{arg}_data")

          tempfile = File.join(dir_path, send("#{arg}_filename"))
          File.binwrite(tempfile, data)
          tempfile
        end
      end
    end
  end
end
