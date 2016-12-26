require 'sqlite3'
require 'sequel'
require 'logger'

# http://stackoverflow.com/a/6632032
# Don't allow downloaded files to be created as StringIO. Force a tempfile to be created.
require 'open-uri'
OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
OpenURI::Buffer.const_set 'StringMax', 0

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
