# encoding:utf-8
require 'curburger'
require 'oj'

# helper methods
require 'fb_client/token'
require 'fb_client/request'
require 'fb_client/fetch'

class FbClient

  include Token
  include Request
  include Fetch

  Oj.default_options = {:mode => :compat, :time_format => :ruby}

end
