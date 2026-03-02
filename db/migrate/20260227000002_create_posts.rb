class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string  :url,    null: false
      t.string  :title
      t.text    :body
      t.string  :source
      t.references :user, null: true, foreign_key: true

      # Reaction counts (denormalized for performance)
      t.integer :funny_count,     null: false, default: 0
      t.integer :laugh_count,     null: false, default: 0
      t.integer :cry_count,       null: false, default: 0
      t.integer :wow_count,       null: false, default: 0
      t.integer :cool_count,      null: false, default: 0
      t.integer :cute_count,      null: false, default: 0
      t.integer :surprised_count, null: false, default: 0

      t.timestamps
    end
  end
end
