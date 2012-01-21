class AddOauthTables < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string :code
      t.string :secret
      t.string :display_name
      t.string :link
      t.string :image_url
      t.string :redirect_uri
      t.string :scope
      t.string :notes
      t.datetime :revoked
      t.timestamps
    end
    create_table :auth_requests do |t|
      t.string :code
      t.integer :client_id
      t.string :scope
      t.string :redirect_uri
      t.string :state
      t.string :response_type
      t.string :grant_code
      t.string :access_token
      t.datetime :authorized_at
      t.datetime :revoked
      t.timestamps
    end
    create_table :access_grants do |t|
      t.string :code
      t.string :access_token
      t.string :identity
      t.integer :client_id
      t.string :scope
      t.datetime :granted_at
      t.string :redirect_uri
      t.datetime :expires_at
      t.datetime :revoked
      t.datetime :last_access
      t.datetime :prev_access
      t.timestamps
    end
    create_table :access_tokens do |t|
      t.string :code
      t.string :identity
      t.integer :client_id
      t.string :redirect_uri
      t.string :scope
      t.datetime :granted_at
      t.datetime :expires_at
      t.string :access_token
      t.datetime :revoked
      t.datetime :last_access
      t.datetime :prev_access
      t.timestamps
    end
  end

  def self.down
    drop_table :access_tokens
    drop_table :access_grants
    drop_table :auth_requests
    drop_table :clients
  end
end
