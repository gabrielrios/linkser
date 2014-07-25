require 'addressable/uri'
require 'linkser/version'

module Linkser
  class << self
    def parse(url, options = {})
      Linkser::Parser.new(url, options).object
    end
  end
end

require 'linkser/parser'
require 'linkser/object'
require 'linkser/resource'
