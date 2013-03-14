require "json"

module Resizor

  class ImageRepository
    attr_reader :api_version, :access_token, :secret_token

    def initialize attrs = {}
      @api_version = attrs.fetch :api_version
      @access_token = attrs.fetch :access_token
      @secret_token = attrs.fetch :secret_token
    end

    def host
      "api.resizor.com"
    end

    def client_path
      "/v#{api_version}/#{access_token}"
    end

    def all params = {}
      params[:timestamp] = timestamp
      params[:signature] = generate_signature params

      response = HTTP.get url("assets.json"), params

      JSON.parse response.last
    end

    def fetch id
      params = { timestamp: timestamp }
      params[:signature] = generate_signature(params.merge(id: id))

      response = HTTP.get url("assets/#{id}.json"), params

      JSON.parse response.last
    end

    def store file, id = nil
      params = { timestamp: timestamp }
      params[:id] = id if id

      response = HTTP.post_multipart url("assets.json"), params.merge({
        signature: generate_signature(params),
        file: file
      })

      JSON.parse response.last
    end

    def timestamp
      Time.now.utc.to_i
    end

    def generate_signature params, signature_klass = Signature
      signature_klass.generate secret_token, params
    end

    def url endpoint
      File.join host, client_path, endpoint
    end
  end
end
