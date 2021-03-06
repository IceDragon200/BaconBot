require 'redis'

$redis ||= Redis.new

plugin :Mumble do
  def initialize *args
    super
    @murm_users = []
    start_watch
  end

  def start_watch
    @t = async(:watch_murmur)
  end

  def cmds
    "mumble"
  end

  def unregister
    super
    Thread.kill(@t) if @t && @t.alive?
  end

  match /mumble|mumz/
  def execute(m)
    synchronize(:mumble) do
      str = @murm_users.join(", ")
      str = "emptier than my heart" if str.empty?
      m.reply "mumz: #{str}"
    end
  end

  def watch_murmur
    loop do
      synchronize(:mumble) do
        users = $redis.get('murmUsers').split(';')

        chan = bot.channels.find{|c|c.name == "#sg_usa"}

        users.each do |newUser|
          if !@murm_users.include?(newUser)
            chan.send("#{newUser} on mumz") if chan
          end
        end

        @murm_users.each do |oldUser|
          if !users.include?(oldUser)
            chan.send("#{oldUser} off mumz") if chan
          end
        end

        @murm_users = users
      end
      sleep 2
    end
  end
end
