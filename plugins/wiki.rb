require 'nokogiri'
require 'open-uri'
require 'uri'

plugin :Wiki do
  def init_store(s)
    @fact = s.get('fact') { [cur_date, ''] }
    @fact.save
  end

  def cur_date
    Time.now.strftime("%D")
  end

  def cmds
    ["wiki", "fact"]
  end

  match "fact", method: :fact
  def fact m
    if (cur_date != @fact[0] || @fact[1].empty?)
      @fact[0] = cur_date
      @fact[1] = get_fact
      @fact.save
    end

    m.reply @fact[1]
  end

  match /wiki\s+(.+)/, method: :wiki
  def wiki m, q
    m.reply get_fact(q)
  end

  def get_fact name = nil
    name ||= "Special:Random"
    url = "http://en.wikipedia.org/wiki/#{name.gsub(" ", "_")}"

    doc = Nokogiri::HTML(open(url))

    title = doc.css('h1#firstHeading').text

    text = doc.css('div#bodyContent p')[0].text
    text.gsub!(/\[\d+\]/, "")

    if name == "Special:Random" && text.end_with?("may refer to:")
      return get_fact
    end

    unless text.index(title)
      text = "#{title.strip}: #{text}"
    end

    text
  end
end
