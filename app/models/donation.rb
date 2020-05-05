class Donation < ActiveRecord::Base
    belongs_to :committee
    belongs_to :donor

    
end