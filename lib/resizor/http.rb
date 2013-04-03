require "uri"
require "net/http"

module Resizor
  module HTTP
    def self.get host, query
      uri = URI(host)
      uri.query = URI.encode_www_form query

      response = Net::HTTP.get_response uri

      [response.code.to_i, response.body]
    end

    def self.delete host, query
      uri = URI host
      uri.query = URI.encode_www_form query

      response = Net::HTTP.new(uri.host, uri.port).delete uri.request_uri
      [response.code.to_i, response.body]
    end
  end
end
