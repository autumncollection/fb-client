require 'fb_client'
require "test/unit"

class FbClientTest < Test::Unit::TestCase

  $FB_TOKENS = {
    :url => 'http://fb-tokens.ataxo.wcli.cz',

    # optional curburger configuration for fb-tokens fetching:
    :ua  => {
      :http_auth => {
        :user     => 'fbes',
        :password => 'T0kenyJsouTreba',
      },
    },
    :token_attempts           => 4,
    :sleep_no_token           => 300, # 5 minutes
    :preferred_no_token       => 'preferred_sleep',
    :preferred_no_token_sleep => 15,
  }

  def test_initialize
    assert_raise(ArgumentError) {
     FbClient::Token.get_token
    }
  end

end
