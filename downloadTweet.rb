#!/usr/bin/env ruby

#Libraries
require 'twitter'
require_relative 'DataFrame'
require 'net/http'

#Options
max_download = 3
image_directory = "images/" #*must* have the slash in there (Windows or Mac format...)
search_term = "to:ProjectSplatter"

#Authentication
Twitter.configure do |config|
  config.consumer_key       = 'pdAOmtEwrA7VmPRQ7arX1A'
  config.consumer_secret    = 'daW6kyO2Kvk7DVJr3yHBwLgfUrQKzYJufAn4kOedvE'
  config.oauth_token        = '21875193-JAJqwH05O8JPGdq3oKQVVpMnSjgTOodV0aYHlOPTQ'
  config.oauth_token_secret = 'InpG9JFGIETApbG0Q6a61y67nJotCILAUitXxldWVc'
end

#Pull out the previously recorded tweets
# - make this more pleasant to read....
currentTweets = DataFrame.new({:lat=>[],:long=>[],:ID=>[],:user=>[],:timecode=>[],:text=>[],:image=>[]})
File.open("tweetLog.txt") do |f|
  f.each do |line|
    if line != "lat^long^ID^user^timecode^text^image"
      entry = line.chomp.split "^"
      currentTweets << {:lat=>[entry[0].to_f],:long=>[entry[1].to_f],:ID=>[entry[2].to_i],:user=>[entry[3]],:timecode=>[entry[4]],:text=>[entry[5]],:image=>[entry[6]]}
     end
  end
end

#Check to see if we need to do something else...

if ARGV[0]
  if ARGV[0] == 'stats'
    total = 0
    currentTweets[:lat].each do |lat|
      if lat > 0
        total += 1
      end
    end
      puts "Total tweets: #{currentTweets.nrow}"
      puts "Total geo-cached tweets: #{total}"
      fraction = (Float(total) / currentTweets.nrow)*100
      puts "... #{fraction.round(0)}% geo-cached"
  end
else
  #Pull out SilNet's recently sent messages
  tweets = Twitter.search(search_term, {:count=>max_download})
  #Search through for un-added 'silnet' tweets
  currentNew = 0
  finished = false
  tweets.results.each do |tweet|
    if not currentTweets[:ID].include? tweet.id
      currentNew += 1
      newTweet = {:text=>[tweet.text]}
      if tweet.geo
        newTweet[:lat] = [tweet.geo.coordinates[0]]
        newTweet[:long] = [tweet.geo.coordinates[1]]
      else
        newTweet[:lat] = [-99999.999]
        newTweet[:long] = [-99999.999]
      end
      newTweet[:user] = [tweet.from_user]
      newTweet[:ID] = [tweet.id]
      newTweet[:timecode] = [tweet.created_at]
      if !tweet.media.empty?
        newTweet[:image] = [image_directory + newTweet[:ID][0].to_s + ".jpg"]
        File.open(newTweet[:image][0], 'w') do |file|
          file.puts Net::HTTP.get(URI(tweet.media[0][:media_url]))
        end
      else
        newTweet[:image] = ["NONE"]
      end
      currentTweets << newTweet
    else
      finished = true
    end
  end
  
  #Check for possible errors (this could be written better with a while loop...)
  if not finished
    puts "Warning: there may be unrecorded tweets"
    puts "\t...is this the first time you've run this script?"
    puts "\t...if not, alter the 'max_download' parameter at the start of the scrpt"
  end

  #Write out new set of tweets
  if currentNew != 0
    puts "Read #{currentNew} new tweets; total tweets in memory #{currentTweets.nrow}"
    File.open("tweetLog.txt", 'w') do |f|
      f.write("lat^long^ID^user^timecode^text^image\n")
      currentTweets.each_row do |row|
        f.write(row[0].to_s + '^' + row[1].to_s + '^' + row[2].to_s + '^' + row[3] + '^' + row[4].to_s + '^' + row[5] + '^' + row[6] + "\n")
      end
    end
  else
    puts "No new tweets read; exiting"
  end
end
