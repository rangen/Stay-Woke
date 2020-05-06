User.destroy_all
Politician.destroy_all
Donor.destroy_all
Donation.destroy_all
Committee.destroy_all



tisdale = User.create(first_name: "Tisdale", last_name: "Fry", address: "1543 26th Ave San Francisco CA", zip_code: 94122)
don = User.create(first_name: "Don", last_name: "Mallory", address: "2302 Valdez Oakland CA", zip_code: 94612)


tisdale.find_my_servants
don.find_my_servants



Politician.pluck(:candidate_id).each {|can| GetCandidateInfo.new(can).seek}