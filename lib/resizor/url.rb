module Resizor
  class Url
    AVAILABLE_SUBDOMAINS = 8
    KNOWN_OPERATIONS = [ "scale", "crop" ]

    UnknownOperation = Class.new ArgumentError

    attr_reader :api_version, :access_key, :secret_key, :config

    def initialize attrs = {}, config = Resizor.config
      @config = config
      @api_version = attrs.fetch :api_version
      @access_key = attrs.fetch :access_key
      @secret_key = attrs.fetch :secret_key
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
      validate_operation options[:operation]

      id, format = options.fetch(:id), options.fetch(:format)

      build_url path: path("#{id}.#{format}"), query: parameter_string_from_options(options)
    end

    def path endpoint = nil
      _path = [client_path]
      _path << endpoint if endpoint

      _path.join "/"
    end

    def client_path
      "/v#{api_version}/#{access_key}"
    end

    # Generate a signature from a parameters hash
    def signature params, signature_klass = Signature
      signature_klass.generate secret_key, params
    end

    def optimize_parallel_downloads?
      config.optimize_parallel_downloads?
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
      path, query = components.fetch(:path), components.fetch(:query)

      components = components.merge host: computed_host(path, query)

      URI::HTTP.build(components).to_s
    end

    def computed_host path, query
      if optimize_parallel_downloads?
        host parallelized_subdomain(path, query)
      else
        host
      end
    end

    # Figure out which subdomain this requets should use
    # This will always return the same domain if called multiple times
    # with the same arguments
    def parallelized_subdomain path, query
      check = [path, query].join "-"
      identifier = Zlib::crc32(check) % AVAILABLE_SUBDOMAINS + 1

      [subdomain, identifier].join "-"
    end

    def parameter_string_from_options options
      params = params_from_options options

      params[:signature] = signature params

      # Remove keys not necessary in the query string
      # We need them in the signature calculation so they are kept until here
      params.delete :id
      params.delete :format

      URI.encode_www_form params.sort
    end

    def params_from_options options
      params = options.dup

      # Convert cutout options from a nested hash to flat keys
      cutout_params = params.delete :cutout
      if params[:operation] == "crop"
        params.merge! convert_cutout_params(cutout_params)
      end

      params
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
