require "uri"
require "openssl"

module Resizor
  class Signature
    attr_reader :secret, :parameters

    def initialize secret, parameters
      self.secret = secret
      self.parameters = parameters
    end

    def generate
      digest = OpenSSL::Digest::Digest.new "sha1"
      OpenSSL::HMAC.hexdigest digest, secret, parameter_string
    end

    def parameter_string
      URI.encode_www_form parameters.sort
    end

    class << self
      def generate secret, params
        self.new(secret, params).generate
      end
    end

    private

    def secret= secret
      @secret = secret
    end

    def parameters= parameters
      parameters.delete :file
      @parameters = parameters
    end
  end
end
