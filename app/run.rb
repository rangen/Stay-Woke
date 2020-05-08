require 'tty-prompt'
require 'colorize'
require 'colorized_string'
require 'io/console'
require 'pry'

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "db/donations.db")  
class StayWokeCLI
    attr_accessor :user, :temp_user, :temp_active, :current_user, :current_committee, :current_politician, :term_height, :term_width, :term_options, :user_string
    attr_reader :heart
    def initialize
        @prompt = TTY::Prompt.new
        @heart = @prompt.decorate(@prompt.symbols[:heart] + ' ', :bright_magenta)
        @temp_active = false
        @term_height, @term_width = IO.console.winsize
        @term_options = {per_page: @term_height, cycle: true}
    end

    def welcome
      puts wake_up "Welcome to Stay Woke!"
      choices = {"Yes, open my eyes"=> :new, "No, I've been " + wake_up("woke") + " before"=>:existing, "I can't handle the truth..."=>:exit}
      resp = @prompt.ask("\nIs it your first time waking up?")
      
        case resp
        when :exit 
            return
        when :existing && User.first       #pretty genius && to stop login attempt to an empty db :)
            find_user_name
        else
            new_user
        end
        login
    end

    def new_user
        wipe
        args = @prompt.collect do
            key(:first_name).ask("We've been expecting you!\n \nIt's never too late to " + "wake up".light_blue.on_white + " and find out what's going on.\n \nStaying woke takes daily practice and mindfulness.\n \nLet's help you " + "stay woke".light_blue.on_white + " by setting up a user profile.\nFirst Name: ")
            key(:last_name).ask("Last name: ")
            key(:address).ask("\nPerfect.".green + "\nThe first step in " + "staying woke ".light_blue.on_white + " is getting informed.\nEnter your address to get started: ")
        end
        wipe
        seed_initial_data(args)        
        puts "Let's fucking do this! You'll need a password to access the system."
    end

    def find_user_name #displays users in database  and user can select one to attempt to log in with
        wipe
        names = User.all.map do |n|
            "#{n[:first_name]} #{n[:last_name]}"   #oh man, refactor...so bad
        end
        resp = @prompt.select("Select a user:", names)
        first, last = resp.split
        @user = User.find_by(first_name: first, last_name: last)# could use new variable of name = first + last 
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
        
        wipe
        choices = {"Show Information for My District" => :my_dist,
             "Show Information for Another District" => :other_dist,
             "Settings" => :settings, "Exit Stay Woke" => :exit
            }
       resp = @prompt.select(top_bar, choices, @term_options)
       case resp
        when :exit
            exit_program
        when :my_dist
            info_for_district
        when :other_dist
            retrieve_other_address_as_user_obj
            info_for_district
        when :settings
            settings
       end
    end

    def exit_program
        wipe
        puts "\n\n\n\nEnjoy your slumber. Come back when you're ready to be woke.".light_blue.on_white #colorify this shit Tisdale!
    end

    def retrieve_other_address_as_user_obj  #give user a chance to enter a new address to see data for; give option for random address with 'random'
        other_address = @prompt.ask("Enter a US address or 'random' to retrieve district info:", default: "1520 Marion Lincoln Park MI")
        @temp_active = true
        seed_initial_data(address: other_address)
        @current_user = @temp_user
    end

    def info_for_district
        user = @current_user
        wipe
        
        choices = user.politicians.reduce({}){|chc, pol| chc[pol.name] = pol; chc}
        choices["Return to Main Menu"] = :exit

        resp = @prompt.select(top_bar + "Info for My District", choices, @term_options)
        case resp
        when :exit
            main_menu
        else
            @current_politician = resp  #but holding the object! from the reduce
            show_committee_names
        end
    end
    
    def show_committee_names   #
        choices = {}
        wipe
        pol = @current_politician
        pol.committees.each_with_index {|com, idx| choices[com.name] = idx}
        choices["Return to District"] = :exit
        resp = @prompt.select(top_bar + "Select a Committee for #{pol.name}".purple, choices)

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
        wipe
        pct = (com.num_records_downloaded / com.num_records_available.to_f * 100).round(1).to_s.blue
        choices = [{name: "View Donations to This Committee", value: :continue},
        {name: "Return to Committee Names", value: :exit}]

        resp = @prompt.select(top_bar + pol.name + "\ncom.name + #{com.designation_full} a.k.a. #{com.alt_name}\n" +
            "Active: #{com.cycles_active}   Individual Donations: #{com.num_records_available}" + 
            "\nYou have downloaded #{com.num_records_downloaded}, or #{pct}% of them.", choices, @term_options)

        case resp
            when :continue
                view_donation_info
            when :exit
                show_committee_names
        end
    end

    def view_donation_info
        pol = @current_politician
        com = @current_committee
       choices = [{name: "View Donor Stats", value: :donor_stats},
        {name: "View Donation (random)", value: :random},
        {name: "Download More Records (#{com.num_records_available - com.num_records_downloaded} Available)", value: :download},
        {name: "Return to Committee Info", value: :exit}]

        resp = @prompt.select("Individual Contributions to #{com.name} (#{com.num_records_downloaded} downloaded)", choices, @term_options)
        case resp
        when :donor_stats
            donor_stats
        when :random
            view_random_donation
        when :download
            download_more_records
        when :exit
            show_committee_info
        end
    end

    def donor_stats

    end

    def view_random_donation

    end

    def download_more_records

    end

    def settings
        wipe
        choices = {"View My Account Settings" => :settings,
            "Change Address" => :change_address,
            "Change Password" => :change_pwd,
            "Delete Data"=>:delete_data,
            "Delete Account" => :delete_me,
            "About Stay Woke!".light_blue.on_white=>:about,
            "Return to Main Menu" => :exit
        }
        resp = @prompt.select(top_bar + "Account Settings".red, choices, @term_options)
            case resp
            when :about
                about_stay_woke
            when :settings
                view_my_account_settings
            when :delete_data
                delete_data
            when :delete_me
                delete_my_user_account  #works
            when :change_address
                change_address #works
            when :change_pwd 
                change_password #works
            when :exit
                main_menu
            end
    end

    def about_stay_woke
        wipe
        # choices = [{name: "", value: 0, disabled: ''},
        #     {name: , value: 0, disabled: ''},
        #     {name: , value: 0, disabled: ''},
        #     {name: , value: 0, disabled: ''},
        #     , value: 0, disabled: ''},
        
        
       

        # resp = @prompt.select("My Account Settings", choices, cycle: true)
        
        settings
    end

    def delete_data
        settings
    end

    def view_my_account_settings
        wipe
        choices = [{name: "User: #{@user.first_name} #{@user.last_name}  Woke Since: #{@user.created_at.strftime("%B %d %Y")}", value: 0, disabled: ''},
            {name: "Address: #{@user.address} #{@user.zip_code}  Password: " + @user.password, value: 0, disabled: ''},
            {name: "Domains: #{@user.politicians.pluck(:domain).uniq.join("***")}", value: 0, disabled: ''},
            {name: "Records Downloaded for My Politicians: #{User.first.politicians.sum{|pol| pol.committees.sum{|com| com.num_records_downloaded}}}", value: 0, disabled: ''},
            {name: "Return to Settings", value: 0}]
        resp = @prompt.select("My Account Settings", choices, @term_options)
        settings
    end

    def delete_my_user_account
        @user.destroy   #First let's prompt are you sure?   Remind them the politician records will remain, you are only deleting the user account
        @user, @temp_user, @temp_active, @current_user, @current_committee, @current_politician = [nil] * 6   #punt session variables but we can keep session open, keeping run.rb clean
        wipe
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

    def wipe
        system "clear"
    end

    def wake_up(str)
        str.light_blue.on_white
    end

    def top_bar
        left = "logged in: #{@user.first_name} #{@user.last_name}".red
        right = Time.now.strftime("%A %B %-d, %Y        %H:%M").blue + "\n"
         " " * (@term_width - (left.length + right.length) - 15) + left + " " * 10 + right
    end

    private

    def seed_initial_data(args)
        puts "Building your initial dataset....".red   #COLORIFY TISDALE
        hold_me = User.create(args)

        pong = hold_me.find_my_servants #attempt to get data for new address
        if !pong[:success]
            #let's do something with pong!  save it locally, Gmail...
            @temp_active ? @temp_user = hold_me : @user = hold_me
            return false
        end

        puts "Retrieving info about: ".blue + hold_me.politicians.pluck(:name).map{|x|x.green}.join("    ")
        hold_me.politicians.pluck(:candidate_id).each {|can| GetCandidateInfo.new(can).seek if Politician.find_by(candidate_id: can).committees.empty?}  #don't check if already checked
        hold_me.politicians.each do |pol|
            pol.committees.each {|com| GetCommitteeReceipts.new(com, true).seek if com.last_index.nil?} 
        end
        @temp_active ? @temp_user = hold_me : @user = hold_me
    end
end
# # #run.rb will start here  (maybe some require_relative statements idfk but just the below codes)
sess = StayWokeCLI.new
sess.wipe
sess.welcome
sess.main_menu

