class CreateUserSocials < ActiveRecord::Migration
  def change
    create_table :user_socials do |t|
      t.string :provider, null: false
      t.references :user, index: true
      t.string :uid, null: false

      t.timestamps null: false
    end
    add_foreign_key :user_socials, :users
  end
end
