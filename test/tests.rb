require 'fb_client'
require "test/unit"

class FbClientTest < Test::Unit::TestCase

  $FB_TOKENS = {
    :url => 'http://fb-tokens.ataxo.wcli.cz',

    # optional curburger configuration for fb-tokens fetching:
    :ua  => {
      :http_auth => {
        :user     => '',
        :password => '',
      },
    }
  }

  def test_initialize
    p FbClient.fetch 'ihned.cz'
  end

end
