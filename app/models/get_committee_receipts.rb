class GetCommitteeReceipts
    attr_reader :id, :committee, :stop_after         #transaction period????  Two year default, it looks like?
    attr_accessor :num_accessed, :last_index, :last_date, :record_count

    def initialize(committee, flags = {})
        @id = committee[:fec_id]     #need to set a start date....Nancy Pelosi pulled records from 1987 into DB
        @committee = committee
        @stop_after = 100            #watch for key-stroke to stop download?    show status of x / total downloaded?
        @num_accessed = 0
    end                             #wishing you luck with your re-election! lol   

    def seek
        args = {sort: "-contribution_receipt_date", api_key: API_KEY[:fec], committee_id: id, per_page: 100, last_index: @last_index, last_contribution_receipt_date: @last_date}
        json = JSONByURL.new("https://api.open.fec.gov/v1/schedules/schedule_a?" + Slug.build_params(args))

        res = json.snag 

        #log page info, number results, last index retrieved
        donations = res["results"]
        @record_count = res["pagination"]["count"] if @record_count.nil?
        @num_accessed += donations.count
        donations.select! {|d| d["is_individual"]}  #MUTATES ARRAY!!!! KEEPS ONLY WHERE FIELD is_individual = true, AVOIDING DUPLICATE RECORDS
        page = donations.map {|d| {zip: d["contributor_zip"], amount: d["contributor_aggregate_ytd"], name: d["contributor_name"], entity_type: d["entity_type_desc"], date: d["contribution_receipt_date"]}}
        @last_index = res["pagination"]["last_indexes"]["last_index"]               #set pagination
        @last_date = res["pagination"]["last_indexes"]["last_contribution_receipt_date"]    #set pagination part 2
        
        # puts "#{last_index}    #{last_date}"
        page.each {|item| save_donation(item)}
        pct_done = (@num_accessed.to_f / @stop_after * 100).round(1)
        puts "#{pct_done}% complete.  Downloaded #{@num_accessed} of #{@stop_after} from a total of #{@record_count} records."
        seek if @num_accessed < @stop_after
        #res  #un-comment to view JSON data for this page
    end

    def save_donation(don)
        # if !Donation.find_by(date: don[:date], name: don[:name])  no way to sort?  records look identical
                shoot = Donation.new(don)
                shoot.committee = self.committee
                shoot.save
        # end
                
    end
end




