require "json"

module Resizor

  class Asset
    attr_reader :attributes
    def initialize attributes
      @attributes = attributes
    end
  end

  class AssetResponse
    attr_reader :asset

    def initialize attributes
      @asset = Asset.new attributes
    end

    def success?
      true
    end
  end

  class ErrorResponse
    attr_reader :errors

    def initialize errors
      @errors = errors
    end

    def success?
      false
    end
  end

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
      params[:signature] = signature params

      response = HTTP.get url("assets.json"), params

      JSON.parse response.last
    end

    def fetch id
      params = { timestamp: timestamp }
      params[:signature] = signature params.merge(id: id)

      response = HTTP.get url("assets/#{id}.json"), params

      JSON.parse response.last
    end

    def delete id
      params = { timestamp: timestamp }
      params[:signature] = signature params.merge(id: id)

      response = HTTP.delete url("assets/#{id}.json"), params

      response.first == 204
    end

    def store file, id = nil
      params = { timestamp: timestamp }
      params[:id] = id if id

      http_response = HTTP.post_multipart url("assets.json"), params.merge({
        signature: signature(params),
        file: file
      })

      status, body = *http_response
      body = JSON.parse body

      if status == 201
        AssetResponse.new body["asset"]
      else
        ErrorResponse.new body["errors"]
      end
    end

    def timestamp
      Time.now.utc.to_i
    end

    def signature params, signature_klass = Signature
      signature_klass.generate secret_token, params
    end

    def url endpoint
      File.join host, client_path, endpoint
    end
  end
end
