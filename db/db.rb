require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(
   adapter: 'sqlite3',
   database: 'db/data.db'
)

begin
  ActiveRecord::Schema.define do
    create_table :users do |t|
      t.string :rival_id
      t.string :nick
      t.string :title
      t.string :last_at
      t.string :location
      t.string :game_center
      t.integer :tune_num
      t.integer :fc_num
      t.integer :exc_num
    end

    create_table :songs do |t|
      t.belongs_to :user, index: true
      t.string :name
      t.string :mid
      t.integer :bas_score
      t.integer :adv_score
      t.integer :ext_score
      t.integer :bas_lv
      t.integer :adv_lv
      t.integer :ext_lv
    end
  end
rescue Exception => e
  puts "#{ e.class }, 資料表已存在"
end

class User < ActiveRecord::Base
  has_many :songs
end

class Song < ActiveRecord::Base
  belongs_to :user
end

