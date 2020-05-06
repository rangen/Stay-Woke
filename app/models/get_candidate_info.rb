class GetCandidateInfo
    def initialize(candidate_id)
        args = {api_key: API_KEY[:fec], candidate_id: candidate_id}
        json = JSONByURL.new("https://api.open.fec.gov/v1/candidates/search/?" + Slug.build_params(args))
        res = json.snag
        



        # args = {:address=> self.address, :levels=> "country", :roles=>"legislatorUpperBody&roles=legislatorLowerBody", key: API_KEY[:google]}
        
        # json = JSONByURL.new("https://www.googleapis.com/civicinfo/v2/representatives?" + Slug.build_params(args))
        # res = json.snag


    end
end


#we want to keep any records that are candidate_inactive: false and store them in Politician.