class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.references :profile, foreign_key: true
      t.references :headhunter, foreign_key: true
      t.text :comment

      t.timestamps
    end
  end
end
