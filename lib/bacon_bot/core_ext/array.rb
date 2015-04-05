class Array
  alias :pick :sample

  def pick!
    delete sample
  end
end
