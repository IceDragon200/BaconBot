plugin :Help do
  def cmds
    "help"
  end

  match /(help|cmds|commands)$/, method: :help
  def help m
    cmds = []
    bbot.cinch.plugins.each do |p|
      if p.respond_to? :cmds
        cmds += [p.cmds].flatten
      end
    end
    m.reply cmds.uniq.sort.join(", ")
  end

  match /help\s+(.+)/, method: :help_cmd
  def help_cmd m, cmd
    m.reply "I'm helping with #{cmd}!"
  end
end
