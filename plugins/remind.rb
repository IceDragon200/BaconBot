plugin :Remind do
  def init_store(s)
    @reminds = s.get('reminds') { {} }
    @reminds.save
  end

  def cmds
    "remind"
  end

  listen_to :message, method: :on_message
  def on_message m
    synchronize(:remind) do
      msgname = m.user.nick.downcase

      if msgs = @reminds[msgname].presence
        to_del = []
        msgs.each do |remind|
          if remind[:at] <= Time.now
            m.reply "#{m.user.nick}, #{remind[:name]} at #{remind[:time]}: #{remind[:msg]}"
            to_del.push(remind)
          end
        end
        to_del.each do |remind|
          msgs.delete(remind)
        end
        @reminds.save
      end
    end
  end

  match /remind\s+([^\s]+)\s+(\w+)\s+([^\s].*)/
  def execute m, to, times, reminder
    to.downcase!
    at = Time.now

    times.scan(/\d+[a-zA-Z]/).each do |part|
      num = /\d+/.match(part)[0].to_i
      type = /[a-zA-Z]/.match(part)[0].downcase

      case type
      when "d"
        at += num * 60 * 60 * 24
      when "h"
        at += num * 60 * 60
      when "m"
        at += num * 60
      end
    end

    synchronize(:remind) do
      (@reminds[to] ||= []).push(
        msg: reminder,
        name: m.user.nick.downcase,
        time: Time.now,
        at: at
      )
      @reminds.save
      m.reply "#{m.user.nick}, #{to} will be remindered"
    end
  end
end
