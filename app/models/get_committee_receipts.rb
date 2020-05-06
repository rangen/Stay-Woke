class GetCommitteeReceipts
    attr_reader :id, :committee

    def initialize(committee)
        @id = committee[:fec_id]
        @committee = committee
    end

    def seek
        args = {api_key: API_KEY[:fec], committee_id: id, contributor_zip: 78746}
        json = JSONByURL.new("https://api.open.fec.gov/v1/schedules/schedule_a?" + Slug.build_params(args))

        res = json.snag  #puts endpoint if errors occurring comment out finds

        #log page info, number results, last index retrieved
        donations = res["results"]
        page = donations.map {|d| {zip: d["contributor_zip"], amount: d["contributor_aggregate_ytd"], name: d["contributor_name"], entity_type: d["entity_type_desc"], date: d["contribution_receipt_date"]}}
        page.each {|item| save_donation(item)}
    end

    def save_donation(don)
        puts don
        if !Donation.find_by(date: don[:date], name: don[:name])
                shoot = Donation.new(don)
                shoot.committee = self.committee
                shoot.save
        end
                
    end
end




