require "imagekit/version"
require "imagekit/uploader"

module Imagekit
  autoload :Utils, 'imagekit/utils'
  autoload :Uploader, 'imagekit/uploader'
  autoload :PreloadedFile, "imagekit/preloaded_file"
  autoload :CarrierWave, "imagekit/carrier_wave"

  class ImagekitException < StandardError;end
  # This is class for initialize the secret key
  USER_AGENT = "ImagekitRuby/" + VERSION
  ENDPOINT   = 'https://ik.imagekit.io'
  class Configuration
    attr_accessor :public_key, :private_key, :imagekit_id

    def initialize
      self.public_key  = nil
      self.private_key = nil
      self.imagekit_id = nil
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||=  Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

  def self.generate_signature(params_hash)
    sorted_params = self.sort_params(params_hash)
    paramsstring  = CGI.unescape(sorted_params.to_query)
    checksum = OpenSSL::HMAC.hexdigest('sha1', Imagekit.configuration.private_key, paramsstring)
  end

  def self.sort_params(params_hash)
    sorted_params_hash = {}
    sorted_keys = params_hash.keys.sort{|x, y| x <=> y}
    sorted_keys.each do |k|
      sorted_params_hash[k] = params_hash[k]
    end
    sorted_params_hash
  end

end

require "imagekit/helper" if defined?(::ActionView::Base)
require "imagekit/railtie" if defined?(Rails) && defined?(Rails::Railtie)
