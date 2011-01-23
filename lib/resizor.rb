$LOAD_PATH << File.expand_path( File.dirname(__FILE__) )

require 'resizor/resizor'
require 'resizor/connection'
require 'resizor/asset'
require 'resizor/version'
require 'resizor/railtie'

if defined? ActionDispatch::Http::UploadedFile
  module ActionDispatch
    module Http
      class UploadedFile
        def path
          @tempfile.path
        end
      end
    end
  end
end
