require 'sqlite3'
require 'sequel'
require 'logger'


require 'twitter'
# <3 https://mikecoutermarsh.com/the-io-object-for-media-must-respond-to-to_io/
module Twitter::Image
  # The Twitter gem is particular about the type of IO object it
  #   recieves when tweeting an image. If an image is < 10kb, Ruby opens it as a
  #   StringIO object. Which is not supported by the Twitter gem/api.
  #
  #   This method ensures we always have a valid IO object for Twitter.
  def self.open_from_url(image_url)
    image_file = open(image_url)
    return image_file unless image_file.is_a?(StringIO)

    file_name = File.basename(image_url)

    temp_file = Tempfile.new(file_name)
    temp_file.binmode
    temp_file.write(image_file.read)
    temp_file.close

    open(temp_file.path)
  end
end

LOGGER = Logger.new($stdout)

CONFIG = {
    :database_filepath => ENV['DATABASE_FILEPATH'] || 'database.sqlite3',
    :twitter_consumer_key => ENV['TWITTER_CONSUMER_KEY'],
    :twitter_consumer_secret => ENV['TWITTER_CONSUMER_SECRET'],
    :twitter_access_token => ENV['TWITTER_ACCESS_TOKEN'],
    :twitter_access_token_secret => ENV['TWITTER_ACCESS_TOKEN_SECRET']
}

DB = Sequel.sqlite(CONFIG[:database_filepath])

if ENV['ENVIRONMENT'] == 'development'
  DB.loggers << LOGGER
end

DB.create_table? :cards do
  String :id, :primary_key=>true
  String :data, :text=>true
  DateTime  :tweeted_at, :null => true
end

class Card < Sequel::Model
  unrestrict_primary_key
end

def Card.untweeted_random()
  where(:tweeted_at => nil).order(Sequel.lit('RANDOM()'))
end

Card.finder :untweeted_random
