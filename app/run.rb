require 'tty-prompt'
require 'colorize'
require 'colorized_string'
require 'pry'

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "db/donations.db")  
class StayWokeCLI
    attr_accessor :user, :temp_user, :temp_active, :current_user, :current_committee, :current_politician
    attr_reader :heart
    def initialize
        @prompt = TTY::Prompt.new
        @heart = @prompt.decorate(@prompt.symbols[:heart] + ' ', :bright_magenta)
        @temp_active = false
        
    end

    def welcome
      puts "Welcome to Stay Woke!".light_blue.on_light_white
      resp = @prompt.yes?("Is it your first time waking up?")
      resp || User.first.nil? ? new_user : find_user_name  #pretty genius || to stop login attempt to an empty db :)
      login
    end

    def new_user
        args = {}
        system "clear"
        args[:first_name] = @prompt.ask("We've been expecting you. It's never too late to wake up and find out what's going on. Staying woke takes daily practice and mindfulness.  Let's help you with that by setting up a user profile. If I need to ask you a question, what is your first name?")
        args[:last_name] = @prompt.ask("Thanks, #{args[:first_name]}.  We won't share your information to any third-party vendors (until we get Series A Funding, at least).  Is there a family name you'd like to use?")
        args[:address] = @prompt.ask("In order to properly assist you #{args[:first_name]}, your address will be required. This information will be kept completely private unless you try to break our code.")
        seed_initial_data(args)
        puts "Let's fucking do this! You'll need a password to access the system."
    end

    def find_user_name #displays users in database  and user can select one to attempt to log in with
       names = User.all.map do |n|
            "#{n[:first_name]} #{n[:last_name]}"
        end
        resp = @prompt.select("Select a user:", names)
        first, last = resp.split
        @user = User.find_by(first_name: first, last_name: last)# could use new variable of name = first + last
        # choices = []
        # User.all.each do |n|
        #     choices << "#{n[:first_name]} #{n[:last_name]}"
        #     choices << n.id
        # end
        # @user = @prompt.select("Select a user:", Hash[choices]) 
    end

    def login
        #checks the newly loaded @user variable for a password.  if new user, create and exit w/ true.  if password, ask for password and rturn
        if @user.password.nil?
            resp = @prompt.mask("Please create a password:", mask: @heart)
            @user.update(password: resp)
            return true
        else 
             3.times do 
                resp = @prompt.mask("Please enter your password:", mask: @heart)
                return true if resp == @user.password
             end
             welcome #this is where they failed to login  
         end
        #check and branch to new_user or set instance variables
    end

    def main_menu
        @temp_user.destroy if @temp_user  #Delete the incomplete User record in our database!
        @temp_active = false #reset temp_user when returning to main menu
        @temp_user = nil
        @current_user = @user
        choices = {"Show Information for My District" => 2,
             "Show Information for Another District" => 3,
             "Settings" => 4, "Exit" => 1
            }
       resp = @prompt.select("Please choose from one of the following:", choices, cycle: true)
       case resp
        when 1
            exit_program
        when 2
            info_for_district
        when 3
            retrieve_other_address_as_user_obj
            info_for_district
        when 4
            settings
       end
    end

    def exit_program
        system 'clear'
        puts "Enjoy your slumber. Come back when you're ready to be woke.".light_blue.on_white #colorify this shit Tisdale!
    end

    def retrieve_other_address_as_user_obj  #give user a chance to enter a new address to see data for; give option for random address with 'random'
        other_address = @prompt.ask("Enter a US address or 'random' to retrieve district info:", default: "1520 Marion Lincoln Park MI")
        @temp_active = true
        seed_initial_data(address: other_address)
        @current_user = @temp_user
    end

    def info_for_district
        user = @current_user
        choices = {user.politicians[0].name => 0, user.politicians[1].name => 1, user.politicians[2].name => 2, "Return to Main Menu" => :exit}
        resp = @prompt.select("Please choose one of the following:", choices, cycle: true)
        case resp
        when :exit
        main_menu
        else
            @current_politician = user.politicians[resp]
            show_committee_names
        end
    end
    
    def show_committee_names   #
        choices = {}
        pol = @current_politician
        pol.committees.each_with_index {|com, idx| choices[com.name] = idx}
        choices["Return to District"] = :exit
        resp = @prompt.select("Select a Committee for #{pol.name}".purple, choices)

        case resp
        when :exit
            info_for_district
        else
            @current_committee = pol.committees[resp]
            show_committee_info
        end
    end         

    def show_committee_info
        pol = @current_politician
        com = @current_committee
        choices = [{name: com.name + "(#{com.designation_full})", value: 0, disabled: ''},
        {name: "Active: #{com.cycles_active}   Individual Donations: #{com.num_records_available}", value: 0, disabled: ''},
        {name: "You have downloaded #{com.num_records_downloaded} of #{com.num_records_available}", value: 0, disabled: ''},
        {name: "View Donations to This Committee", value: :continue},
        {name: "Return to Committee Names", value: :exit}]
        resp = @prompt.select(pol.name, choices)
        case resp
            when :continue
                view_donation_info
            when :exit
            show_committee_names
        end
    end

    def view_donation_info
        pol, com  = @current_politician, @current_committee

        
    end

    def settings
        choices = {"About Stay Woke!".light_blue.on_white=>:about, "View My Account Settings" => 1,
            "Delete Data"=>2,
            "Delete Account" => 3,
            "Change Address" => 4,
            "Change Password" => 5,
            "Return to Main Menu" => 6
        }
        resp = @prompt.select("Please choose from one of the following:", choices, cycle: true)
            case resp
            when :about
                about_stay_woke
            when 1
                view_my_account_settings
            when 2
                delete_data
            when 3
                delete_my_user_account
            when 4
                change_address
            when 5 
                change_password
            when 6
                main_menu
            end
    end

    def about_stay_woke

        settings
    end

    def delete_data
        settings
    end

    def view_my_account_settings
        settings
    end

    def delete_my_user_account
        @user.destroy   #First let's prompt are you sure?   Remind them the politician records will remain, you are only deleting the user account
        @user, @temp_user, @temp_active, @current_user, @current_committee, @current_politician = [nil] * 6   #punt session variables but we can keep session open, keeping run.rb clean
        system "clear"
        puts "Account deleted. Don't feed the hand that bites you.".red
        welcome #Great loop!  This is where we would start over (for some reason if we wanted to instead of changing address)
    end

    def change_address
        args = @user.attributes  #Oh, hello Ruby on Rails command
        args[:address] = @prompt.ask("Current Address: #{@user.address}   New Address?")
        @user.destroy
        @user = seed_initial_data(args)
        @current_user = @user
        settings
    end

    def change_password
        @user.password = @prompt.ask("Current Password: #{@user.password}   New Password?")
        @user.save
        settings
    end

    def exit
       puts "Enjoy your slumber. Come back when you're ready to be woke."
    end

    private

    def seed_initial_data(args)
        puts "Building your initial dataset...."   #COLORIFY TISDALE
        hold_me = User.create(args)
        hold_me.find_my_servants
        puts "Retrieving info about: " + hold_me.politicians.pluck(:name).join("    ")
        hold_me.politicians.pluck(:candidate_id).each {|can| GetCandidateInfo.new(can).seek if Politician.find_by(candidate_id: can).committees.empty?}
        hold_me.politicians.each do |pol|
            pol.committees.each {|com| GetCommitteeReceipts.new(com, true).seek if com.last_index.nil?} 
        end
        @temp_active ? @temp_user = hold_me : @user = hold_me
    end
end
# # #run.rb will start here  (maybe some require_relative statements idfk but just the below codes)
sess = StayWokeCLI.new
sess.welcome
sess.main_menu