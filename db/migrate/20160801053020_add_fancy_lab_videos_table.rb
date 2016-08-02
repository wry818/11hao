class AddFancyLabVideosTable < ActiveRecord::Migration
  def change
    create_table :fancylab_videos do |t|
      t.string :video_id
      t.string :video_title
      t.string :video_name
      t.string :video_url
      t.integer :video_likes
    end
  end
end
