class Donor < ActiveRecord::Base
    has_many :donations
    has_many :politicians, through: :donations

    
end