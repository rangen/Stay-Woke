require "bundler/setup"
Bundler.require
require_all 'app'
require 'sqlite3'
require 'active_record'
# require 'sinatra_activerecord'


ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "db/donations.db")

    # API_KEY = {:fec=> "QcTjwDy06yeUoGj5I8ZKkXzAYBHA8cReddzO196M", :google=> "AIzaSyATHZvtmoZF0nhrPZumDtPQzeqgo4jw8Mo"}
    API_KEY = "QcTjwDy06yeUoGj5I8ZKkXzAYBHA8cReddzO196M"
# DB = ActiveRecord::Base.connection

