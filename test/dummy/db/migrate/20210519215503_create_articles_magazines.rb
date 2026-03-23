class CreateArticlesMagazines < ActiveRecord::Migration[6.0]
  def change
    create_join_table :articles, :magazines do |t|
      t.index [:article_id, :magazine_id]
    end
  end
end
