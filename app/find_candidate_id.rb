class FindCandidateID
    attr_reader :pol

    def initialize(politician)   #bad form to have so much shit in the initialize????     whoa i didn't need modules   hmmmm
        @pol = politician
    end

    def seek
        party = "DEM" if pol.party == "Democratic Party"
        party = "REP" if pol.party == "Republican Party"

        if pol.title == "U.S. Senator"
            office = "S"
            district = "00"   # 00 for Senate (warning: or at-large candidates but we shouldn't be getting those from Google API)
        else
            office = "H"
            district =  pol.domain.scan(/\d+/) if pol.domain   #RegEx to strip district # from Politician Domain (Representatives only)
        end                                                    #have to check for nil value b/c Liz Cheney from WY has no district


        args = {api_key: API_KEY[:fec], q: pol.name, party: party, district: district, office: office}
        
        args[:q] = "Joseph Courtney" if args[:q] == "Joe Courtney"    ###Build out this list as any errors are found with mismatched politician names

        json = JSONByURL.new("https://api.open.fec.gov/v1/names/candidates/?" + Slug.build_params(args))
        res = json.snag

        candidate = res["results"].find{|rec| rec["office_sought"] == office}
        
        return nil if candidate.nil?

        candidate["id"]
    end
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    # def initialize(name)
        #     office = Hash["P", "President", "H", "House", "S", "Senate"]


        #     url = "https://api.open.fec.gov/v1/names/candidates/?q=" + name + "&api_key=" + API_KEY[:fec]
        #     response = RestClient.get(url)
        #     result = JSON.parse(response)
        #     if result  #JSON didn't fail   code error catch if it is blank?
        #         hits = result["results"]
        #         if result.length == 1  #single result     yay!
        #             puts "Found 1 result.  Name: #{hits[0].name}    ID:  #{hits[0].id}"
        #         else
        #             puts "Found #{hits.length} results."   #need user to specify which or do we use logic?
        #             hits.each_with_index {|hit, idx| puts "#{idx}.  #{hit["name"]}  #{office[hit["office_sought"]]}"}
        #         end
        #     end
        # end