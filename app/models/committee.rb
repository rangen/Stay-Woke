class Committee < ActiveRecord::Base
    has_and_belongs_to_many :politicians
    
end