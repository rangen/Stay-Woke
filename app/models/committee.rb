class Committee < ActiveRecord::Base
    has_and_belongs_to_many :politicians
    has_many :donations

    def get_initial_sched_a
        GetCommitteeReceipts.new(self, {initial_download: true}).seek if self.last_index.nil? 
    end
end