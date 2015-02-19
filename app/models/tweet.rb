class Tweet < ActiveRecord::Base
  belongs_to :team
  @@faye_client = Faye::Client.new('http://localhost:9292/faye')
  @@twitter_client = Twitter::Streaming::Client.new do |config|
    config.consumer_key        = ENV['FOOTBALL_CUSTOMER_TW_KEY']
    config.consumer_secret     = ENV['FOOTBALL_CUSTOMER_TW_SECRET_KEY']
    config.access_token        = ENV['FOOTBALL_ACCESS_TOKEN']
    config.access_token_secret = ENV['FOOBALL_ACCESS_TOKEN_SECRET']
  end

  def self.team_tweets
    twitter_handles = Team.pluck(:twitter) << "premierleague"
    
    Thread.new do 
      @@twitter_client.filter(track: twitter_handles.join(","), language: "en") do |tweet|
        puts "tweet: #{tweet.text}"
        twitter_handles.each do |handle|
          if tweet.text.include?(handle)
            @@faye_client.publish("/tweets/#{handle}", tweet)
            puts "published to #{handle}"
          end
        end
      end
    end
  end

end

