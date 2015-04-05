plugin :Insult do
  def init_store(s)
    @insults = s.get('insults') { {} }
    @insults.save
    @insult_times = {}
    @insult_times.default_proc = proc { |h, k| h[k] = 0 }

    @insult_cache = bbot.data_cache.get('insults.txt').split("\n").map(&:strip)
  end

  def cmds
    'insult'
  end

  listen_to :message, method: :on_message
  def on_message m
    synchronize(:insult) do
      msgname = m.user.nick.downcase

      if ins = @insults[msgname].presence
        ins.each do |msg|
          m.reply "#{m.user.nick}, #{msg[:msg]}"
        end
        ins.clear
        @insults.save
      end
    end
  end

  match /insult\s+([^\s]+)/
  def execute m, to
    to.downcase!
    synchronize(:insult) do
      msgname = m.user.nick.downcase
      if Time.now.to_i - @insult_times[msgname] < 60
        m.reply "#{m.user.nick}, eat a dick"
      else
        @insult_times[msgname] = Time.now.to_i
        ins = @insult_cache.sample || "eat a dick"
        @insults[to] ||= []
        @insults[to].push(msg: ins) if @insults[to].empty?
        @insults.save
      end
    end
  end
end
