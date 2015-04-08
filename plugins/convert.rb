require 'steam-condenser'

plugin :Convert do
  def cmds
    ["con(vert)"]
  end

  match /(?:con(?:vert)?) (\d+)(\w+)\s+(\w+)/, method: :con
  def con(m, i, u1, u2)
    r = http.json("http://rate-exchange.appspot.com/currency?from=#{u1}&to=#{u2}&q=#{i}")
    if r.res.status != 200
      m.reply 'Convert appears to be down.'
    elsif r.err
      m.reply 'ERROR: failed to parse response.'
    else
      j = r.data['v'].round(2)
      m.reply "#{j}#{u2}"
    end
  end
end
