require 'uri'

plugin :Links do
  def init_store(s)
    @links = s.get('links') { [] }
    @links.save
  end

  def cmds
    'links'
  end

  def save_link(url, text, title, name)
    synchronize(:links) do
      @links.data.push(
        url: url,
        msg: text,
        title: title,
        name: name,
        time: Time.now
      )
      @links.save
    end
  end

  listen_to :message, method: :on_message
  def on_message m
    name = m.user.nick.downcase
    ## get title, save link
    #
    text = m.message.dup
    while match = text.match(/\S+\.\S*[^,!]/)
      text = match.post_match
      url = URI.parse(match[0])
      url.scheme = 'http' if url.scheme.blank?
      begin
        doc = http.html(url)
        title = doc.css('title').text.gsub("\n", "")
        save_link url, text, title, name
        m.reply("#{m.user.nick}, link: #{title}") if title && !title.empty?
      rescue URI::InvalidURIError
      rescue SocketError
      rescue Exception => e
        if e.to_s.include?('redirection forbidden')
          save_link(url, text, '', name)
        else
          puts e.inspect
          puts e.backtrace.join("\n")
        end
      end
    end
  end

  match /links((?:\s+\w+)*)/
  def execute m, words
    if !words
      @links.data.sort! do |a, b|
        b[:time] <=> a[:time]
      end

      links = @links[0..2]
      links.each do |link|
        m.reply "#{m.user.nick}, #{link[:url]} - #{link[:title]} - linked by #{link[:name]} at #{link[:time]}"
      end
    else
      words = words.downcase.split
      results = @links.data.select do |link|
        words.all? do |word|
          word.strip!
          link[:url].to_s.downcase.include?(word) ||
            link[:title].to_s.downcase.include?(word) ||
            link[:name].to_s.downcase.include?(word) ||
            link[:msg].to_s.downcase.include?(word)
        end
      end

      results.sort! do |a, b|
        b[:time] <=> a[:time]
      end
      results = results[0..2]

      results.each do |link|
        m.reply "#{m.user.nick}, #{link[:url]} - #{link[:title]} - linked by #{link[:name]} at #{link[:time]}"
      end
    end
  end
end
