#!/usr/bin/env ruby

require_relative '../config/environment.rb'

sess = StayWokeCLI.new
sess.wipe
sess.welcome

