class GetCommitteeReceipts
    attr_reader :id, :committee, :stop_after         #transaction period????  Two year default, it looks like?
    attr_accessor :num_accessed, :last_index, :last_date, :record_count

    def initialize(committee, flags = {})
        @id = committee[:fec_id]     #need to set a start date....Nancy Pelosi pulled records from 1987 into DB
        @committee = committee
        @stop_after = 200            #watch for key-stroke to stop download?    show status of x / total downloaded?
        @num_accessed = 0
    end                             #wishing you luck with your re-election! lol   

    def seek
        args = {sort: "-contribution_receipt_date", api_key: API_KEY[:fec], committee_id: id, per_page: 100, last_index: @last_index, last_contribution_receipt_date: @last_date}
        json = JSONByURL.new("https://api.open.fec.gov/v1/schedules/schedule_a?" + Slug.build_params(args))

        res = json.snag 

        #log page info, number results, last index retrieved
        donations = res["results"]
        @record_count = res["pagination"]["count"] if @record_count.nil?     #initial population of instance variable that knows total records in dataset for user experience info
        @num_accessed += donations.count    #Log how many records we have accessed so far so we don't download Nancy Pelosi's donor base from 1987 and blow our API KEY
        donations.select! {|d| d["is_individual"]}  #MUTATES ARRAY!!!! KEEPS ONLY WHERE FIELD is_individual = true, AVOIDING DUPLICATE RECORDS FROM INTERNAL MEMOS
        
        #build an array of hashes of 2-element hashes (:donation & :donor) to pass to save_donation method
        page = donations.map {|d| {:donation=> {amount: d["contributor_receipt_amount"], date: d["contribution_receipt_date"]}, :donor=> {zip: d["contributor_zip"], name: d["contributor_name"], street_1: d["contributor_street_1"], street_2: d["contributor_street_2"], employer: d["contributor_employer"], state: d["contributor_state"], city: d["city"], occupation: d["contributor_occupation"], line_number: d["line_number"]}}}    
        @last_index = res["pagination"]["last_indexes"]["last_index"]               #set pagination
        @last_date = res["pagination"]["last_indexes"]["last_contribution_receipt_date"]    #set pagination part 2
        
        # puts "#{last_index}    #{last_date}"
        page.each {|item| save_donation(item)}
        pct_done = (@num_accessed.to_f / @stop_after * 100).round(1)   #xx.x% format for progress downloading records per flags [flags to:do]
        puts "#{pct_done}% complete.  Downloaded #{@num_accessed} of #{@stop_after} from a total of #{@record_count} records."
        seek if @num_accessed < @stop_after
        # res  #un-comment to view JSON data for this page
    end

    def save_donation(plug)
        penance = Donation.new(plug[:donation])
        giver = Donor.find_or_create_by(plug[:donor])
        penance.donor = giver                             #Boom, goes the dynamite. From your address to someone you should thank/sneer at in just a few lines of code.
        penance.committee = self.committee
        penance.save        
    end
end




