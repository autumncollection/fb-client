# encoding:utf-8
require 'fb_client/request'
class FbClient

  module Fetch

    protected

    LIMIT_ERROR = [
      'An unknown error occurred',
    ]
    LIMIT_ERRORS = [
      /the 'limit' parameter should not exceed/i
    ]
    # ua reset error - blacklisted ip
    UA_RESET_ERROR = [5]
    LIMIT          = 250
    BREAK_CODES    = [100, 2500, 803, 21]
    DISABLE_REASON = {
      :'2500'   => 'Deleted profile',
    }
    MASKED_TOKEN = [190, 613, 2, 4, 17, 613]
    DIFFERENT_ID = [21]
    FB = {
      :graph_api_url      => "https://graph.facebook.com/v2.0/",
      :sleep_no_token     => 200,
      :sleep_preferred    => 15,
      :token_attempts     => 3,
      :preferred_no_token => 'preferred_sleep',
    }

    # return nil in case of error, data otherwise
    # func - calling method used for logging
    def self.fetch(url, preferred = :default, return_error = false)
      ini_token_conf
      token, last_error, doc, attempt = nil, nil, nil, 0
      while true
        attempt += 1
        break if attempt > @@conf[:token_attempts]
        token = FbClient::Token.get_token(preferred)

        if !token.nil? && token == @@conf[:preferred_no_token]
          sleep @@conf[:sleep_preferred]
          attempt -= 1
          next
        elsif !token.nil? && !token
          sleep @@conf[:sleep_no_token]
          next
        elsif token.nil?
          return nil
        end

        response = request "#{@@conf[:graph_api_url]}#{url}" +
          "#{url.index('?') ? '&' : '?'}access_token=#{token}"

        if response && response.include?(:error) && response.include?(:content)
          error = recognize_error response[:content]
          # stop fetching
          if error.kind_of?(Hash) || error == true
            return return_error ? error : false
          # just report token
          else
            FbClient::Token.report_token token
            next
          end
        end

        if response && response.kind_of?(Hash) && response.include?('error')
          return_error ? {:error => response['error']} : false
        else
          return response
        end
        break
      end
      false
    end

    private

    include Request

    def self.ini_token_conf
      @@conf = FbClient::Fetch::FB
      @@conf.merge!($FB_TOKENS || {})
      @@conf.merge!($FB || {})
    end

    def self.request url
      ini_fetch
      FbClient::Request.ua_get @@ua_fetch, url
    end

    # initialize curburger client only once
    def self.ini_fetch
      @@ua_fetch ||= Curburger.new((defined?($FB_UA_OPTS) ? $FB_UA_OPTS[:ua] : {}).merge({
        :ignore_kill  => true,
        :req_norecode => true,
      }))
      @@ua_fetch.reset
    end

    def self.recognize_error response
      begin
        # limit error - too many items in one response
        if response['error_msg'] && LIMIT_ERROR.include?(response['error_msg'])
          {:error => "limit_error"}
        # 504 gateway
        elsif response.include?('error') && response['error'].include?('code')
          if UA_RESET_ERROR.include?(response['code'].to_i) ||
            MASKED_TOKEN.include?(response['error']['code'].to_i)

            false
          elsif BREAK_CODES.include?(response['error']['code'].to_i)
            {:error => response['error']['code']}
          elsif DIFFERENT_ID.include?(response['error']['code'].to_i)
            {
              :error  => response['error']['code'].to_i,
              :new_id => response['error']['message'] =~
                /to page id (\d+)/i ? $1.to_i : nil
            }
          else
            limit_error = {:error => response['error']['message']}
            LIMIT_ERRORS.each { |error|
              limit[:error] = 'limit_error' if
                response['error']['message'].match(error)
            }
            limit_error
          end
        end
      rescue => bang
        return {:error => "Facebook::Fetch: " +
          "#{bang.message} #{bang.backtrace} #{response}"
        }
      end
    end
  end # Fetch

end
