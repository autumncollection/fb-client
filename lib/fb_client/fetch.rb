# encoding:utf-8

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

    # return nil in case of error, data otherwise
    # func - calling method used for logging
    def self.fetch(url, preferred = :default, return_error = false)
      ini_fetch
      token, last_error, doc, attempt = nil, nil, nil, 0
      while true
        attempt += 1
        break if attempt > $FB_TOKENS[:token_attempts]
        token = FbClient::Token.get_token(preferred)
        if token && token.kind_of?(Hash) && token.include?(:error)
          return nil
        elsif !token.nil? && !token
          sleep $FB_TOKENS[:sleep_no_token]
          next
        elsif !token.nil? && token == $FB_TOKENS[:preferred_no_token]
          sleep $FB_TOKENS[:preferred_no_token_sleep]
          attempt -= 1
        elsif token.nil?
          return nil
        end

        graph_url =
          "#{GRAPH_URL}#{url}#{url.index('?') ? '&' : '?'}access_token=#{token}"
        response = request @@ua_fetch, url

        if !rsp || rsp.include?(:error)
          if rsp.include?(:content)
            begin
              doc, stop_fetching = rsp[:content], true
              # limit error - too many items in one response
              error = if doc['error_msg'] && LIMIT_ERROR.include?(doc['error_msg'])
                "limit_error"
              elsif doc['error'] && doc['error']['message']
                limit_error = ''
                LIMIT_ERRORS.each { |error|
                  limit_error = 'limit_error' if doc['error']['message'].match(error)
                }
                limit_error
              elsif doc['code'] && UA_RESET_ERROR.include?(doc['code'].to_i)
                stop_fetching = false
                nil
              elsif doc['error'].include?('code') && BREAK_CODES.include?(doc['error']['code'])
                {:error => doc['error']['code']}
              elsif doc['error'].include?('code') && DIFFERENT_ID.include?(doc['error']['code'].to_i)
              # ID was changed
                {
                  :error  => doc['error']['code'].to_i,
                  :new_id => doc['error']['message'] =~ /to page id (\d+)/i ? $1.to_i : nil
                }
              # token has to be masked
              elsif doc['error'].include?('code') && MASKED_TOKEN.include?(doc['error']['code'].to_i)
                stop_fetching = false
                nil
              end

              if stop_fetchning
                return return_error ? {:error => error} : false
              else
                FbClient::Token.report_token token
              end
            rescue => bang
              return {:error => "Facebook::Fetch: " +
                "#{bang.message} #{bang.backtrace} #{rsp[:content]}"
              }
            end
          end
        end

        doc && doc.kind_of?(Hash) && doc.include?('error') ?
          {:error => doc['error']} : doc
      end
      false
    end

    private

    def self.request url
      FbClient::Request.ua_get @@ua_fetch, url
    end

    # initialize curburger client only once
    def self.ini_fetch
      @@ua_fetch ||= Curburger.new(($FB_UA_OPTS[:ua] || {}).merge({
        :ignore_kill  => true,
        :req_norecode => true,
      }))
      @@ua_fetch.reset
    end

  end # Fetch

end
