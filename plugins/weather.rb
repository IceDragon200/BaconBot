require 'weather-underground'

plugin :Weather do
  def cmds
    "weather"
  end

  match /weather\s+(.+)/
  def execute m, loc
    m.reply get_weather(loc)
  end

  def get_weather loc
    w = WeatherUnderground::Base.new
    obv = w.CurrentObservations(loc)
    obv.display_location[0].full + ": " + obv.temperature_string + " " + obv.weather
  end
end
