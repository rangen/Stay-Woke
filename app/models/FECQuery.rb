class FECQuery

    def self.load_data
        response = RestClient.get("https://api.open.fec.gov/v1/candidates/search/?election_year=2018&page=1&cycle=2018&state=CA&has_raised_funds=true&sort_hide_null=false&sort_nulls_last=false&sort=name&per_page=5&api_key=QcTjwDy06yeUoGj5I8ZKkXzAYBHA8cReddzO196M&sort_null_only=false")
        JSON.parse(response)
    end




end

# data["results"]  returns the results array for how many records we are retrieving

# each record is a HASH with (in this method, 25 keys)

# last_f2_date
# party
# cycles[array]
# candidate_status
# office
# district
# incumbent_challenge_full
# inactive_election_years
# incumbent_challenge
# party_full
# election_districts[array]               
# candidate_inactive (boolean)
# load_date  ????
# principal_committees        Array...........treasurer_name  committee_type_full  cycles[array]  #look more into later
# candidate_id
# district_number
# office_full
# first_file_date
# state (CA)
# election_years
# federal_funds_flag
# name AGUILAR, PETE
# active_through 2020
# last_file_date
