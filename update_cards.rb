require 'open-uri'
require 'json'
require 'logger'

require_relative './common.rb'

cards_json_url = "https://api.hearthstonejson.com/v1/latest/enUS/cards.json"

cards_json = open(cards_json_url).read

cards = JSON.parse cards_json

cards.each do |card_data|

  begin
    card_data_json = JSON.generate card_data

    card = Card.find_or_create( :id => card_data['id'] ) do |card|
      card.id = card_data['id']
      card.data = card_data_json
      LOGGER.info "Created #{card.id}"
    end

    if card.data != card_data_json
      card.data = card_data_json
      card.save
      LOGGER.info "Updated #{card.id}"
    end
  rescue Exception => e
    LOGGER.error e.message
  end

end

untweeted_card = Card.first :tweeted_at => nil

if untweeted_card == nil

  Card.dataset.update :tweeted_at => nil
  LOGGER.info "RESETED tweeted_at"

end
