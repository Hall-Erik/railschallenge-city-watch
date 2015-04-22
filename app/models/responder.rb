class Responder < ActiveRecord::Base
  belongs_to :emergency, foreign_key: 'emergency_code', primary_key: 'code'

  validates :name, uniqueness: true, presence: true
  validates :capacity, presence: true, inclusion: { in: 1..5 }
  validates :type, presence: true

  self.inheritance_column = nil
end
