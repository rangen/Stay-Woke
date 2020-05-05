class FindCandidateID
        def initialize(name)
            office = Hash["P", "President", "H", "House", "S", "Senate"]


            url = "https://api.open.fec.gov/v1/names/candidates/?q=" + name + "&api_key=" + API_KEY[:fec]
            response = RestClient.get(url)
            result = JSON.parse(response)
            if result  #JSON didn't fail   code error catch if it is blank?
                hits = result["results"]
                if result.length == 1  #single result     yay!
                    puts "Found 1 result.  Name: #{hits[0].name}    ID:  #{hits[0].id}"
                else
                    puts "Found #{hits.length} results."   #need user to specify which or do we use logic?
                    hits.each_with_index {|hit, idx| puts "#{idx}.  #{hit["name"]}  #{office[hit["office_sought"]]}"}
                end
            end
        end
end