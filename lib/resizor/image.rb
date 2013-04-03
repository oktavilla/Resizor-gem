require "date"

module Resizor
  class Image
    attr_accessor :id, :name, :extension, :mime_type,
                  :width, :height, :file_size

    attr_reader :created_at, :attributes

    def initialize attrs
      self.attributes = attrs
    end

    def filename
      "#{name}.#{extension}"
    end

    def attributes= attrs
      attrs = attrs.reject {|key, value| !self.respond_to? "#{key}=" }
      attrs.each do |key, value|
        self.public_send("#{key}=", value)
      end

      @attributes = attrs
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
