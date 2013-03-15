require "singleton"

module Resizor
  def self.configured?
    config.configured?
  end

  def self.configure &block
    yield(config) if block_given?
  end

  def self.config
    Config.instance
  end

  class Config
    include Singleton
    attr_accessor :access_key, :secret_key, :optimize_parallel_downloads

    def configured?
      access_key && secret_key
    end

    def optimize_parallel_downloads
      @optimize_parallel_downloads ||= false
    end

    alias :optimize_parallel_downloads? :optimize_parallel_downloads
  end
end
