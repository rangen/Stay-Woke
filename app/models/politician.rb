class Politician < ActiveRecord::Base
    has_many :donations
    has_many :donors, through: :donations


end