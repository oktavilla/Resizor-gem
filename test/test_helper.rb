$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minitest/autorun'
require 'shoulda'
require 'resizor'
require 'logger'

require 'active_support'
require 'active_record'

require 'webmock/minitest'
include WebMock::API

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])

if defined?(Rails::Railtie)
  class Railtie < Rails::Railtie
    initializer 'resizor.insert_into_active_record' do
      ActiveSupport.on_load :active_record do
        Resizor::Railtie.insert
      end
    end
  end
end

class Railtie
  def self.insert
    ActiveRecord::Base.send(:include, Resizor::Glue)
  end
end

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

def fixtures_dir
  File.join(File.dirname(__FILE__), 'fixtures')
end

def image_fixture_path
  File.join(fixtures_dir, 'image.jpg')
end

def setup_fixtures
  Dir.mkdir(fixtures_dir) unless File.directory?(fixtures_dir)
  File.open(image_fixture_path, 'w') {|f| f.write('Fake JPEG data') } unless File.exists?(image_fixture_path)
end

def teardown_fixtures
  File.unlink(image_fixture_path) if File.exists?(image_fixture_path)
  Dir.rmdir(fixtures_dir) if File.directory?(fixtures_dir)
end

class File
  def original_filename
    File.basename(self.path)
  end
end
