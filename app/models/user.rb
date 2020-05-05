class User < ActiveRecord::Base
    include 
    has_many :politicians
    
    # def find_my_servants
    #     #let's use Google Civic API to find my politicians using my address
    #     args = {:api_}
    #     "https://www.googleapis.com/civicinfo/v2/representatives"
    #     'https://www.googleapis.com/civicinfo/v2/representatives?address=2302%20Valdez%20Oakland%20CA&levels=country&roles=legislatorLowerBody&roles=legislatorUpperBody&key=[YOUR_API_KEY]' \


    # end
end