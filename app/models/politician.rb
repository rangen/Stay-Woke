class Politician < ActiveRecord::Base
    has_and_belongs_to_many :committees
    has_and_belongs_to_many :users
    

end