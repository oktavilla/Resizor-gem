module Resizor
  class ImageCollection
    include Enumerable
    attr_reader :total_pages, :current_page, :total_images, :images

    def initialize attrs
      self.images = attrs.fetch "images", []
      self.attributes = attrs
    end

    def attributes= attrs
      @total_pages = attrs.fetch "total_pages", 0
      @current_page = attrs.fetch "current_page", 0
      @total_images = attrs.fetch "total_images", 0
    end

    def images= images
      @images = images.map do |attrs|
        Image.new attrs
      end
    end

    def each &block
      images.each &block
    end
  end
end
