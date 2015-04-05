require 'cinch'
require 'ostruct'
require 'bacon_bot/plugins'
require 'bacon_bot/storage'
require 'bacon_bot/data_cache'

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
    # @!attribute [rw] data_cache
    #   @return [TeamBacon::DataCache]
    attr_accessor :data_cache

    def initialize(rootpath, config)
      self.class.current = self
      @rootpath = rootpath
      @config = OpenStruct.new config
      @plugins = Plugins.new self, @rootpath
      @storage = Storage.new File.join(@rootpath, 'store')
      @data_cache = DataCache.new File.join(@rootpath, 'data')
      create_bot
      load_plugins
    end

    def create_bot
      cc = @config
      @cinch = Cinch::Bot.new do
        configure do |c|
          c.nick = cc.nick
          c.realname = cc.realname || cc.nick
          c.user = cc.user || cc.nick
          c.server = cc.server || abort('Server missing')
          c.channels = cc.channels || [cc.channel]
        end

        on :connect do |m|
          if pass = cc.password
            User("nickserv").send("identify #{pass}")
          end
        end

        on :message, "#{cc.commandchar}reload" do |m|
          if owner = cc.owner
            load_plugins if m.user.nick.casecmp(owner) == 0
          end
        end
      end
    end

    def start_scheduler
      @scheduler = Cinch::Timer.new @cinch, interval: 15 do
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
