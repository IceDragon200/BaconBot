require 'bacon_bot/pot'

plugin :PotMan do
  def init_store(s)
    @pots = s.get('pots') do
      h = {}
      h.default_proc = proc { |h, k| h[k] = Pot.new }
      h
    end
    @pots.data.each_value(&:fix)
    @pots.save
  end

  def cmds
    "pot"
  end

  match /pot\s+(\w+)/, method: :asdf
  def asdf m, thing
    case thing
    when "help"
      m.reply "pot [help / list],  pot <name> [status / reset / kill / hand / list],  pot <name> draw <num>,  pot <name> [put / take] <chip>"
    when "list"
      synchronize(:pot) do
        m.reply "pots: #{@pots.data.keys.join(', ')}"
      end
    end
  end

  match /pot\s+(\w+)\s+(\w+)\s*(\w*)/, method: :pot
  def pot m, name, task, arg
    synchronize(:pot) do
      msgname = m.user.nick.downcase
      pot = @pots[name]

      case task.downcase
      when "reset"
        pot.reset
        m.reply "pot #{name} reset"
      when "kill"
        @pots.data.delete name
        m.reply "pot #{name} killed"
      when "hand"
        m.reply "pot #{name} #{msgname}'s hand: #{pot.hand(msgname)}"
      when "draw"
        chips = pot.draw msgname, arg.to_i
        m.reply "drew #{chips}"
      when "put"
        chips = pot.put(msgname, arg.upcase)
        m.reply "pot #{name} #{msgname} put: #{chips}"
      when "take"
        chips = pot.take(msgname, arg.upcase)
        m.reply "pot #{name} #{msgname} take: #{chips}"
      when "status"
        num = pot.status

        m.reply "pot #{name} has #{num} chips remaining"
      end

      @pots.save
    end
  end
end
