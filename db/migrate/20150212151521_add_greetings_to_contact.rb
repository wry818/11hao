class AddGreetingsToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :greetings, :string
  end
end
