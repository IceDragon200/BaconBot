require 'cinch'
require 'ostruct'
require 'bacon_bot/plugins'
require 'bacon_bot/storage'

module TeamBacon
  class Bot
    class << self
      # @!attribute [rw] current
      #   @return [TeamBacon::Bot]
      attr_accessor :current
    end

    # @!attribute [rw] rootpath
    #   @return [String]
    attr_accessor :rootpath
    # @!attribute [rw] cinch
    #   @return [Cinch::Bot]
    attr_accessor :cinch
    # @!attribute [rw] plugins
    #   @return [TeamBacon::Plugins]
    attr_accessor :plugins
    # @!attribute [rw] storage
    #   @return [TeamBacon::Storage]
    attr_accessor :storage

    def initialize(rootpath, config)
      self.class.current = self
      @config = OpenStruct.new(config)
      @rootpath = rootpath
      @plugins = Plugins.new self, @rootpath
      @storage = Storage.new
      create_bot
      load_plugins
    end

    def create_bot
      @cinch = Cinch::Bot.new do
        configure do |c|
          c.nick = @config.nick
          c.realname = @config.realname || @config.nick
          c.user = @config.user || @config.nick
          c.server = @config.server
          c.channels = @config.channels || [@config.channel]
        end

        on :connect do |m|
          if pass = @config.password
            User("nickserv").msg("identify #{pass}")
          end
        end

        on :message, "!reload" do |m|
          if owner = @config.owner
            load_plugins if m.user.nick.casecmp(owner) == 0
          end
        end
      end
    end

    def start_scheduler
      @scheduler = Cinch::Timer.new self, interval: 15 do
        on_timer_15s
      end
    end

    def start
      start_scheduler
      @cinch.start
    end

    def load_plugins
      @plugins.reload
    end

    def on_timer_15s
      @plugins.each do |p|
        if p.respond_to? :timer_15s
          p.timer_15s
        end
      end
    end
  end
end
