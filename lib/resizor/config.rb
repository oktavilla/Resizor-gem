module Resizor
  class Config
    attr_accessor :access_key, :secret_key, :optimize_parallel_downloads
    attr_writer :host

    def configured?
      access_key && secret_key
    end

    def api_version
      API_VERSION
    end

    def host
      @host ||= "api.resizor.com"
    end

    def optimize_parallel_downloads
      @optimize_parallel_downloads ||= false
    end

    alias :optimize_parallel_downloads? :optimize_parallel_downloads
  end
end
