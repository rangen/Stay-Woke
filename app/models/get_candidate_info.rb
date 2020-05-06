class GetCandidateInfo
    attr_reader :id

    def initialize(candidate_id)
        @id = candidate_id
    end

    def seek
        args = {api_key: API_KEY[:fec], candidate_id: id}
        json = JSONByURL.new("https://api.open.fec.gov/v1/candidates/search/?" + Slug.build_params(args))
        res = json.snag  #puts endpoint if errors occurring comment out finds

        res["results"][0]["principal_committees"].each {|com| create_committee(com)}
    end

    def create_committee(committee)
        c = committee
        args = {name: c["name"], designation_full: c["designation_full"], alt_name: c["affiliated_committee_name"], org_type: c["organization_type"], fec_id: c["committee_id"], last_file_date: c["last_file_date"]}

        if !Committee.find_by(args)
            com = Committee.create(args)
            Politician.find_by(candidate_id: id).committees << com
        end
    end
end


# #we want to keep any records that are candidate_inactive: false and store them in Politician.

# res["results"][0] returns:
# {"has_raised_funds"=>true,
#     "party"=>"DEM",
#     "candidate_inactive"=>false,
#     "cycles"=>[2016, 2018, 2020],
#     "last_f2_date"=>"2020-01-27",
#     "district_number"=>0,
#     "principal_committees"=>
#      [{"cycles"=>[2016, 2018, 2020],
#        "party"=>"DEM",
#        "affiliated_committee_name"=>"FRIENDS OF KAMALA HARRIS",
#        "first_file_date"=>"2015-01-22",
#        "treasurer_name"=>"KOSOGLU, ROHINI",
#        "designation"=>"P",
#        "committee_type"=>"S",
#        "party_full"=>"DEMOCRATIC PARTY",
#        "organization_type_full"=>nil,
#        "candidate_ids"=>["S6CA00584"],
#        "committee_type_full"=>"Senate",
#        "state"=>"CA",
#        "committee_id"=>"C00571919",
#        "last_f1_date"=>"2020-01-27",
#        "organization_type"=>nil,
#        "designation_full"=>"Principal campaign committee",
#        "last_file_date"=>"2020-04-15",
#        "filing_frequency"=>"Q",
#        "name"=>"KAMALA HARRIS FOR SENATE"}],
#     "first_file_date"=>"2015-01-22",
#     "incumbent_challenge"=>"I",
#     "office_full"=>"Senate",
#     "election_years"=>[2016, 2022],
#     "party_full"=>"DEMOCRATIC PARTY",
#     "election_districts"=>["00", "00"],
#     "state"=>"CA",
#     "office"=>"S",
#     "federal_funds_flag"=>false,
#     "district"=>"00",
#     "load_date"=>"2020-01-27T21:10:00+00:00",
#     "last_file_date"=>"2020-01-27",
#     "incumbent_challenge_full"=>"Incumbent",
#     "inactive_election_years"=>nil,
#     "candidate_id"=>"S6CA00584",
#     "name"=>"HARRIS, KAMALA D",
#     "candidate_status"=>"C",
#     "active_through"=>2022}]



#     # res["results"][0]["principal_committees"][0]  INDEX MUST BE FOR MULTIPLE COMMITTEES?   #THERE's A CANDIDATE_IDS ARRAY HERE......MULTIPLE CANDIDATES FOR A COMMITTEE! potentially
#     # res["results"][0]["principal_committees"][0]["designation_full"]

#     designation_full
#     name
#     committee_id
