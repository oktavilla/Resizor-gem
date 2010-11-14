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
      ActiveRecord::Base.send(:include, Resizor)
    end
  end

  class << self
    def included base
      base.extend ClassMethods
    end
  end
  
  module ClassMethods
    def has_resizor_asset name, options = {}
      include InstanceMethods
      
      write_inheritable_attribute(:resizor_assets, {}) if resizor_assets.nil?
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
      read_inheritable_attribute(:resizor_assets)
    end
  end
  
  module InstanceMethods 
    def asset_for name
      @resizor_assets ||= {}
      @resizor_assets[name] ||= Resizor::AttachedAsset.new(name, self, self.class.resizor_assets[name])
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
