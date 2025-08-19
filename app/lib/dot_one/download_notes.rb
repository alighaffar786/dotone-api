module DotOne::DownloadNotes
  def self.create(klass, params)
    generator_klass = begin
      "DotOne::DownloadNotes::#{klass.name}Note".constantize
    rescue NameError
      Default
    end

    generator_klass.new(params)
  end
end
