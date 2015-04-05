require 'cinch/plugin'
require 'set'
require 'bacon_bot/http'

module Bacon
  class Plugins
    # @!attribute [rw] bot
    #   @return [Bacon::Bot]
    attr_accessor :bot
    # @!attribute [rw] rootpath
    #   @return [String]
    attr_accessor :rootpath

    attr_accessor :logger

    def initialize(bot, rootpath)
      @bot = bot
      @rootpath = rootpath
      @logger = nil
    end

    def list
      @bot.cinch.plugins
    end

    def each(&block)
      list.each(&block)
    end

    def shutdown
      unregister_handles
      unregister_all
    end

    def load_plugin(filename)
      Plugins::Loader.load_file @bot, filename
    end

    def load_all
      @logger.puts "Loading plugins from: #@rootpath" if @logger
      Dir.glob File.join(@rootpath, 'plugins/*.rb') do |f|
        load_plugin f
      end
    end

    def reload
      shutdown
      load_all
    end

    def register(plugin)
      list.register_plugin plugin
    end

    def unregister_handles
      each do |p|
        @bot.cinch.handlers.unregister(*p.handlers)
      end
    end

    def unregister_all
      list.unregister_all
    end
  end

  class Plugin
    def init_store(s)
      #
    end

    def bbot
      Bacon::Bot.current
    end

    def async(method_name = nil, &block)
      if block_given?
        Thread.new(&block)
      else
        Thread.new(&method(method_name))
      end
    end

    def http
      @http ||= Bacon::HTTPRequestHelper.new
    end

    def self.create(_name, &block)
      Class.new self do |mod|
        include Cinch::Plugin

        def mod.name
          _name
        end

        def mod.to_s
          _name
        end

        def initialize(*args)
          super
          init_store bbot.storage
        end

        class_eval &block
      end
    end
  end

  class Plugins::Loader
    # @!attribute [rw] bbot
    #   @return [Bacon::Bot]
    attr_accessor :bbot

    def initialize(bot)
      @bbot = bot
    end

    def plugin(name, &block)
      @bbot.plugins.register Plugin.create(name, &block)
    end

    def load_file(filename)
      @bbot.plugins.logger.debug "Loading Plugin: #{filename}" if @bbot.plugins.logger
      instance_eval File.read(filename), filename, 1
    end

    def self.load_file(bbot, filename)
      new(bbot).load_file(filename)
    end
  end
end
