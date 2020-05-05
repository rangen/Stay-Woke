User.destroy_all
Politician.destroy_all
Donor.destroy_all
Donation.destroy_all


tisdale = User.create(first_name: "Tisdale", last_name: "Fry", address: "1543 26th Ave San Francisco CA", zip_code: 94122)
don = User.create(first_name: "Don", last_name: "Mallory", address: "2302 Valdez Oakland CA", zip_code: 94612)

#  if we us API, how do we use Ave/Street/Blvd?

bern = Politician.create(name: "Bernie Sanders")
warren = Politician.create(name: "Elizabeth Warren")

hader = Donor.create(name: "Bill")
gwen = Donor.create(name: "Gwen Stefani")
uma = Donor.create(name: "Uma Thurman")

warren_win = Committee.create(name: "Warren!!!!", fec_id: "Cff9929")
bernie_win = Committee.create(name: "Bernie 2016", fec_id: "C999929")


first = Donation.create(donor: hader, amount: 5000, date: Time.now, committee: bernie_win)
second = Donation.create(donor: gwen, amount: 62000, date: Time.now, committee: warren_win)
third = Donation.create(donor: uma, amount: 1200, date: Time.now, committee: warren_win)
fourth = Donation.create(donor: uma, amount: 69420, date: Time.now, committee: warren_win)


bern.save
warren.save

hader.save
uma.save
gwen.save




