require "resizor/version"
require "resizor/api_version"
require "resizor/config"
require "resizor/http"
require "resizor/signature"
require "resizor/image"
require "resizor/image_collection"
require "resizor/image_repository"
require "resizor/url"

module Resizor
  def self.store image, options = {}
    repository.store image, options["id"]
  end

  def self.delete id
    repository.delete id
  end

  def self.find id
    repository.fetch id
  end

  def self.all options = {}
    repository.all options
  end

  def self.config
    @config ||= Config.new
  end

  def self.configured?
    config.configured?
  end

  def self.configure &block
    yield(config) if block_given?
  end

  private

  def self.repository
    @repository ||= ImageRepository.new self.config
  end
end
