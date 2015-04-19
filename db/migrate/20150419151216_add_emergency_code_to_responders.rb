class AddEmergencyCodeToResponders < ActiveRecord::Migration
  def change
    add_column :responders, :emergency_code, :string

    # Set NOT NULL
    change_column_null :responders, :name, false
    change_column_null :responders, :type, false
    change_column_null :responders, :capacity, false
  end
end
