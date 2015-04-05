require 'cinch/plugin'
require 'set'

module TeamBacon
  class Plugins
    # @!attribute [rw] bot
    #   @return [TeamBacon::Bot]
    attr_accessor :bot
    # @!attribute [rw] rootpath
    #   @return [String]
    attr_accessor :rootpath

    def initialize(bot, rootpath)
      @bot = bot
      @rootpath = rootpath
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
      puts "Loading plugins from: #@rootpath"
      Dir[File.join(@rootpath, 'plugins/*.rb')].each do |f|
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
      TeamBacon::Bot.current
    end

    def async(method_name = nil, &block)
      if block_given?
        Thread.new(&block)
      else
        Thread.new(&method(method_name))
      end
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
    #   @return [TeamBacon::Bot]
    attr_accessor :bbot

    def initialize(bot)
      @bbot = bot
    end

    def plugin(name, &block)
      @bbot.plugins.register Plugin.create(name, &block)
    end

    def load_file(filename)
      puts "Loading Plugin: #{filename}"
      instance_eval File.read(filename), filename, 1
    end

    def self.load_file(bbot, filename)
      new(bbot).load_file(filename)
    end
  end
end
