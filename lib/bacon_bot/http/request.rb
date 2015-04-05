require 'active_support/core_ext/hash'
require 'excon'
require 'nokogiri'
require 'yajl'

module Bacon
  module HTTPHelper
    class Response
      attr_accessor :org
      attr_accessor :data

      def initialize(org, data)
        @org = org
        @data = data
      end
    end

    def request(uri, options = {})
      res = Excon.new(uri).request({ method: :get }.merge(options))
      data = begin
        yield res
      rescue Exception => ex
        puts ex.inspect
        nil
      end
      Response.new res, data
    end

    def plain(uri, options = {})
      request(uri, options) { |res| res.body }
    end

    def json(uri, options = {})
      h = { headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }
      request(uri, h.deep_merge(options)) { |res| Yajl::Parser.parse(res.body) }
    end

    def xml(uri, options = {})
      request(uri, options) { |res| Nokogiri::XML(res.body) }
    end

    def html(uri, options = {})
      request(uri, options) { |res| Nokogiri::HTML(res.body) }
    end
  end

  class HTTPRequestHelper
    include HTTPHelper
  end
end
