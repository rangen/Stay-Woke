class Donation < ActiveRecord::Base
    belongs_to :politician
    belongs_to :donor

    
end