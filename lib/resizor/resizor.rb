require 'restclient'
require 'forwardable'
require 'json' unless defined?(ActiveSupport::JSON)

module Resizor
  extend self
  extend Forwardable
  attr_reader :connection
  def_delegators :connection, :get, :post, :delete, :api_url, :api_key, :use_ssl, :cdn_host

  def configure
    yield @connection = ResizorConnection.new
  end

  def connection
    raise "Not connected. Please setup Resizor configuration first." unless @connection
    @connection
  end
end
