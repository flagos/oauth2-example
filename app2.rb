require 'sqlite3'
require "active_record"
require "rack/oauth2/sinatra"
require "rack/oauth2/server"
require "sinatra"
DATABASE = SQLite3::Database.new("test2.db")

# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "test2.db")
ActiveRecord::Migrator.migrate('db/migrate')


class MyApp < Sinatra::Base
  use Rack::Logger
 # set :sessions, true # https://github.com/rack/rack/issues/299
  register Rack::OAuth2::Sinatra
  puts DATABASE
  oauth.database = DATABASE
  #oauth.scope = %w{read write}
  
  oauth.authenticator = lambda do |username, password|
    "Batman" if username == "cowbell" && password == "more"
  end

  # 3.  Obtaining End-User Authorization
 
  get "/oauth/authorize" do
  if current_user
    render "oauth/authorize"
  else
    redirect "/oauth/login?authorization=#{oauth.authorization}"
  end
  end

  post "/oauth/grant" do
    oauth.grant! "Superman"
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
