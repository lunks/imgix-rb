module Imgix
  class Path
    ALIASES = {
      width: :w,
      height: :h,
      rotation: :rot
    }

    def initialize(prefix, token, path = '/')
      @prefix = prefix
      @token = token
      @path = path
      @options = {}
    end

    def to_url(opts={})
      @options.merge!(opts)
      
      url = "#{@prefix}/#{path_and_params}"
      url += (@options.length > 0 ? '&' : '') + "s=#{signature}"

      return url
    end

    def defaults
      @options = {}
      return self
    end

    def method_missing(method, *args, &block)
      key = method.to_s.gsub('=', '')
      if args.length == 0
        return @options[key]
      elsif args.first.nil? && @options.has_key?(key)
        @options.delete(key) and return
      end

      @options[key] = args.first
    end

    ALIASES.each do |from, to|
      define_method from do
        @options[to]
      end

      define_method "#{from}=" do |value|
        @options[to] = value
      end
    end

    private

    def signature      
      Digest::MD5.hexdigest(@token + @path + '?' + query)
    end

    def path_and_params
      "#{@path}?#{query}".gsub(/^(\/)/, '')
    end

    def query
      @options.map { |k, v| "#{k.to_s}=#{v}" }.join('&')
    end
  end
end