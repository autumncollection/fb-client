# encoding:utf-8

class FbClient

  module Request

    def self.ua_get ua, url
      ua.reset
      begin
        response = ua.send(:get, url)
      rescue FetchFailedException => err
      end

      begin
        content = response[:content]
        return {:error => response[:error], :content => content} if
          response.include?(:error)
        content
      rescue SyntaxError, Oj::ParseError => e
        return nil
      end
    end

  end

end
