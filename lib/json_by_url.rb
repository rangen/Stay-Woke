class JSONByURL
    attr_reader :url, :logger

    def initialize(url, logger = false)
        @url = url
        @logger = logger
    end

    def snag
        result = {clean: false}
        
        puts "GETting JSON: #{url}" if @logger
        begin
          response = RestClient.get(url)
          result.code = response.code
          result.json = JSON.parse(response)
        rescue RestClient::BadRequest => e
          result.code = e.http_code
        else #check for 2xx also?
          result.clean = true
        end
        result
    end
end