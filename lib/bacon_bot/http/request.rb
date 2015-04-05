require 'excon'
require 'nokogiri'
require 'yajl'

module TeamBacon
  module Http
    def request(*args)
      Excon.new(*args)
    end

    def json
    end

    def xml
    end

    def html
    end
  end
end
