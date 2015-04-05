require 'bacon_bot/dicebox'

plugin :Dice do
  listen_to :message, method: :on_message
  def on_message m
    return unless m.message =~ /^(\d*#)?(\d+)d(\d+)/

    dice = Dicebox::Dice.new(m.message)
    begin
      d = dice.roll
      if d.size < 350
        m.reply "#{m.user.nick}, #{d}"
      else
        m.reply "#{m.user.nick}, I don't have enough dice to roll that!"
      end
    rescue Exception => e
      m.reply "#{m.user.nick}, I don't understand..."
    end
  end
end
