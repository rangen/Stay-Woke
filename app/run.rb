require 'tty-prompt'
ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "db/donations.db")  
class StayWokeCLI
    attr_accessor :user
    attr_reader :heart
    def initialize
        @prompt = TTY::Prompt.new
        @heart = @prompt.decorate(@prompt.symbols[:heart] + ' ', :bright_magenta)
    end
    def welcome
      resp = @prompt.yes?('Welcome to Stay Woke! Is it your first time waking up?')
      resp ? new_user : find_user_name
      login
    end
    def new_user
        args = {}
        resp = @prompt.ask("We've been expecting you. It's never too late to wake up and find out what's going on. Staying woke takes daily practice and mindfulness.  Let's help you with that by setting up a user profile. If I need to ask you a question, what is your first name?")
        args[:first_name] = resp #logic check for one word
        resp = @prompt.ask("Thanks, #{args[:first_name]}.  We won't share your information to any third-party vendors (until we get Series A Funding, at least).  Is there a family name you'd like to use?")
        args[:last_name] = resp
        resp = @prompt.ask("In order to properly assist you #{args[:first_name]}, your adress will be required. This information will be kept completely private unless you try to break our code.")
        args[:address] = resp
        @user = User.create(args)
    end
    def find_user_name #displays users in database  and user can select one to attempt to log in with
       names = User.all.map do |n|
            "#{n[:first_name]} #{n[:last_name]}"
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
    end
end
# sess = StayWokeCLI.new
# sess.welcome