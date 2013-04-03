require "resizor/version"
require "resizor/api_version"
require "resizor/config"
require "resizor/http"
require "resizor/image_repository"

module Resizor

  def self.store image, options = {}
    repository.store image, options["id"]
  end

  def self.repository
    @repository ||= ImageRepository.new self.config
  end

  def self.configured?
    config.configured?
  end

  def self.configure &block
    yield(config) if block_given?
  end

  def self.config
    @config ||= Config.new
  end
end
