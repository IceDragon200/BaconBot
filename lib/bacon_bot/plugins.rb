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
    include Cinch::Plugin

    def self.create(name, &block)
      Class.new self do |mod|
        def mod.name
          name
        end

        class_eval &block
      end
    end
  end

  class Plugins::Loader
    attr_accessor :bot

    def initialize(bot)
      @bot = bot
    end

    def plugin(name, &block)
      @bot.plugins.register Plugin.create(name, &block)
    end

    def load_file(filename)
      instance_eval File.read(filename), filename, 1
    end

    def load_file(bot, filename)
      new(bot).load_file(filename)
    end
  end
end
