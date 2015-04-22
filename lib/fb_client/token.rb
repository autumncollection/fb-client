# encoding:utf-8

class FbClient

  module Token

    def self.get_token(type = :default)
      ini_token
      tail     = type == :default ? "?preferred=#{type.to_s}" : ""
      response = request "#{$FB_TOKENS[:url]}/get#{tail}"
      return nil if !response ||
        (response.kind_of?(Hash) && !response.include?(:error))
      response['token']
    end

    # report non-working token
    def self.report_token token
      ini_token
      request @@ua_token, "#{$FB_TOKENS[:url]}/check?access_token=#{token}"
    end

    # report non-working token and obtain a new one using get_token
    def self.report_and_get_new_token token
      report_token token
      get_token
    end

    def self.free_token?(type = :default)
      ini_token
      begin
        response = request @@ua_token, "#{$FB_TOKENS[:url]}/stats"
        return false unless response
        return false if response['working'].to_i <= 0
        return false if type == :default && response['preferred'].to_i > 0
        true
      rescue => bang
        return false
      end
    end

    # initialize curburger client only once
    def self.ini_token
      @@ua_token ||= Curburger.new(($FB_TOKENS[:ua] || {}).merge({
        :ignore_kill  => true,
        :req_norecode => true,
      }))
      @@ua_token.reset
    end

    private

    def self.request url
      FbClient::Request.ua_get @@ua_token, url
    end

  end

end
