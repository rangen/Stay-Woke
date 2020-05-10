ENV["SINATRA_ENV"] ||= "staywoke"

require "bundler/setup"
Bundler.require(:default, ENV['SINATRA_ENV'])


require_all "app"
require_all "lib"
require_relative "keys.rb"

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "db/#{ENV['SINATRA_ENV']}.db")
ActiveRecord::Base.logger = nil

Hash.use_dot_syntax = true

