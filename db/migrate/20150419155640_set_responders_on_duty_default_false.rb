class SetRespondersOnDutyDefaultFalse < ActiveRecord::Migration
  def change
    change_column_default :responders, :on_duty, false
  end
end
