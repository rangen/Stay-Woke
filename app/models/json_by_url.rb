class JSONByURL
    attr_reader :url

    def initialize(url)
        @url = url
    end

    def snag
          #code error responses here to more easily catch in individual class methods
        puts "Sending JSON Request: #{url}"
          response = JSON.parse(RestClient.get(url))
    end
end