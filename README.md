tweetSplat - Downloading Tweets for ProjectSplatter
===================================================
Will Pearse (wdpearse@umn.edu)

##Overview
This is intended to be a quick and easy way to download and geo-reference sightings of roadkill for Project Splatter. However, it should also work for anyone who wants to download tweets sent to them, and figure out where those people were when they sent those tweets/where they are now.

##Requirements
* Ruby (tested on version 2.0.0)
* Twitter and Geocoder gems (something like 'gem install twitter' and 'gem install geocoder' should do the trick!)

##Usage
1. Look inside *downloadTweet.rb* and *geocode.rb*; you need to put in your own authentication details ([go here](https://dev.twitter.com/apps) and create a new application)
2. Change *search_term* to whatever account you're trying to search in *downloadTweet.rb*
3. Run the download with something like *ruby downloadTweet.rb*
4. The file *tweetLog.txt* now contains your tweets, with each element separated by the character "^". Those tweets have the GPS co-ordinates of where each tweet was sent (if from a GPS-enabled device). Any images associated with the tweets are in the folder 'images'.
5. To get GPS co-ordinates on the basis of something else, make a copy of *tweetLog.txt* called *tweetLogGeocode.txt* but add another column at the end called *geocode*. That column should contain 'NOTHING' to do nothing, 'USER' to get the lat/long location of where that user says they are, or some other text string (probably from the text of the tweet) that you want to find out the lat/long location of
6. Run something like *ruby geocode.rb*
7. After a long time, the file *tweetLogGeocoded.txt* contains all the geocoded tweets.

##NOTES
* It is simple to change the file names everything's written out to; look inside the Ruby scripts
* The script, by default, only downloads the last 40 tweets in a search. For most purposes, this will be fine. If it doesn't get all your tweets on a search (for instance, the first time you run the program), you'll get a warning
* Make regular backups of your output files.
* The script is using *tweetLog.txt* as a record of what tweets were there the last time you searched; it adds tweets into this file when you search again
* Don't repeatedly call *geocode.rb* on a file where you've already got the information you want; set known tweets to 'NOTHING' in the 'geocode' column
* I use the character '^' to split the entries of the output because ',' is so common on Twitter. The line *data <- read.csv("tweetLog.txt", sep="^")* will happily load the data in its present form into R
* Examples of the kind of output to expect are inside the 'example' folder
* *tweetLog.txt* must exist when the program runs. Sorry!
* While *DataFrame.rb* is semi-unit-tested, nothing else is. Sorry!


##License
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. The following restriction to the GNU GPL applies: contact the author of this program (wdpearse@umn.edu) for a suitable citation when using the code.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
