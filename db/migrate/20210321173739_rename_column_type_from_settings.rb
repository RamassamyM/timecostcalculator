class RenameColumnTypeFromSettings < ActiveRecord::Migration[6.0]
  def change
    rename_column :settings, :type, :category
  end
end
