class Responder < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  validates :capacity, presence: true, inclusion: { in: 1..5 }
  validates :type, presence: true
    
  self.inheritance_column = nil
end
