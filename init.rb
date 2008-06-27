$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'prefixed_attributes'
ActiveRecord::Base.send :include, PrefixedAttributes
