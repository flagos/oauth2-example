require 'sqlite3'
require "active_record"
require "rack/oauth2/sinatra"
require "rack/oauth2/server"
require "rack/oauth2/server/admin"
require "logger"

DATABASE = SQLite3::Database.new("test.db")

# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "test.db")
ActiveRecord::Migrator.migrate('db/migrate')

$logger = Logger.new("test.log")
$logger.level = Logger::DEBUG
Rack::OAuth2::Server::Admin.configure do |config|
  config.set :logger, $logger
  config.set :logging, true
  config.set :raise_errors, true
  config.set :dump_errors, true
  config.oauth.logger = $logger
end



class MyApp < Sinatra::Base
  use Rack::Logger
  set :sessions, true

  register Rack::OAuth2::Sinatra
  oauth.authenticator = lambda do |username, password|
    "Batman" if username == "cowbell" && password == "more"
  end
  oauth.host = "example.org"
  oauth.database = DATABASE


  # 3.  Obtaining End-User Authorization
 
  before "/oauth/*" do 
    halt oauth.deny! if oauth.scope.include?("time-travel") # Only Superman can do that
  end

  get "/oauth/authorize" do
    "client: #{oauth.client.display_name}\nscope: #{oauth.scope}\nauthorization: #{oauth.authorization}"
  end

  post "/oauth/grant" do
    oauth.grant! "Batman"
  end

  post "/oauth/deny" do
    oauth.deny!
  end


  # 5.  Accessing a Protected Resource

  before { @user = oauth.identity if oauth.authenticated? }

  get "/public" do
    if oauth.authenticated?
      "HAI from #{oauth.identity}"
    else
      "HAI"
    end
  end

  get "/camion" do
    "pouet-pouet"
  end

  oauth_required "/private", "/change"

  get "/private" do
    "Shhhh"
  end

  post "/change" do
    "Woot!"
  end

  oauth_required "/calc", :scope=>"math"

  get "/calc" do
  end
  
  oauth_required "/milk", :scope => "rite"
  
  get "/milk" do
  end

  get "/user" do
    @user
  end

  get "/list_tokens" do
    oauth.list_access_tokens("Batman").map(&:token).join(" ")
  end
  run! if app_file == $0
end
