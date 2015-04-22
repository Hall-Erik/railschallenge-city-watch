class RemoveDatetimesFromEmergencies < ActiveRecord::Migration
  def change
    remove_column :emergencies, :created_at
    remove_column :emergencies, :updated_at
  end
end
