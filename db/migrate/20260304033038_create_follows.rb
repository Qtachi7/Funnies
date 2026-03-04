class CreateFollows < ActiveRecord::Migration[8.1]
  def change
    create_table :follows do |t|
      t.bigint :follower_id, null: false
      t.bigint :following_id, null: false

      t.timestamps
    end

    add_index :follows, :follower_id
    add_index :follows, :following_id
    add_index :follows, [ :follower_id, :following_id ], unique: true

    add_foreign_key :follows, :users, column: :follower_id,  on_delete: :cascade
    add_foreign_key :follows, :users, column: :following_id, on_delete: :cascade
  end
end
