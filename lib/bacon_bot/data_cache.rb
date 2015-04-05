module TeamBacon
  class DataCache
    # @!attribute [rw] rootpath
    #   @return [String]
    attr_accessor :rootpath

    def initialize(rootpath)
      @rootpath = rootpath
      @cache = {}
    end

    def load(name)
      File.read(File.join(rootpath, name))
    end

    def get(name)
      @cache[name] ||= load(name)
    end
  end
end
