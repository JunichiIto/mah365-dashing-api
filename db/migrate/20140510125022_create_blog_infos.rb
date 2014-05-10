class CreateBlogInfos < ActiveRecord::Migration
  def change
    create_table :blog_infos do |t|
      t.string :title
      t.string :url
      t.datetime :published_at

      t.timestamps
    end
  end
end
