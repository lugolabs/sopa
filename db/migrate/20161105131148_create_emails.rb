class CreateEmails < ActiveRecord::Migration[5.0]
  def change
    create_table :emails do |t|
      t.string :recipient
      t.string :subject
      t.text :body
      t.string :campaign_id

      t.timestamps
    end
  end
end
