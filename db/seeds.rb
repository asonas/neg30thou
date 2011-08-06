# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

screen_name = 'asonas'
user_id = 1
access_token = 12345
access_token_secret = 'abcd'
birthday = '1988-11-07'


Users.create(:screen_name => screen_name, :user_id => user_id, :access_token => access_token, :access_token_secret => access_token_secret, :birthday => birthday)
