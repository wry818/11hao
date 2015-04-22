class CreateJoinTableOrganizationUser < ActiveRecord::Migration
  def change
    create_join_table :organizations, :users do |t|
      t.index [:organization_id, :user_id]
      t.index [:user_id, :organization_id]
    end
  end
end
