require 'yaml'

module TeamBacon
  class Storage
    class Store
      attr_accessor :name
      attr_accessor :data

      def initialize(parent, name, data)
        @name = name
        @storage = parent
        @data = data
      end

      def [](key)
        @data[key]
      end

      def []=(key, value)
        @data[key] = value
      end

      def load
        @data = @storage.load @name
      end

      def save
        @storage.save @name, @data
      end
    end

    attr_accessor :rootpath
    attr_accessor :cache

    def initialize
      @rootpath = Dir.getwd
      @cache = {}
    end

    def clear
      @cache.clear
    end

    def name_to_file(name)
      File.join rootpath, "#{name}.yaml"
    end

    def dump_raw(name, data)
      File.write name_to_file(name), data
      data
    end

    def dump(name, data)
      dump_raw name, data.to_yaml
      data
    end

    def load(name)
      filename = name_to_file(name)
      unless File.exists?(filename)
        if block_given?
          dump filename, yield
        else
          dump filename, {}
        end
      end
      YAML.load_file filename
    end

    def cache(name, data)
      @cache[name] ||= Store.new self, name, data
    end

    def get(name, &block)
      cache name, load(name, &block)
    end

    def save_raw(name, data)
      cache name, dump_raw(name, data)
    end

    def save(name, data)
      cache name, dump(name, data)
    end
  end
end
