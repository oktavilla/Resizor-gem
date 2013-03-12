require "date"

module Resizor
  class Image
    attr_accessor :id, :name, :extension, :mime_type,
                  :width, :height, :file_size

    attr_reader :created_at

    def initialize attrs = {}
      self.attributes = attrs
    end

    def filename
      "#{name}.#{extension}"
    end

    def attributes= attrs
      attrs.each do |k, v|
        self.public_send("#{k}=", v) if self.respond_to? "#{k}="
      end
    end

    def created_at= time
      if time.kind_of? Time
        @created_at = time
      else
        @created_at = DateTime.parse(time).to_time
      end
    end
  end
end
