require "bundler/setup"
Bundler.require
require_all 'app'
require 'sqlite3'
require 'active_record'
# require 'sinatra_activerecord'


ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "db/donations.db")

# DB = ActiveRecord::Base.connection

