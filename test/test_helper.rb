$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'resizor'

require 'resizor/railtie'

gem 'activerecord', '~>3.0.0'
require 'active_record'

require 'webmock/test_unit'
include WebMock::API

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])

ActiveRecord::Base.send(:include, Resizor)

def build_model
  ActiveRecord::Base.connection.create_table :items, :force => true do |t|
    t.column :name, :string
    t.column :image_resizor_id, :string
    t.column :image_name, :string
    t.column :image_mime_type, :string
    t.column :image_size, :integer
    t.column :image_width, :integer
    t.column :image_height, :integer
  end
  Object.send(:remove_const, "Item") rescue nil
  Object.const_set("Item", Class.new(ActiveRecord::Base))
  Item.class_eval do
    has_resizor_asset :image
  end
end

def setup_resizor
  Resizor.configure do |config|
    config.api_host = 'resizor.test'
    config.api_key = 'test-api-key'
  end
  Resizor::Railtie.insert
end

class File
  def original_filename
    File.basename(self.path)
  end
end
