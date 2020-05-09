require 'pry'
require 'tty-prompt'
class User < ActiveRecord::Base
    has_and_belongs_to_many :politicians
    
    def find_my_servants
        #let's use Google Civic API to find my politicians using my address
        reporter = {success: true} #allow returns to provide useful info
        args = {:address=> self.address, :levels=> "country", :roles=>"legislatorUpperBody&roles=legislatorLowerBody", key: API_KEY[:google]}
        
        json = JSONByURL.new("https://www.googleapis.com/civicinfo/v2/representatives?" + args.build_params)
        res = json.snag

        #save normalized address info :)  Thanks Google!
        n = res["normalizedInput"]
        return {success: false, error_type: :failed_address}.merge(self.attributes) if n["zip"].empty?  #feels like the best way to guess if address is malformed as google will give partial data but we won't get congress district if no zip
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
            if pol.candidate_id.nil?  #populate the Politician's Candidate_ID for this Title if haven't already retrieved previously.
                found_candidate_id = FindCandidateID.new(pol).seek
                if found_candidate_id.nil?
                    #error with coalescing Google API data and FEC.gov
                    catch_to_report = pol.delete #finally a use for this shit  Let's get it out of our database AND do something with it below
                    reporter = {:success => false, error_type: :candidate_not_found_fec}.merge(catch_to_report.attributes)  #we can catch to send an email!!! attach info that failed
                else
                    pol.update(candidate_id: found_candidate_id)
                    self.politicians << pol if !self.politicians.include?(pol) #moved this logic here so we don't delete a record we're attached to.  how would fix otherwise?
                end
            end       
        end
        
        reporter   
    end

    def create_politician(args)
        Politician.create(args)
    end   
end