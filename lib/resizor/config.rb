require "singleton"

module Resizor
  def self.configured?
    config.configured?
  end

  def self.configure &block
    yield(config) if block_given?
    config
  end

  def self.config
    Config.instance
  end

  class Config
    include Singleton
    attr_accessor :access_key, :secret_key

    def configured?
      access_key && secret_key
    end
  end
end
