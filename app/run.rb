require 'tty-prompt'

class StayWokeCLI

    def initialize
        @prompt = TTY::Prompt.new
    end

    def welcome
        @prompt.yes?('Welcome to Stay Woke! Is it your first time waking up?')
    end
    
    def new_user
        args = {}
        
        resp = @prompt.ask("We've been expecting you. It's never too late to wake up and find out what's going on. Staying woke takes daily practice and mindfulness.  Let's help you with that by setting up a user profile. If I need to ask you a question, what is your first name?")
        args[:first_name] = resp #logic check for one word
        
        resp = @prompt.ask("Thanks, #{args[:first_name]}.  We won't share your information to any third-party vendors (until we get Series A Funding, at least).  Is there a given name you'd like to use?")
        args[:last_name] = resp

        

        puts args
    end

    def login
        #load Users in database (Make sure they have address?)
        resp = load_users_and_prompt
        #check and branch to new_user or set instance variables

    end

    def load_users_and_prompt

    end


end


sess = StayWokeCLI.new
resp = sess.welcome

resp ? sess.new_user : sess.login