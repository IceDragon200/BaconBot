require 'weather-underground'

plugin :Timea do
  def cmds
    "time"
  end

  match /time$/, method: :time
  def time m
    m.reply "bacon time: #{Time.now}"
  end

  match /time\s+(.+)/, method: :get_time
  def get_time m, loc
    w = WeatherUnderground::Base.new
    obv = w.CurrentObservations(loc)
    m.reply obv.display_location[0].full + ": " + obv.local_time
  end
end
