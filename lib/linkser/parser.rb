require 'net/http'
require 'net/https'

module Linkser
  class Parser
    attr_reader :object, :last_url

    def initialize url, options={}
      head = get_head url, options
      @object =
        case head.content_type
        when "text/html"
          Linkser::Objects::HTML.new url, last_url, head, options
        else
          Linkser::Object.new url, last_url, head, options
        end
    end

    private

    def get_head url, options, limit = 10
      raise 'Too many HTTP redirects. URL was not reacheable within the HTTP redirects limit' if (limit==0)
      @last_url = url
      uri = URI.parse(Addressable::URI.escape(url))
      if uri.scheme and (uri.scheme.eql? "http" or uri.scheme.eql? "https")
        http = Net::HTTP.new uri.host, uri.port
        if uri.scheme.eql? "https"
          unless options[:ssl_verify]==true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          http.use_ssl = true
        end
      else
      raise 'URI ' + uri.to_s + ' is not supported by Linkser'
      end
      http.start do |agent|
        response = agent.head uri.request_uri
        case response
        when Net::HTTPSuccess then
          return response
        when Net::HTTPRedirection then
          location = response['location']
          location = "#{uri.scheme}://#{uri.host}:#{uri.port}#{location}" if location.start_with?("/")
          warn "Redirecting to #{location}"
          return get_head location, options, limit - 1
        else
        raise 'The HTTP request has a ' + response.code + ' code'
        end
      end
    end
  end
end

