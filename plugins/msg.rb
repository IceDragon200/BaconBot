plugin :Msg do
  def init_store(s)
    @msgs = s.get('msgs') { {} }
    @msgs.save
  end

  def cmds
    'msg'
  end

  listen_to :join, method: :on_join
  def on_join m
    synchronize(:msg) do
      msgname = m.user.nick.downcase
      if @msgs[msgname].presence
        m.reply "#{m.user.nick}, you have messages waiting"
      end
    end
  end

  listen_to :message, method: :on_message
  def on_message m
    synchronize(:msg) do
      msgname = m.user.nick.downcase

      if umsgs = @msgs[msgname].presence
        umsgs.each do |msg|
          m.reply "#{m.user.nick}, #{msg[:name]} at #{msg[:time]}: #{msg[:msg]}"
        end
        umsgs.clear
        @msgs.save
      end
    end
  end

  match /msg\s+([^\s]+)\s+([^\s].*)/, method: :msg
  def msg m, to, text
    synchronize(:msg) do
      (@msgs[to.downcase] ||= []).push(
        msg: text,
        name: m.user.nick,
        time: Time.now
      )
      @msgs.save
      m.reply "#{m.user.nick}, msg deployed"
    end
  end
end
