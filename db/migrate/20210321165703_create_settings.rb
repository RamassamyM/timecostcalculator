class CreateSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :settings do |t|
      t.string :type
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
