class User < ActiveRecord::Base
    include Slug
    has_many :politicians
    
    def find_my_servants
        #let's use Google Civic API to find my politicians using my address
        args = {:address=> self.address, :levels=> "country", :roles=>"legislatorUpperBody&roles=legislatorLowerBody", key: API_KEY[:google]}
        
        json = JSONByURL.new("https://www.googleapis.com/civicinfo/v2/representatives?" + Slug.build_params(args))
        res = json.snag

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
                servants[index] = {:name => res["officials"][index]["name"]}
                servants[index][:party] = res["officials"][index]["party"]
                servants[index][:twitter] = res["officials"][index]["channels"].find {|h| h["type"] == "Twitter"}["id"]
                servants[index][:domain] = polIndices[index][:domain]
                servants[index][:title] = polIndices[index][:title]
            end
        end

        servants #change to res to view output of JSON
    end

    def create_politician(api)

    end

    
end