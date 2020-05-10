require 'pry'
require 'tty-prompt'
class User < ActiveRecord::Base
    has_and_belongs_to_many :politicians
    
    def check_address(new_add)  #passing in so we can preserve the current address on an unsuccessful change attempt.   switch to User.new -> User.create and save old?
        args = {:address=> new_add, :levels=> "country", :roles=>"legislatorUpperBody&roles=legislatorLowerBody", key: API_KEY[:google]}        

        attempt = JSONByURL.new("https://www.googleapis.com/civicinfo/v2/representatives?" + args.build_params)
        res = attempt.snag
        
        return false if !res.clean #send back to one of the two methods that grab an address so they can reattempt (4/9/20 we only get clean on 2xx responses)
        return false if res.json.offices.reduce(0) {|sum, div| sum += div.officialIndices.length} != 3  #if didn't catch 3 politicians, address was poor  continue if partial? i.e. we didn't grab one but let's work with 1 or 2...?  and user can update address later
        
        #address valid! let's return from this function with the normalized address thanks to the Google API
        n = res.json.normalizedInput
        normal = "#{n.line1} #{n.city} #{n.state}"
        self.update(address: normal, zip_code: n.zip) #First time we save the new user or the dummy user  if existing user, update is fine.
        user_pols = parse_civic_info(res.json)
        #swap out Google API name for FEC name here if we detect an issue in the staywoke JSON we maintain
        user_pols = user_pols.each {|pol| pol.name = StayWokeCLI.patches.json[pol.name] || pol.name} #yew!

        user_pols.each do |pol| 
            result = FindCandidateID.new(pol).seek if pol.candidate_id.nil?  #don't bother retrieving candidate ID if we already have

            if result || pol.candidate_id #if we found or already had b/c not nil
                pol.update(candidate_id: result) if pol.candidate_id.nil? #update if new
                self.politicians << pol if !self.politicians.include?(pol)
            else
                find_fail = pol.attributes
                find_fail.user = self.attributes
                report_failure(find_fail)
            end
            self.reload
        end
        binding.pry
        sleep 3
    end

    def report_failure(msg)
        binding.pry
        puts msg
    end

    def parse_civic_info(res)
        
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
                servant_name = servant_name.scrub_name if servant_name.split.count > 2   #might not need!!!  Removes middle initials and Jr. suffixes
                servants[index] = {:name => servant_name}
                servants[index][:party] = res["officials"][index]["party"]
              
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
        servants.values.map{|pol| Politician.find_or_create_by(pol)}
    end 
end