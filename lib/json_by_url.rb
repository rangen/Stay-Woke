class JSONByURL
    attr_reader :url, :logger

    def initialize(url, logger = false)
        @url = url
        @logger = logger
    end

    def snag
          #code error responses here to more easily catch in individual class methods
        puts "Sending JSON Request: #{url}" if @logger
          response = JSON.parse(RestClient.get(url))
    end
end