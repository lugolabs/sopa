class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :event_type
      t.string :recipient
      t.string :country
      t.string :campaign_id
      t.string :campaign_name

      t.timestamps
    end
  end
end
