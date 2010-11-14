require 'rails/generators/active_record'

class ResizorGenerator < ActiveRecord::Generators::Base
  desc "Create a migration to add resizor-specific fields to your model."

  argument :asset_names, :required => true, :type => :array, :desc => "The names of the asset(s) to add.",
           :banner => "asset_one asset_two asset_three ..."

  def self.source_root
    @source_root ||= File.expand_path('../templates', __FILE__)
  end

  def generate_migration
    migration_template "resizor_migration.rb.erb", "db/migrate/#{migration_file_name}"
  end

  protected

  def migration_name
    "add_resizor_#{asset_names.join("_")}_to_#{name.underscore}"
  end

  def migration_file_name
    "#{migration_name}.rb"
  end

  def migration_class_name
    migration_name.camelize
  end

end
