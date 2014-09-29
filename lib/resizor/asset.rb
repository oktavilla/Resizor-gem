module Resizor
  class ResizorAsset
    attr_accessor :id, :name, :mime_type, :size, :width, :height, :path

    def initialize(options={})
      options.each { |k,v| send "#{k}=".to_sym, v }
    end

    def url(options={})
      options = {:size => '200', :format => 'jpg', :cdn_host => !Resizor.cdn_host.nil?}.merge(options)
      options[:cdn_host] ? cdn_compatible_url(options) : query_string_url(options)
    end


    def resize_token_for(options={})
      options = {:size => '200', :format => 'jpg'}.merge(options)
      Digest::SHA1.hexdigest("#{Resizor.api_key}-#{id}-#{options[:size]}-#{options[:format]}")
    end

    def save_to_resizor(params = {})
      if path && File.exists?(path)
        ret = Resizor.post('/assets.json', params.merge(:file => File.open(path, 'rb')))
        if ret.code == 201
          @id = ret.body['asset']['id']
          @name = "#{ret.body['asset']['name']}.#{ret.body['asset']['extension']}"
          @mime_type = ret.body['asset']['mime_type']
          @size = ret.body['asset']['file_size']
          @width = ret.body['asset']['width']
          @height = ret.body['asset']['height']
        else
          return false
        end
      end
      return true
    end

    def destroy
      if id && id.to_s != ''
        ret = Resizor.delete("/assets/#{id}.json")
        if ret.code == 200
         return true
        end
      end
    end

  private

    def query_string_url(options={})
      "#{Resizor.api_url(true)}/assets/#{id}.#{options[:format]}?size=#{options[:size]}#{"&cutout="+options[:cutout] if options[:cutout]}&token=#{resize_token_for(options)}"
    end

    def cdn_compatible_url(options={})
      "//#{Resizor.cdn_host}/assets/#{options[:size]}#{"/"+options[:cutout] if options[:cutout]}/#{resize_token_for(options)}/#{id}.#{options[:format]}"
    end

  end

  class AttachedResizorAsset < Resizor::ResizorAsset

    attr_accessor :attachment_name, :instance, :file

    def initialize(attachment_name, instance, options = {})
      @attachment_name = attachment_name
      @instance = instance
      @options = options
      @id = instance_read("resizor_id")
      @name = instance_read("name")
      @mime_type = instance_read("mime_type")
      @size = instance_read("size")
      @width = instance_read("width")
      @height = instance_read("height")
    end

    def assign in_file
      if in_file.is_a?(Resizor::ResizorAsset)
        @id = in_file.id
        @name = in_file.name
        @mime_type = in_file.mime_type
        @size = in_file.size
        @width = in_file.width
        @height = in_file.height
      else
        @file = in_file
      end
    end

    def save
      if file
        @path = File.join(Dir.tmpdir, file.original_filename)
        if file.is_a?(Tempfile) || file.respond_to?(:path)
          FileUtils.move(file.path, @path)
        else
          File.open(@path, 'wb') { |f| f.write(file.read) }
        end
        if save_to_resizor
          File.unlink(@path)
          @file = nil
        else
          instance.errors[attachment_name.to_sym] << "can't be saved"
          return false
        end
      end
      instance_write(:resizor_id, @id)
      instance_write(:name, @name)
      instance_write(:mime_type, @mime_type)
      instance_write(:size, @size)
      instance_write(:width, @width)
      instance_write(:height, @height)
      return true
    end

    def delete
      destroy
    end

    def destroy
      if ret = super
        clear
        instance.send(:save)
      end
      ret
    end

    def clear
      @id = nil
      @name = nil
      @mime_type = nil
      @size = nil
      @width = nil
      @height = nil
    end

  protected
    def instance_write(_attr, value)
      setter = :"#{attachment_name}_#{_attr}="
      self.instance_variable_set("@#{_attr.to_s.chop}", value)
      instance.send(setter, value) if instance.respond_to?(setter)
    end

    def instance_read(_attr)
      getter = :"#{attachment_name}_#{_attr}"
      instance.send(getter) if instance.respond_to?(getter)
    end
  end
end
