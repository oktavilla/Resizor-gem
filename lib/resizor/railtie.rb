require 'resizor.rb'

module Resizor
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

  module Glue
    def self.included base
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def has_resizor_asset name, options = {}
      include InstanceMethods

      if resizor_assets.nil?
        if ActiveSupport::VERSION::MAJOR == 3 && ActiveSupport::VERSION::MINOR > 1
          self.resizor_assets = {}
        else
          write_inheritable_attribute(:resizor_assets, {})
        end
      end
      resizor_assets[name] = options

      before_save :save_attached_files_for_resizor
      before_destroy :delete_attached_files_on_resizor

      define_method name do |*args|
        asset_for(name)
      end

      define_method "#{name}=" do |file|
        asset_for(name).assign(file)
      end

      define_method "#{name}?" do
        !asset_for(name).file.nil? || !asset_for(name).id.nil?
      end

    end

    def resizor_assets
      if ActiveSupport::VERSION::MAJOR == 3 && ActiveSupport::VERSION::MINOR > 1
        class_attribute(:resizor_assets)
        self.resizor_assets
      else
        read_inheritable_attribute(:resizor_assets)
      end
    end
  end

  module InstanceMethods
    def asset_for name
      @resizor_assets ||= {}
      @resizor_assets[name] ||= Resizor::AttachedResizorAsset.new(name, self, self.class.resizor_assets[name])
    end

    def save_attached_files_for_resizor
      self.class.resizor_assets.each do |name, options|
        asset_for(name).send(:save)
      end
    end

    def delete_attached_files_on_resizor
      self.class.resizor_assets.each do |name, options|
        asset_for(name).send(:destroy)
      end
    end
  end
end
