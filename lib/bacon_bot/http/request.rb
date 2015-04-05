require 'excon'
require 'nokogiri'
require 'yajl'

module TeamBacon
  module Http
    class Response
      attr_accessor :org
      attr_accessor :body

      def initialize(org, body)
        @org = org
        @body = body
      end
    end

    def request(uri, *args)
      res = Excon.new(uri).request(*args)
      Response.new res, yield(res)
    end

    def plain(*args)
      request(*args) { |res| res.body }
    end

    def json(*args)
      request(*args) { |res| Yajl::Parser.parse(req.body) }
    end

    def xml(*args)
      request(*args) { |res| Nokogiri::XML(res.body) }
    end

    def html(*args)
      request(*args) { |res| Nokogiri::HTML(res.body) }
    end
  end

  class HttpHelper
    include Http
  end
end
