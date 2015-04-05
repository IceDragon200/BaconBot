require 'steam-condenser'

plugin :Steam do
  def cmds
    "steam"
  end

  def initialize *args
    super
    @steam = bbot.storage.get('steam') { {} }
    @steam.save
    @enabled = false
    if File.exists?("cfg/steamapikey")
      WebApi.api_key = IO.read("cfg/steamapikey").strip
      @enabled = true
    end
  end

  def timer_15s
    return unless @enabled
    info = get_info @steam.data.keys

    info.each do |info|
      id = info[:id]
      old = @steam[id][:game]
      @steam[id] = info
      new_game = @steam[id][:game]
      if new_game && new_game != old
        bbot.cinch.channels[0].msg("steamwatch: #{info[:name]} is now playing #{info[:game]}")
      end
    end

    @steam.save
  end

  match /steamadd\s+(.+)/, method: :on_steamadd
  def on_steamadd m, name
    id = resolve_vanity_url name
    unless id
      m.reply "failed to resolve vanity url #{name}"
      return
    end

    if @steam.data.key?(id)
      m.reply "#{name} is already on steamwatch"
      return
    end

    @steam[id] = {}
    m.reply "#{name} has been placed on steamwatch"

    @steam.save
  end

  match /steamdel\s+(.+)/, method: :on_steamdel
  def on_steamdel m, name
    id = resolve_vanity_url name
    unless(id)
      m.reply "failed to resolve vanity url #{name}"
    end

    unless @steam.data.key?(id)
      m.reply "#{name} is not on steamwatch"
      return
    end

    @steam.delete id
    m.reply "#{name} has been removed from steamwatch"
  end

  match /steam\s*$/, method: :on_steamlist
  def on_steamlist m
    stats = []
    @steam.each_value do |info|
      str = "#{info[:name]}: "
      if(info[:game])
        str += "playing #{info[:game]}"
      else
        str += info[:state]
      end
      stats.push str
    end
    m.reply stats.join(", ")
  end

  match /steam\s+(.+)/, method: :on_steam
  def on_steam m, name
    id = resolve_vanity_url name
    unless(id)
      m.reply "failed to resolve vanity url"
      return
    end

    info = get_info(id)[0]
    str = "#{info[:name]}, #{info[:state]}"

    if(info[:game])
      str += ", playing " + info[:game]
    end

    m.reply str
  end

  def get_info ids
    if(ids.class == Array)
      ids = ids.join(",")
    end
    params = { :steamids => ids }
    json = WebApi.json 'ISteamUser', 'GetPlayerSummaries', 2, params
    result = MultiJson.load(json, :symbolize_keys => true)[:response]

    result[:players].map do |p|
      {:id => p[:steamid].to_i,
        :name => p[:personaname],
        :state => get_state(p[:personastate].to_i),
        :game => p[:gameextrainfo]}
    end
  end

  def get_state state
    case state
    when 0
      "offline"
    when 1
      "online"
    when 2
      "busy"
    when 3
      "away"
    when 4
      "snooze"
    when 5
      "looking to trade"
    when 6
      "looking to play"
    else
      "lulwut"
    end
  end

  def resolve_vanity_url(vanity_url)
    params = { :vanityurl => vanity_url }
    json = WebApi.json 'ISteamUser', 'ResolveVanityURL', 1, params
    result = MultiJson.load(json, :symbolize_keys => true)[:response]

    return nil if result[:success] != 1

    result[:steamid].to_i
  end
end
