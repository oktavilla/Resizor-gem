$LOAD_PATH << File.expand_path( File.dirname(__FILE__) )

require 'resizor/resizor'
require 'resizor/connection'
require 'resizor/asset'
require 'resizor/version'
require 'resizor/railtie'

if defined? ActionDispatch::Http::UploadedFile
  ActionDispatch::Http::UploadedFile.send :define_method, :path do
    @tempfile.path
  end
end
