require 'cgi'
module Resizor
  class Connection
    attr_accessor :api_host, :api_port, :api_key, :use_ssl

    def initialize(options={})
      @api_host = options[:api_host] || options['api_host'] || 'resizor.com'
      @api_port = options[:api_port] || options['api_port'] || 80
      @api_key  = options[:api_key]  || options['api_key']
      @use_ssl  = options[:use_ssl]  || options['use_ssl'] || true
    end

    def get(request_uri, params={}, append_api_key=true)
      params[:api_key] = @api_key if append_api_key
      query = make_query(params)
      do_request do
        make_response_for resource[request_uri + '?' + query].get
      end
    end

    def post(request_uri, params={}, append_api_key=true)
      params[:api_key] = @api_key if append_api_key
      do_request do
        make_response_for resource[request_uri].post params
      end
    end

    def delete(request_uri, params={}, append_api_key=true)
      params[:api_key] = @api_key if append_api_key
      query = make_query(params)
      do_request do
        make_response_for resource[request_uri + '?' + query].delete
      end
    end

    def api_url(force_http = false)
      @api_url ||= "#{(@use_ssl == true && force_http == false) ? 'https' : 'http'}://#{@api_host}:#{(@use_ssl == true && force_http == false) ? '443' : @api_port}}"
    end

  protected

    def resource
      @resource ||= RestClient::Resource.new(api_url)
    end

    def make_query(params)
      params.collect {|key, value| [CGI.escape(key.to_s), CGI.escape(value.to_s)].join("=") }.join("&")
    end

    def make_response_for(http_response)
      Resizor::Response.new(http_response.code, http_response.body)
    end

    def do_request(&block)
      begin
        yield
      rescue RestClient::Exception => e
        Resizor::Response.new(e.http_code, e.http_body)
      end
    end
  end

  class Response
    attr_accessor :code, :body, :format
    def initialize(_code, _body, _format = 'json')
      @code = _code
      @format = _format
      @body = if @format == 'json'
        if defined?(ActiveSupport::JSON)
          ActiveSupport::JSON.decode(_body)
        else
          JSON.parse(_body)
        end
      else
        _body
      end
    end
  end
end
