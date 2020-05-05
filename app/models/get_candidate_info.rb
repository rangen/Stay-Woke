class GetCandidateInfo
    def initialize(candidate_id)
        url = "https://api.open.fec.gov/v1/candidates/search/?election_year=2018&page=1&cycle=2018&has_raised_funds=true&sort_hide_null=false&sort_nulls_last=false&sort=name&per_page=5&sort_null_only=false "&api_key=" + API_KEY
            puts url
            response = RestClient.get(url)
            result = JSON.parse(response)
    end
end


#we want to keep any records that are candidate_inactive: false and store them in Politician.