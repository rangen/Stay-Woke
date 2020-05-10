class StayWokeCLI
    attr_accessor :user, :temp_user, :temp_active, :current_user, :current_committee, :current_politician, :term_height, :term_width, :term_options, :user_string
    attr_reader :heart, :patches

    def initialize
        puts "Loading latest version info from donmallory.tech ....".blue
        # sleep 3
        @prompt = TTY::Prompt.new
        @heart = @prompt.decorate(@prompt.symbols[:heart] + ' ', :bright_magenta)
        @temp_active = false
        @term_height, @term_width = IO.console.winsize
        @term_options = {per_page: @term_height, cycle: true}
        @@patches = JSONByURL.new("http://donmallory.tech/staywoke.json?c="+ Time.now.to_s.encode_via_uri).snag
    end

    def welcome
      puts wake_up "Welcome to Stay Woke!\n"
      choices = {"Yes, open my eyes\n"=> :new, "No, I've been woke before\n"=>:existing, "Exit, I just...I can't.."=>:exit}
      resp = @prompt.select("\n\nIs it your first time waking up?".light_yellow, choices, @term_options)
      
        case resp
        when :exit
            wipe
            return
        when :existing       
            if User.first.nil?
                wipe
                puts "No users found. Please create a new account. \n
                You think you've been " + wake_up("woke.") + "\n\n - You've actually been dreaming your whole life.  But it's not too late..."
                return
            end
            find_user_name
            login
        else
            new_user_name
            wipe
            puts "\nPerfect.".green + "\n\nThe first step in " + "staying woke ".light_blue.on_white + " is getting informed.\n\n" #text here keeps it out of bad address loop in first_address below
            add_first_address
            login
        end
    end

    def new_user_name
        wipe
        args = @prompt.collect do
            key(:first_name).ask("We've been expecting you!\n \nIt's never too late to and find out what's going on.\n \nStaying woke takes daily practice and mindfulness.\n \nLet's help you stay woke by setting up a user profile.\n".light_yellow + "\nFirst Name: ".green)
            key(:last_name).ask("\nLast name: ".green)
        end
        @user = User.new(args)  #Placed new address in separate function to enable easier looping when it fails
    end


    def add_first_address
        add = @prompt.ask("Enter your " + "address".green + " to get started: ")
        wipe
        puts "Checking address...".blue
        result = @user.check_address(add)
        
        if !result
            wipe
            puts "We couldn't find your servants based on that info. \n\n Please try typing the address with more specificity.".blue
            sleep 3
            wipe
            add_first_address
        else
            wipe #user instance was successfully saved in self.check_address  politician info also linked 
            puts "Address Valid! Now, let's do some digging...".blue
            sleep 2
        end
    end

    def find_user_name #displays users in database  and user can select one to attempt to log in with
        wipe
        choices = User.all.reduce({}){|chc, usr| chc[usr.first_name + " " + usr.last_name] = usr.id; chc}
        resp = @prompt.select("Select a User to Login:", choices, @term_options)
        
        @user = User.find(resp) 
    end

    def login
        #checks the newly loaded @user variable for a password.  if new user, create and exit w/ true.  if password, ask for password and rturn
        if @user.password.nil?
            resp = @prompt.mask("Please create a " + "password:".green, mask: @heart)
            @user.update(password: resp)
            main_menu
        else 
            resp = @prompt.mask("Please enter your " + "password:".green, mask: @heart)
            main_menu if resp == @user.password
            
        end
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
        resp = @prompt.select(top_bar + "Select a Committee for #{pol.name}".light_yellow, choices)

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
        pct = (com.num_records_downloaded / com.num_records_available.to_f * 100).round(1).to_s
        choices = [{name: "View Donations to This Committee", value: :continue},
        {name: "Return to Committee Names", value: :exit}]

        resp = @prompt.select(top_bar + pol.name.light_yellow + "\n\n#{com.name.light_blue} (#{com.designation_full}) a.k.a. #{com.alt_name}\n" +
            "\nActive: #{com.cycles_active}   Individual Donations: #{com.num_records_available.to_s.red}" + 
            "\n" + "You".light_blue.on_white +  "have downloaded #{com.num_records_downloaded}, or #{pct}% of them.\n", choices, @term_options)

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
        wipe
        donor_count = com.donations.map{|x| x.donor_id}.uniq.count
        total = com.donations.pluck(:amount).sum
        avg = ((total / donor_count.to_f).round(2)).to_s.green

       choices = [{name: "View Donation (random)", value: :random},
        {name: "Download More Records (#{com.num_records_available - com.num_records_downloaded} Available)", value: :download},
        {name: "Return to Committee Info", value: :exit}]

        resp = @prompt.select(top_bar + "\n" + "Schedule A ".green + "Contributions to #{com.name.light_yellow}" +
               "\n\n(data shown - #{com.num_records_downloaded} local records)".light_blue + 
               "\n\n" + "Unique Donors:".rjust(25) + "   #{donor_count}" +
               + "\n" + "Average Donation:".rjust(25) + "   $#{avg} per donor\n\n", choices, @term_options)

        case resp
        when :random
            view_random_donation
        when :download
            download_more_records
        when :exit
            show_committee_info
        end
    end
    

    def view_random_donation
        pol = @current_politician
        com = @current_committee
        wipe
        
       choices = [{name: "View Donation (random)", value: :random},
        {name: "Download More Records (#{com.num_records_available - com.num_records_downloaded} Available)", value: :download},
        {name: "Return to Committee Info", value: :exit}]

        resp = @prompt.select(top_bar + "\nDonation Earmarked for #{pol.name.light_yellow}" +
               "\n(via  #{com.name}" + "\n-------------------------------------------------------".light_yellow + 
               "\n\n" + "Donors:".rjust(25) + "   " +
                "\nAverage Donation:".rjust(25) + "", choices, @term_options)

       
            view_donation_info
        
    end

    def download_more_records
        pol = @current_politician
        com = @current_committee
        resp = @prompt.slider("How many " + "new records".red + " would you like to download?\nPlease check with your " + "FEC administrator".light_blue + " for hourly API call limits.", max: 3000, step: 150, default: 300)
        result = GetCommitteeReceipts.new(com, {:stop_after => resp}).seek
        com.reload
        view_donation_info
    end

    def settings
        wipe
        choices = {"View My Account Settings" => :view_my_account_settings,
            "Change Address" => :change_address,
            "Change Password" => :change_password,
            "Delete Data"=>:delete_data,
            "Delete Account" => :delete_my_user_account,
            "About Stay Woke!".light_blue.on_white=>:about_stay_woke,
            "Return to Main Menu" => :main_menu
        }
        resp = @prompt.select(top_bar + "Account Settings".red, choices, @term_options)
        self.send(resp)
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
        view = top_bar + "\nViewing Account Settings\n".light_yellow + "\nUser: ".light_blue + "#{@user.first_name} #{@user.last_name}" + "      Woke Since:".light_blue + "  #{@user.created_at.strftime('%B %d %Y')}\n" +
                   "\nAddress:".light_blue + " #{@user.address} #{@user.zip_code}  "  +  "  Password:".red + " #{@user.password}" +
                   "\n\nDomains:".light_blue + "  #{@user.politicians.pluck(:domain).uniq.join(" *  *  * ".light_yellow)}" +
                   "\n\n" + "Donations".green +  " I'm " + "Woke".light_blue.on_white + " to: #{User.first.politicians.sum{|pol| pol.committees.sum{|com| com.num_records_downloaded}}} federal election contributions for my candidates " + "and counting...".light_blue
        choices = {"Return to Account Settings": 0}
        resp = @prompt.select(view, choices, @term_options)
        settings
    end

    def delete_my_user_account
        @user.destroy.politicians.reset   #First let's prompt are you sure?   Remind them the politician records will remain, you are only deleting the user account
        
        @user, @temp_user, @temp_active, @current_user, @current_committee, @current_politician = [nil] * 6   #punt session variables but we can keep session open, keeping run.rb clean
        wipe
        puts "Account deleted. Don't feed the hand that bites you.".red
    end

    def change_address
        resp = @prompt.ask("New Address: ('cancel' to abort)")
        if resp == "cancel"
            view_my_account_settings
            return   #important!  to not execute following code when user gets the kick
        end

        wipe
        puts "Verifying address so we can connect to your servants...".blue
        result = @user.check_address(resp)  #ask the user instance to verify valid address.  return false here if fails to draw 3 politicians
        
        if !result
            wipe 
            puts "We couldn't verify that address. Please email system admin dmm333@gmail.com if this problem persists".blue
            sleep 4
            view_my_account_settings
            return #Kick
        end
        #user is changing their address    
        args = @user.attributes
        @user.destroy
        @user.politicians.reset #clear ActiveRecord cache to destroy associations, data on pols persists, but association gone and user is deleted
    
        
        result[:politicians].each {|pol| @user.politicians << pol}

        
        @user.destroy
        @user.politicians.reset #clear ActiveRecord cache to destroy associations
        
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

    def self.patches
        @@patches
    end

    private

    def address_update(args)
        hold_me = User.create(args)  #No, not yet    check address first, duh

        pong = hold_me.find_my_servants #attempt to get data for new address
       

        hold_me.politicians.pluck(:candidate_id).each {|can| GetCandidateInfo.new(can).seek if Politician.find_by(candidate_id: can).committees.empty?}  #don't check if already checked
        hold_me.politicians.each do |pol|
            pol.committees.each {|com| GetCommitteeReceipts.new(com, {initial_download: true}).seek if com.last_index.nil?} 
        end
        @temp_active ? @temp_user = hold_me : @user = hold_me
    end
end