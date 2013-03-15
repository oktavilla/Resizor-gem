module Resizor
  class Url
    AVAILABLE_SUBDOMAINS = 8
    KNOWN_OPERATIONS = [ "scale", "crop" ]

    UnknownOperation = Class.new ArgumentError

    attr_reader :api_version, :access_token, :secret_token, :config

    def initialize attrs = {}, config = Resizor.config
      @config = config
      @api_version = attrs.fetch :api_version
      @access_token = attrs.fetch :access_token
      @secret_token = attrs.fetch :secret_token
    end

    def generate params = {}
      validate_operation params[:operation]

      id = params.fetch :id
      format = params.fetch :format
      filename = "#{id}.#{format}"

      params[:signature] = signature params

      # Remove keys not necesarry in the query string
      params.delete :id
      params.delete :format

      build_url path: path(filename), query: parameter_string(params)
    end

    def subdomain
      "cdn"
    end

    def domain
      "resizor.com"
    end

    def host sub = self.subdomain
      "#{sub}.#{domain}"
    end

    def path endpoint = nil
      _path = [client_path]
      _path << endpoint if endpoint

      _path.join "/"
    end

    def client_path
      "/v#{api_version}/#{access_token}"
    end

    # Generate a signature from a parameters hash
    def signature params, signature_klass = Signature
      signature_klass.generate secret_token, params
    end

    def optimize_parallel_downloads?
      config.optimize_parallel_downloads?
    end

    def parameter_string params
      URI.encode_www_form params.sort
    end

    def validate_operation operation
      if operation && !KNOWN_OPERATIONS.include?(operation)
        raise UnknownOperation, "#{operation} is not a valid operation. Possible operations is #{KNOWN_OPERATIONS.join(', ')}."
      end
    end

    def build_url components = {}
      path = components.fetch :path
      query = components.fetch :query

      if optimize_parallel_downloads?
        url_host = host parallelized_subdomain(path, query)
      else
        url_host = host
      end

      components = components.merge host: url_host

      URI::HTTP.build(components).to_s
    end

    # Figure out which subdomain this requets should use
    # This will always return the same domain if called multiple times
    # with the same arguments
    def parallelized_subdomain path, query
      check = [path, query].join "-"
      identifier = Zlib::crc32(check) % AVAILABLE_SUBDOMAINS + 1

      [subdomain, identifier].join "-"
    end
  end
end
