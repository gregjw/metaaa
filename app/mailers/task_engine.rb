class TaskEngine < ActionMailer::Base
  def mandrill_client
  	@mandrill_client ||= Mandrill::API.new "B82Ad5NwZCq6MUUrJHdmqQ"
  end

  def grow_tweet(parameter1, parameter2, parameter3, parameter4, parameter5)
        require 'rufus-scheduler'
        require 'yaml'

        @twitter_access_token = parameter1
        @twitter_secret = parameter2
        hashtag = parameter3
        message = parameter4
        message = message + " - via @usemeta"
        user = parameter5
        task_status = user.read_attribute(:task_status)
        user.update_attribute(:reachcount, 0)

        scheduler = Rufus::Scheduler.new
        i = 1

        scheduler.every '60s' do
          twitter = Twitter::REST::Client.new do |config|
            config.consumer_key        = "8hEQiXtfU9vkGhNBylHICITLf"
            config.consumer_secret     = "TjAEi7ipw0EBXalGNDZODsSqa8FDdSdv6c2migRiZs7ryeohmg"
            config.access_token        = "#{@twitter_access_token}"
            config.access_token_secret = "#{@twitter_secret}"
          end

          curation = "#{i} - @usemeta"
          lists_array = []
          follower_flag_array = []

          twitter.lists.each do |item|
            lists_array.push(item)
          end

          x = 0
          z = 0
          count = 0
          follower_flag = false
          flag = false

          follower_array = user.read_attribute(:follower_array)
          follower_array = YAML.load(follower_array)
          username = twitter.followers.first.screen_name

          while z < follower_array.count
            puts username
            puts follower_array[z]
            if username == follower_array[z]
              follower_flag_array.push("true")
            else 
              follower_flag_array.push("false")
            end
            z += 1
          end

          z = 0

          while z < follower_flag_array.count
            if follower_flag_array[z] == "true"
              flag = true
            end
            z += 1
          end
          
          if flag != true
            twitter.create_direct_message(username, message)
            follower_array.push(username)
            pushing = follower_array
            user.update_attribute(:follower_array, pushing)
          end

          match_array = []
          flag = false
          z = 0
          printing = 0

          while x < lists_array.count
            if curation == lists_array[x].name
              match_array.push("true")
              puts "true"
              if lists_array[x].member_count < 4999
                listid = lists_array[x]

                twitter.search("#{hashtag}", result_type: "recent").take(1).collect do |tweet|
                  userid = tweet.user
                  twitter.add_list_member(listid, userid)
                  reach = user.read_attribute(:reachcount)
                  reach = reach + 1
                  user.update_attribute(:reachcount, reach)
                end
              else 
                i += 1
                twitter.create_list("#{curation}")
                puts "Success: Created #{curation}"
              end
            else
              match_array.push("false")
              puts "false"
            end
            x += 1
          end

          while z < match_array.count
            if match_array[z] == "true"
              flag = true
            end
            z += 1
          end

          if flag != true
            twitter.create_list("#{curation}")
            puts "Success at flag: Created #{curation}"
          end
        end
  end

  def analyse_tweet(parameter1, parameter2, parameter3)
        require 'rufus-scheduler'

        @twitter_access_token = parameter1
        @twitter_secret = parameter2
        user = parameter3
        task_status = user.read_attribute(:task_status)

        twitter = Twitter::REST::Client.new do |config|
          config.consumer_key        = "8hEQiXtfU9vkGhNBylHICITLf"
          config.consumer_secret     = "TjAEi7ipw0EBXalGNDZODsSqa8FDdSdv6c2migRiZs7ryeohmg"
          config.access_token        = "#{@twitter_access_token}"
          config.access_token_secret = "#{@twitter_secret}"
        end
        
        i = 0
        timeline = twitter.user_timeline
        count = twitter.user_timeline.count
        data = Array.new

        while i < count
          a = Time.now.strftime("%Y-%m-%d")
          b = timeline[i].created_at.strftime("%Y-%m-%d")
          a = Date.parse(a)
          b = Date.parse(b)
          
          sum = (a-b)

          puts "Time now : #{a}"
          puts "Time then : #{b}"
          puts "Sum : #{sum}"

          if sum < 1
            data.push(timeline[i])
          end

          i = i + 1
        end

        i = 0
        totalretweets = 0
        totalfavourites = 0

        while i < data.size
          puts "Text: #{data[i].text}"
          totalretweets = totalretweets + data[i].retweet_count
          totalfavourites = totalfavourites + data[i].favorite_count
          i = i + 1
        end

        q = data.size
        r = totalretweets 
        f = totalfavourites

        if q == 0
          q = 1
        end

        # METASCORE
        metascore = (q * ((r+f)/0.17)).to_i

        # AVERAGE RETWEETS
        averager = totalretweets / q

        # AVERAGE FAVOURITES
        averagef = totalfavourites / q

        averager_status = user.read_attribute(:data_averager)
        averagef_status = user.read_attribute(:data_averagef)
        metascore_status = user.read_attribute(:data_metascore)
        
        if averager_status == nil
          array = [0,0,0,0,0,0,0]
          array = array.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '')
          user.update_attribute(:data_averager, "#{array}")
        elsif averagef_status == nil
          array = [0,0,0,0,0,0,0]
          array = array.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '')
          user.update_attribute(:data_averagef, "#{array}")
        elsif metascore_status == nil
          array = [0,0,0,0,0,0,0]
          array = array.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '')
          user.update_attribute(:data_metascore, "#{array}")
        end

        averager_status = user.read_attribute(:data_averager)
        averager_array = "#{averager_status}".split(", ").map(&:to_i)

        averagef_status = user.read_attribute(:data_averagef)
        averagef_array = "#{averagef_status}".split(", ").map(&:to_i)

        metascore_status = user.read_attribute(:data_metascore)
        metascore_array = "#{metascore_status}".split(", ").map(&:to_i)

        time = Time.new
        day = time.wday
        user.update_attribute(:todayrt, totalretweets)
        user.update_attribute(:todayfv, totalfavourites)
        user.update_attribute(:todayactivity, count)

        if day == 0
          averager_array[6] = totalretweets
          averagef_array[6] = totalfavourites
          metascore_array[6] = metascore
        elsif day == 1
          averager_array[0] = totalretweets
          averagef_array[0] = totalfavourites
          metascore_array[0] = metascore
        elsif day == 2
          averager_array[1] = totalretweets
          averagef_array[1] = totalfavourites
          metascore_array[1] = metascore
        elsif day == 3
          averager_array[2] = totalretweets
          averagef_array[2] = totalfavourites
          metascore_array[2] = metascore
        elsif day == 4
          averager_array[3] = totalretweets
          averagef_array[3] = totalfavourites
          metascore_array[3] = metascore
        elsif day == 5
          averager_array[4] = totalretweets
          averagef_array[4] = totalfavourites
          metascore_array[4] = metascore
        elsif day == 6
          averager_array[5] = totalretweets
          averagef_array[5] = totalfavourites
          metascore_array[5] = metascore
        end

        averager_array = averager_array.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '')
        averagef_array = averagef_array.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '')
        metascore_array = metascore_array.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '')

        user.update_attribute(:data_averager, "#{averager_array}")
        user.update_attribute(:data_averagef, "#{averagef_array}")
        user.update_attribute(:data_metascore, "#{metascore_array}")

        averager_status = user.read_attribute(:data_averager)
        averagef_status = user.read_attribute(:data_averagef)
        metascore_status = user.read_attribute(:data_metascore)

        scheduler = Rufus::Scheduler.new

        scheduler.every '30s' do
            twitter = Twitter::REST::Client.new do |config|
              config.consumer_key        = "8hEQiXtfU9vkGhNBylHICITLf"
              config.consumer_secret     = "TjAEi7ipw0EBXalGNDZODsSqa8FDdSdv6c2migRiZs7ryeohmg"
              config.access_token        = "#{@twitter_access_token}"
              config.access_token_secret = "#{@twitter_secret}"
            end
            
            i = 0
            tick = 0
            timeline = twitter.user_timeline
            count = twitter.user_timeline.count
            data = Array.new

            while i < count
              a = Time.now.strftime("%Y-%m-%d")
              b = timeline[i].created_at.strftime("%Y-%m-%d")
              a = Date.parse(a)
              b = Date.parse(b)
              
              sum = (a-b).to_i

              if sum < 1
                data.push(timeline[i])
                tick = tick + 1
              end

              i = i + 1
            end

            i = 0
            totalretweets = 0
            totalfavourites = 0

            while i < data.size
              puts "Text: #{data[i].text}"
              totalretweets = totalretweets + data[i].retweet_count
              totalfavourites = totalfavourites + data[i].favorite_count
              i = i + 1
            end

            q = data.size
            r = totalretweets 
            f = totalfavourites

            if q == 0
              q = 1
            end

            # METASCORE
            metascore = (q * ((r+f)/0.17)).to_i

            # AVERAGE RETWEETS
            averager = totalretweets / q

            # AVERAGE FAVOURITES
            averagef = totalfavourites / q

            averager_status = user.read_attribute(:data_averager)
            averagef_status = user.read_attribute(:data_averagef)
            metascore_status = user.read_attribute(:data_metascore)
            
            if averager_status == nil
              array = [0,0,0,0,0,0,0]
              array = array.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '')
              user.update_attribute(:data_averager, "#{array}")
            elsif averagef_status == nil
              array = [0,0,0,0,0,0,0]
              array = array.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '')
              user.update_attribute(:data_averagef, "#{array}")
            elsif metascore_status == nil
              array = [0,0,0,0,0,0,0]
              array = array.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '')
              user.update_attribute(:data_metascore, "#{array}")
            end

            averager_status = user.read_attribute(:data_averager)
            averager_array = "#{averager_status}".split(", ").map(&:to_i)

            averagef_status = user.read_attribute(:data_averagef)
            averagef_array = "#{averagef_status}".split(", ").map(&:to_i)

            metascore_status = user.read_attribute(:data_metascore)
            metascore_array = "#{metascore_status}".split(", ").map(&:to_i)

            time = Time.new
            day = time.wday
            user.update_attribute(:todayrt, totalretweets)
            user.update_attribute(:todayfv, totalfavourites)
            user.update_attribute(:todayactivity, tick)

            if day == 0
              averager_array[6] = totalretweets
              averagef_array[6] = totalfavourites
              metascore_array[6] = metascore
            elsif day == 1
              averager_array[0] = totalretweets
              averagef_array[0] = totalfavourites
              metascore_array[0] = metascore
            elsif day == 2
              averager_array[1] = totalretweets
              averagef_array[1] = totalfavourites
              metascore_array[1] = metascore
            elsif day == 3
              averager_array[2] = totalretweets
              averagef_array[2] = totalfavourites
              metascore_array[2] = metascore
            elsif day == 4
              averager_array[3] = totalretweets
              averagef_array[3] = totalfavourites
              metascore_array[3] = metascore
            elsif day == 5
              averager_array[4] = totalretweets
              averagef_array[4] = totalfavourites
              metascore_array[4] = metascore
            elsif day == 6
              averager_array[5] = totalretweets
              averagef_array[5] = totalfavourites
              metascore_array[5] = metascore
            end

            averager_array = averager_array.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '')
            averagef_array = averagef_array.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '')
            metascore_array = metascore_array.to_s.gsub(/\"/, '\'').gsub(/[\[\]]/, '')

            user.update_attribute(:data_averager, "#{averager_array}")
            user.update_attribute(:data_averagef, "#{averagef_array}")
            user.update_attribute(:data_metascore, "#{metascore_array}")

            averager_status = user.read_attribute(:data_averager)
            averagef_status = user.read_attribute(:data_averagef)
            metascore_status = user.read_attribute(:data_metascore)

            if task_status == "INACTIVE"
              scheduler.shutdown
            end
        end
  end

  def schedule_tweet(parameter1, parameter2, parameter3, parameter4, parameter5, parameter6)
    require 'rufus-scheduler'

    @twitter_access_token = parameter1
    @twitter_secret = parameter2
    tweet = parameter3
    time = parameter4
    gmt = parameter5
    user = parameter6
    current = user.read_attribute(:tweet)

    if gmt == '-12'
      adjusted_time = (time.to_time + 7.hours)
    elsif gmt == '-11'
      adjusted_time = (time.to_time + 6.hours)
    elsif gmt == '-10'
      adjusted_time = (time.to_time + 5.hours)
    elsif gmt == '-9'
      adjusted_time = (time.to_time + 4.hours)
    elsif gmt == '-8'
      adjusted_time = (time.to_time + 3.hours)
    elsif gmt == '-7'
      adjusted_time = (time.to_time + 2.hours)
    elsif gmt == '-6'
      adjusted_time = (time.to_time + 1.hours)
    elsif gmt == '-5'
      adjusted_time = (time.to_time + 0.hours)
    elsif gmt == '-4'
      adjusted_time = (time.to_time - 1.hours)
    elsif gmt == '-3'
      adjusted_time = (time.to_time - 2.hours)
    elsif gmt == '-2'
      adjusted_time = (time.to_time - 3.hours)
    elsif gmt == '-1'
      adjusted_time = (time.to_time - 4.hours)
    elsif gmt == '+0'
      adjusted_time = (time.to_time - 5.hours)
    elsif gmt == '+1'
      adjusted_time = (time.to_time - 6.hours)
    elsif gmt == '+2'
      adjusted_time = (time.to_time - 7.hours)
    elsif gmt == '+3'
      adjusted_time = (time.to_time - 8.hours)
    elsif gmt == '+4'
      adjusted_time = (time.to_time - 9.hours)
    elsif gmt == '+5'
      adjusted_time = (time.to_time - 10.hours)
    elsif gmt == '+6'
      adjusted_time = (time.to_time - 11.hours)
    elsif gmt == '+7'
      adjusted_time = (time.to_time - 12.hours)
    elsif gmt == '+8'
      adjusted_time = (time.to_time - 13.hours)
    elsif gmt == '+9'
      adjusted_time = (time.to_time - 14.hours)
    elsif gmt == '+10'
      adjusted_time = (time.to_time - 15.hours)
    elsif gmt == '+11'
      adjusted_time = (time.to_time - 16.hours)
    elsif gmt == '+12'
      adjusted_time = (time.to_time - 17.hours)
    end

    if current == ""
      i = 0
      data = '"tweets' + "#{i}" + '": [{ "content": "' + "#{tweet}" + '", 
              "time": "' + "#{time}" '" }]'
      update = "#{data}"
      user.update_attribute(:tweet, update)
      user.update_attribute(:tweet_quantity, i)
    else
      i = user.read_attribute(:tweet_quantity)
      i = i + 1
      data = '"tweets' + "#{i}" + '": [{ "content": "' + "#{tweet}" + '", 
              "time": "' + "#{time}" '" }]'
      update = "#{current},\n #{data}"
      user.update_attribute(:tweet, update)
      user.update_attribute(:tweet_quantity, i)
    end 


    scheduler = Rufus::Scheduler.new

    scheduler.at "#{adjusted_time}" do 
      twitter = Twitter::REST::Client.new do |config|
        config.consumer_key        = "8hEQiXtfU9vkGhNBylHICITLf"
        config.consumer_secret     = "TjAEi7ipw0EBXalGNDZODsSqa8FDdSdv6c2migRiZs7ryeohmg"
        config.access_token        = "#{@twitter_access_token}"
        config.access_token_secret = "#{@twitter_secret}"
      end
      
      twitter.update("#{tweet}")
    end
  end

  # MORNING WEATHER FORECAST
  def task1(parameter1, parameter2, parameter3, task, user)
  	require 'open_weather'
    require 'rufus-scheduler'

    scheduler = Rufus::Scheduler.new

    scheduler.every '10s' do 

      if user.following?(task) == true
      	email = parameter1
        city = parameter2
        country = parameter3

      	options = { units: "metric", APPID: "dc17fdf256992988f1b41458821ada1e" }
      	data = OpenWeather::Current.city("#{city}, #{country}", options)
      	filter1a = data["weather"]
      	filter1b = filter1a[0]
      	type = filter1b["main"]

      	filter2a = data["main"] 
      	mintemp = filter2a["temp_min"]
      	maxtemp = filter2a["temp_max"]
        
        day = Date.today.strftime("%A")
        
      	template_name = "task-1-weather-forecast"
      	template_content = []

        if type == 'Clear'
          if day == 'Monday'
            image = "http://i.imgur.com/hcfHP5m.jpg"
          elsif day == 'Tuesday'
            image = "http://i.imgur.com/0LjOMRy.jpg"
          elsif day == 'Wednesday'
            image = "http://i.imgur.com/vdoYzIZ.jpg"
          elsif day == 'Thursday'
            image = ""
          elsif day == 'Friday'
            image = ""
          elsif day == 'Saturday'
            image = ""
          elsif day == 'Sunday'
            image = "http://i.imgur.com/hcfHP5m.jpg"
          end
        elsif type == 'Rain' 
          if day == 'Monday'
            image = "http://i.imgur.com/rToCdqY.jpg"
          else
            image = "http://i.imgur.com/rToCdqY.jpg"
          end
        end
          
      	message = {
          	to: [{email: "#{email}"}], 
          	from: "greg@metaaa.org", 
          	subject: "Welcome to Meta, #{email}", 
          	global_merge_vars: [
          				{name: "weatherType", content: "#{type}"},
          				{name: "weatherMinimum", content: "#{mintemp}"},
          				{name: "weatherMaximum", content: "#{maxtemp}"},
                  {name: "imageEmbed", content: "#{image}"}
          			]
          }

        mandrill_client.messages.send_template template_name, template_content, message
      else
        scheduler.shutdown
      end
    end
  end 

  # POCKET TO EVERNOTE (REMOVE OR REPLACE?)
  def task2(parameter1, task, user)
    require 'rufus-scheduler'

    @access_token = parameter1

    scheduler = Rufus::Scheduler.new

    scheduler.every '10s' do 
      if user.following?(task) == true
        require "thrift/types"

        # EVERNOTE CONNECTION
          evernoteHost = "sandbox.evernote.com"
          userStoreUrl = "https://#{evernoteHost}/edam/user"
          noteStoreUrlBase = "https://#{evernoteHost}/edam/note/"

          noteStoreUrl = noteStoreUrlBase + @access_token.params[:edam_shard]
          noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
          noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
          noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)

        # POCKET CONNECTION

        begin
          notebook = Evernote::EDAM::Type::Notebook.new()
          notebook.name = "Meta"

          noteStore.createNotebook(@access_token.token, notebook)
        rescue 
          list = noteStore.listNotebooks(@access_token.token)
          i = list.length

          i.times do |j|
            notebook = list[j].name
 
            if notebook == "Meta"
              guid = list[j].guid
              puts "Token: #{@access_token.token}"
              puts "GUID: #{guid}"

              our_note = Evernote::EDAM::Type::Note.new()
              our_note.title = 'Test'
              our_note.content = '<?xml version="1.0" encoding="UTF-8"?>
              <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
              <en-note><h1>Hello, world</h1></en-note>'
              our_note.notebookGuid = guid

              noteStore.createNote(@access_token.token, our_note)
            end
          end
        end
      else
         scheduler.shutdown
      end
    end
  end 

  # FAVOURITE TWEETS WITH HASHTAG
  # AUTOMATICALLY DM ANYONE WHO TWEETS A HASHTAG
  def task3(parameter1, parameter2, parameter3, task, user)
    require 'rufus-scheduler'

    @twitter_access_token = parameter1
    @twitter_secret = parameter2
    track = parameter3
    
    scheduler = Rufus::Scheduler.new

    scheduler.every '2m' do 

      if user.following?(task) == true
        twitter = Twitter::REST::Client.new do |config|
          config.consumer_key        = "8hEQiXtfU9vkGhNBylHICITLf"
          config.consumer_secret     = "TjAEi7ipw0EBXalGNDZODsSqa8FDdSdv6c2migRiZs7ryeohmg"
          config.access_token        = "#{@twitter_access_token}"
          config.access_token_secret = "#{@twitter_secret}"
        end
        
        twitter.search("#{track}", result_type: "recent").take(3).collect do |tweet|
          puts "#{tweet.user.screen_name}: #{tweet.text} #{tweet.id}"
          twitter.favorite("#{tweet.id}")
        end
      else
        scheduler.shutdown
      end
    end
  end 

  # NYT TO INSTAPAPER
  def task4(parameter1, parameter2, task, user)
    require 'rufus-scheduler'

    scheduler = Rufus::Scheduler.new

    scheduler.every '6h' do 
      if user.following?(task) == true

        username = parameter1
        password = parameter2

        get = RestClient.get 'http://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/1.json?offset=20&api-key=8c5386d2003eff4d2cfd0fb7f516fd3c%3A13%3A72607246'
        parse = JSON.parse(get)
        one = parse['results']
        two = one[0]
        three = two['url']

        title = two['title']
        https_url = three.gsub("\\", '')

        InstaPush.connect "#{username}", "#{password}" do
          add "#{https_url}"
        end
      else
        scheduler.shutdown
      end
    end
  end

  # INSTAGRAM TO DROPBOX
  def task5(parameter1, parameter2, parameter3, task, user)
    require 'rufus-scheduler'

    @instagram_access_token = parameter1
    @dropbox_access_token = parameter2
    @dropbox_secret = parameter3

    image_array = []
    flag = true
    scheduler = Rufus::Scheduler.new

    scheduler.every '10m' do
      instagram = Instagram.client(:access_token => "#{@instagram_access_token}")
      client = Dropbox::API::Client.new :token => @dropbox_access_token, :secret => @dropbox_secret

      if user.following?(task) == true
        feed = instagram.user_liked_media
        caption = []
        link = []
        time = []
        array = []

        for media_item in feed
          caption.push(media_item.caption)
          link.push(media_item.link)
          time.push(media_item.created_time)
          array.push(media_item.images.standard_resolution.url)
        end

        description = caption[0]
        url = link[0]
        image = array[0]
        created_time = time[0]
        created_time = Time.strptime("#{created_time}",'%s')

        count = image_array.count
        i = 0

        puts "Count: #{count}"
        puts "Image: #{image}"

        if count > 0
          while i < count
            if image != image_array[i]
              flag = true
            else
              flag = false
            end
            i = i + 1
          end
        else
          client.upload "#{created_time}.png", open("#{image}")
          image_array.push("#{image}")
        end

      else
        scheduler.shutdown
      end
    end
  end

  # EMAIL ME DAILY WITH A NEW SPOTIFY SONG
  def task6(parameter1, task, user)
    require 'rufus-scheduler'

    scheduler = Rufus::Scheduler.new

    scheduler.every '10s' do 

      if user.following?(task) == true
        email = parameter1

        client_id = "c94843e648354545961a3cf45708ae75"
        client_secret = "10281d6d6c294526ad7c0ba17d87e43d"
        user_id = "gregjwww"
        playlist_id = "47GJYYiWS8uBX4kvcEe2EH"

        RSpotify.authenticate("#{client_id}", "#{client_secret}")
        playlist = RSpotify::Playlist.find("#{user_id}", "#{playlist_id}")
        size = playlist.tracks.size
        tracks = []

        playlist.tracks.each do |track|
          tracks.push(track.id)
        end

        song = tracks.sample

        template_name = "task-6-spotify-suggestion"
        template_content = []

        auth = RestClient.get "https://api.spotify.com/v1/tracks/#{song}"
        get = JSON.parse(auth)
        name = get["name"]

        link = "https://open.spotify.com/track/#{song}"

        album = get["album"]
        image1 = album["images"]
        image2 = image1[0]
        image = image2["url"]

        message = {
          to: [{email: "#{email}"}], 
          from: "greg@metaaa.org", 
          subject: "[META] Today's Spotify Suggestion", 
          global_merge_vars: [
              {name: "link", content: "#{link}"},
              {name: "name", content: "#{name}"},
              {name: "image", content: "#{image}"}
          ]
        }

        mandrill_client.messages.send_template template_name, template_content, message
      else
        scheduler.shutdown
      end
    end
  end

  # WIKIPEDIA TO INSTAPAPER
  def task7(parameter1, parameter2, task, user)
    require 'rufus-scheduler'

    scheduler = Rufus::Scheduler.new

    scheduler.every '6h' do 

      if user.following?(task) == true
        username = parameter1
        password = parameter2

        url = "https://en.wikipedia.org/w/index.php?title=Special:Random"

        InstaPush.connect "#{username}", "#{password}" do
          add "#{url}"
        end
      else
        scheduler.shutdown
      end
    end
  end

  # INSTAGRAM TO TWITTER
  def task8(parameter1, parameter2, parameter3, task, user)
    require 'rufus-scheduler'

    @instagram_access_token = parameter1
    @twitter_access_token = parameter2
    @twitter_secret = parameter3

    image_array = []
    flag = true

    scheduler = Rufus::Scheduler.new

    scheduler.every '15m' do 
      if user.following?(task) == true
        instagram = Instagram.client(:access_token => "#{@instagram_access_token}")

        twitter = Twitter::REST::Client.new do |config|
          config.consumer_key        = "zyaiHIkorYUnQpMxYHgYcayhg"
          config.consumer_secret     = "qZp9FzQhw9v5wGOwm7S7UdqFoB3xCqGYg2DMc82PnyuwbidsMO"
          config.access_token        = "#{@twitter_access_token}"
          config.access_token_secret = "#{@twitter_secret}"
        end

        feed = instagram.user_recent_media
        caption = []
        link = []
        time = []
        array = []

        for media_item in feed
          caption.push(media_item.caption)
          link.push(media_item.link)
          time.push(media_item.created_time)
          array.push(media_item.images.standard_resolution.url)
        end

        description = caption[0]
        url = link[0]
        image = array[0]
        created_time = time[0]
        created_time = Time.strptime("#{created_time}",'%s')
        now = Time.now
        post = description["text"]

        difference = (now - created_time) / 60
        count = image_array.count
        i = 0
            
        puts "Count: #{count}"
        puts "Image: #{image}"

        if difference < 15    
          if count > 0
            while i < count
              if image != image_array[i]
                puts "Flag True"
                flag = true
              else
                puts "Flag False"
                flag = false
              end

              i = i + 1
            end
          else
            twitter.update_with_media("#{post} #{url}", open("#{image}"))
            image_array.push("#{image}")
          end
        end
      else
         scheduler.shutdown
      end
    end
  end 

  # SLACK BOT
  def task9
    token = "xoxb-8709845893-hfhBzvwsP0I3kN0s8rQeNQ89"
  end
end