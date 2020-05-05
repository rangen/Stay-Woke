User.destroy_all
Politician.destroy_all
Donor.destroy_all
Donation.destroy_all


tisdale = User.create(first_name: "Tisdale", last_name: "Fry", street_address: "1543 26th Ave", zip_code: 94122)
don = User.create(first_name: "Don", last_name: "Mallory", street_address: "2302 Valdez", zip_code: 94612)

#  if we us API, how do we use Ave/Street/Blvd?

bern = Politician.create(first_name: "Bernie", last_name: "Sanders")
warren = Politician.create(first_name: "Elizabeth", last_name: "Warren")

hader = Donor.create(first_name: "Bill", last_name: "Hader")
gwen = Donor.create(first_name: "Gwen", last_name: "Stefani")
uma = Donor.create(first_name: "Uma", last_name: "Thurman")

first = Donation.create(donor: hader, amount: 5000, date: Time.now, politician: bern)
second = Donation.create(donor: gwen, amount: 62000, date: Time.now, politician: warren)
third = Donation.create(donor: uma, amount: 1200, date: Time.now, politician: warren)
fourth = Donation.create(donor: uma, amount: 69420, date: Time.now, politician: warren)


bern.save
warren.save

hader.save
uma.save
gwen.save




