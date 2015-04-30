# encoding:utf-8

class FbClient

  module Request

    def self.ua_get ua, url
      ua.reset
      begin
         p url
        response = ua.send(:get, url)
      rescue FetchFailedException => err
        return false
      end

      begin
        content = Oj.load response[:content]
        return {:error => response[:error], :content => content} if
          response.include?(:error)
        content
      rescue SyntaxError, Oj::ParseError => e
        return nil
      end
    end

  end

end
