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

    def subdomain
      "cdn"
    end

    def domain
      "resizor.com"
    end

    def host sub = self.subdomain
      "#{sub}.#{domain}"
    end

    def scale options = {}
      generate options.merge(operation: "scale")
    end

    def crop options = {}
      generate options.merge(operation: "crop")
    end

    # Generate a valid resizor url for a given image id and format.
    #
    # Accepts a hash of options.
    #   id - image identifier. Required.
    #   format - image format of returned image. Valid formats are jpg, png and gif. Required.
    #   operation - image conversion operation. Can be scale or crop. scale is default.
    #   width - Destination width for operation.
    #   height - Destination height for operation.
    #   pad - Hex color to pad scaled images with.
    #
    #   If operation is set to crop we accept cutout options
    #     cutout: { x: 100, y: 350, width: 500, height: 300 }
    #
    # The correct signature will be calculated from the given options
    def generate options = {}
      id = options.fetch :id
      format = options.fetch :format

      validate_operation options[:operation]

      url_params = convert_to_url_params options

      url_params[:signature] = signature url_params

      # Remove keys not necessary in the query string
      # We need them in the signature calculation so they are kept until here
      url_params.delete :id
      url_params.delete :format

      build_url path: path("#{id}.#{format}"), query: parameter_string(url_params)
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

    # Ensure we do not send an unknown operation to resizor.
    # This is mostly to safeguard against typos.
    def validate_operation operation
      if operation && !KNOWN_OPERATIONS.include?(operation)
        raise UnknownOperation, "#{operation} is not a valid operation. Possible operations is #{KNOWN_OPERATIONS.join(', ')}."
      end
    end

    # Builds the url from the componets and returns it as a string
    #
    # If configured to +optimize_parallel_downloads+ it calculates which subdomain
    # to use with +parallelized_subdomain+
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

    def convert_to_url_params options
      url_params = options.dup

      # Convert cutout options
      cutout_options = url_params.delete :cutout
      if url_params[:operation] == "crop"
        url_params.merge! convert_cutout_params(cutout_params)
      end

      url_params
    end

    def convert_cutout_params params
      cutout_params = {}
      params.each do |k,v|
        cutout_params["cutout_#{k}".to_sym] = v
      end

      cutout_params
    end
  end
end
