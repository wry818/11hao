class AddSourceToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :source, :string
  end
end
