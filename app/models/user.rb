class User < ActiveRecord::Base
    has_and_belongs_to_many :politicians
    
    def find_my_servants
        #let's use Google Civic API to find my politicians using my address
        args = {:address=> self.address, :levels=> "country", :roles=>"legislatorUpperBody&roles=legislatorLowerBody", key: API_KEY[:google]}
        
        json = JSONByURL.new("https://www.googleapis.com/civicinfo/v2/representatives?" + Slug.build_params(args), true)
        res = json.snag

        #save normalized address info :)  Thanks Google!
        n = res["normalizedInput"]
        normal = "#{n["line1"]} #{n["city"]} #{n["state"]}"
        self.update(address: normal, zip_code: n["zip"])

        servants = Hash.new
        offIndices = Hash.new
        polIndices = Hash.new

        res["divisions"].each_value do |v| 
            offIndices[v["officeIndices"][0]] = v["name"]
        end

        res["offices"].each_with_index do |office, off_idx|
             office["officialIndices"].each do |idx|
                polIndices[idx] = {title: office["name"]}
                polIndices[idx][:domain] = offIndices[off_idx]
             end
        end

        res["offices"].each do |office|
            office["officialIndices"].each do |index|
                servant_name = res["officials"][index]["name"]
                servant_name = Slug.scrub_name(servant_name) if servant_name.split.count > 2   #might not need!!!
                servants[index] = {:name => servant_name}
                servants[index][:party] = res["officials"][index]["party"]

                
                e = res["officials"][index]["emails"]
                servants[index][:email] = e.nil? ? "Not Listed" : e[0]
                t = res["officials"][index]["channels"].find {|h| h["type"] == "Twitter"}
                servants[index][:twitter] = t.nil? ? "Not Listed" : t["id"]

                f = res["officials"][index]["channels"].find {|h| h["type"] == "Facebook"}    #gnarly AF refactor?
                servants[index][:facebook] = f.nil? ? "Not Listed" : f["id"]

                i = res["officials"][index]["channels"].find {|h| h["type"] == "Instagram"}
                servants[index][:instagram] = i.nil? ? "Not Listed" : i["id"]

                y = res["officials"][index]["channels"].find {|h| h["type"] == "YouTube"}
                servants[index][:youtube] = y.nil? ? "Not Listed" : y["id"]
                

                servants[index][:domain] = polIndices[index][:domain]
                servants[index][:title] = polIndices[index][:title]
            end
        end

        servants.each_value do |rep|
            pol = Politician.find_or_create_by(rep)
            self.politicians << pol if !self.politicians.include?(pol)
            if !pol.candidate_id  #populate the Politician's Candidate_ID for this Title if haven't already retrieved.
                seeker = FindCandidateID.new(pol)
                pol.update(candidate_id: seeker.seek)
            end
        end
        
        servants #change to res to view output of JSON
    end

    def create_politician(args)
        Politician.create(args)
    end

    #simple instance method to show capability
    def show_my_local_donors
        self.politicians[0].committees[0].donations.map do |d|
            puts "#{d.donor.name} #{d.donor.street_1} #{d.donor.city}   $$#{d.amount}         #{d.donor.occupation} @ #{d.donor.employer}"
        end
    end

    
end