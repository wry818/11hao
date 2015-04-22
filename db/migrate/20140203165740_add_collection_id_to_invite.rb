class AddCollectionIdToInvite < ActiveRecord::Migration
  def change
    add_column :invites, :collection_id, :integer
  end
end
