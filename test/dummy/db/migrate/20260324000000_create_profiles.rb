class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.integer :article_id
      t.string :bio
      t.string :website

      t.index [:article_id], name: "index_profiles_on_article_id"
    end

    add_foreign_key :profiles, :articles
  end
end
