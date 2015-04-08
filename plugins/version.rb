plugin :Version do
  match /version/, method: :display_version
  def display_version(msg)
    msg.reply "BaconBot v#{Bacon::Version::STRING}"
  end
end
