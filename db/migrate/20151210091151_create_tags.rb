class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.string :search_help
      t.integer :use_count
      t.string :display
      t.boolean :active
      t.boolean :is_destroy
      t.integer :starmark
      t.timestamps
    end
  end
end
