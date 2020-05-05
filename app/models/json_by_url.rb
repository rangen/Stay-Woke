class JSONByURL
    attr_reader :url

    def initialize(url)
        @url = url
    end

    def snag
          #code error responses here to more easily catch in individual class methods
        response = JSON.parse(RestClient.get(url))
    end
end