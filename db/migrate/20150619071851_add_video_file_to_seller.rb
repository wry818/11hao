class AddVideoFileToSeller < ActiveRecord::Migration
  def change
    add_column :sellers, :video_file, :string
  end
end
