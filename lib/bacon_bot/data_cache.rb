module Bacon
  class DataCache
    # @!attribute [rw] rootpath
    #   @return [String]
    attr_accessor :rootpath

    # @param [String] rootpath
    def initialize(rootpath)
      @rootpath = rootpath
      @cache = {}
    end

    # Loads a file from the system.
    # Name is the basename of the file to be loaded.
    #
    # @param [String] name
    def load(name)
      File.read(File.join(rootpath, name))
    end

    # Loads and caches a file's contents.
    # Name is the basename of the file to be loaded.
    #
    # @param [String] name
    def get(name)
      @cache[name] ||= load(name)
    end
  end
end
