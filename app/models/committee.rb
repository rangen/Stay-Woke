class Committee < ActiveRecord::Base
    has_and_belongs_to_many :politicians
    has_many :donations

    
end