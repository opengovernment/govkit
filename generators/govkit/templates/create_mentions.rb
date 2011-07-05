class CreateMentions < ActiveRecord::Migration
  def self.up
    create_table :mentions, :force => true do |t|
      t.string   "url",           :limit => 8000
      t.string   "excerpt",       :limit => 4000
      t.string   "title",         :limit => 1000
      t.string   "source"
      t.datetime "date"
      t.float    "weight"
      t.integer  "owner_id"
      t.string   "owner_type"
      t.string   "search_source"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
  
  def self.down
    drop_table :mentions
  end
end
