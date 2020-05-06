class GetCandidateInfo
    attr_reader :id

    def initialize(candidate_id)
        @id = candidate_id
    end

    def seek
        args = {api_key: API_KEY[:fec], candidate_id: id}
        json = JSONByURL.new("https://api.open.fec.gov/v1/candidates/search/?" + Slug.build_params(args), false)
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