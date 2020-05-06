User.destroy_all
Politician.destroy_all
Donor.destroy_all
Donation.destroy_all
Committee.destroy_all



tisdale = User.create(first_name: "Tisdale", last_name: "Fry", address: "1543 26th Ave San Francisco CA", zip_code: 94122)
don = User.create(first_name: "Don", last_name: "Mallory", address: "2302 Valdez Oakland CA", zip_code: 94612)
drew = User.create(first_name: "Drew", last_name: "Majoulet", address: "1816 E 6th Austin TX")


tisdale.find_my_servants
don.find_my_servants
drew.find_my_servants



Politician.pluck(:candidate_id).each {|can| GetCandidateInfo.new(can).seek}

Committee.all.each{|com| GetCommitteeReceipts.new(com).seek}

#Log FEC API calls for session?
#drop old committees?  We should be filtering for old ones