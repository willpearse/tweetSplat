#!/usr/bin/env ruby

#Libraries
require 'geocoder'
require 'twitter'
require_relative 'DataFrame'

#Parameters
sleep_time = 5 #How long to delay between searches

#Authentication
Twitter.configure do |config|
  config.consumer_key       = 'pdAOmtEwrA7VmPRQ7arX1A'
  config.consumer_secret    = 'daW6kyO2Kvk7DVJr3yHBwLgfUrQKzYJufAn4kOedvE'
  config.oauth_token        = '21875193-JAJqwH05O8JPGdq3oKQVVpMnSjgTOodV0aYHlOPTQ'
  config.oauth_token_secret = 'InpG9JFGIETApbG0Q6a61y67nJotCILAUitXxldWVc'
end

#Pull out the previously recorded tweets
currentTweets = DataFrame.new({:lat=>[],:long=>[],:ID=>[],:user=>[],:timecode=>[],:text=>[],:image=>[],:geocode=>[]})
File.open("tweetLogGeocode.txt") do |f|
  f.each do |line|
    if line != "lat^long^ID^user^timecode^text^image^geocode"
      entry = line.chomp.split "^"
      currentTweets << {:lat=>[entry[0].to_f],:long=>[entry[1].to_f],:ID=>[entry[2].to_i],:user=>[entry[3]],:timecode=>[entry[4]],:text=>[entry[5]],:image=>[entry[6]],:geocode=>[entry[7]]}
     end
  end
end

#Loop through tweets looking for requested action
currentTweets[:geocode].each_with_index do |action, i|
  sleep sleep_time
  if action != "NOTHING"
    if action == "USER"
      if not currentTweets[:user][i].empty?
        user = Twitter.user currentTweets[:user][i]
        search = Geocoder.search(user.location)[0]
        unless search.nil?
          currentTweets[:lat][i], currentTweets[:long][i] = search.coordinates
        end
      end
    else
      search = Geocoder.search(action)[0]
      unless search.nil?
        currentTweets[:lat][i], currentTweets[:long][i] = search.coordinates
      end
    end
  end
end

#Write out the new file
File.open("tweetLogGeocoded.txt", 'w') do |f|
  f.write("lat^long^ID^user^timecode^text^image^geocode\n")
  currentTweets.each_row do |row|
    f.write(row[0].to_s + '^' + row[1].to_s + '^' + row[2].to_s + '^' + row[3] + '^' + row[4].to_s + '^' + row[5] + '^' + row[6] + row[7] + "\n")
  end
end
