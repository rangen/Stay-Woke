require 'tty-prompt'



require "bundler/setup"
Bundler.require
require_all './../app/models'
require 'sqlite3'
require 'active_record'
# require 'sinatra_activerecord'


ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "./../db/donations.db")
ActiveRecord::Base.logger = nil
