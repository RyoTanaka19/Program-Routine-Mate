class CreateContacts < ActiveRecord::Migration[7.2]
  def change
    create_table :contacts do |t|
      t.string :name, null: false
      t.text :message, null: false
      t.string :subject, null: false
      t.text :email, null: false

      t.timestamps
    end
  end
end
