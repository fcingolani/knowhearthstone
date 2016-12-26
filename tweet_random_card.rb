require 'twitter'
require 'open-uri'
require 'json'

require_relative './common.rb'

twitter = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONFIG[:twitter_consumer_key]
  config.consumer_secret     = CONFIG[:twitter_consumer_secret]
  config.access_token        = CONFIG[:twitter_access_token]
  config.access_token_secret = CONFIG[:twitter_access_token_secret]
end

# This should be obtained with twitter.configuration.short_url_length
# but YOLO
short_url_length = 22

max_text_length = 140 - (1 + short_url_length) # space + media

tail = " #Hearthstone"

card = Card.first_untweeted_random()

  if card != nil

  card_data = JSON.parse card.data

  LOGGER.info "Picked #{card.data}"


  begin
    image = open("http://wow.zamimg.com/images/hearthstone/cards/enus/animated/#{card.id}_premium.gif")
  rescue OpenURI::HTTPError => ex
    image = nil
    LOGGER.info "Golden card not found"
  end

  if image == nil
    begin
      image = open("http://wow.zamimg.com/images/hearthstone/cards/enus/original/#{card.id}.png")
    rescue OpenURI::HTTPError => ex
      image = nil
      LOGGER.info "Regular card not found"
    end
  end

  if image != nil

    text = card_data['flavor']

    if text == nil or text.length > max_text_length
      text = card_data['name']
    end

    if text.length + tail.length <= max_text_length
      text += " #Hearthstone"
    end

    tweet = twitter.update_with_media text, image

    LOGGER.info "Tweeted ##{tweet.id} #{tweet.text}"

  end

  card.tweeted_at = DateTime.now
  card.save

end
