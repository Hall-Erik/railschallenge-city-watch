class Emergency < ActiveRecord::Base
  has_many :responders, foreign_key: 'emergency_code', primary_key: 'code'
  validates :code, uniqueness: true, presence: true
  validates :fire_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :police_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :medical_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  before_create :dispatch

  def resolve
  end

  private

  def dispatch
    full_response = dispatch_types

    return unless full_response
    self.full_response = true
  end

  # Call the dispatcher method for all emergency types
  def dispatch_types
    fire_response = (fire_severity > 0) ? dispatcher('Fire', fire_severity) : 0
    police_response = (police_severity > 0) ? dispatcher('Police', police_severity) : 0
    medical_response = (medical_severity > 0) ? dispatcher('Medical', medical_severity) : 0
    full_response?(fire_response, police_response, medical_response)
  end

  # RuboCop wants a small ABC size
  def full_response?(fire_response, police_response, medical_response)
    fire_response >= fire_severity && police_response >= police_severity && medical_response >= medical_severity
  end

  # Respond to a specific type of emergency
  def dispatcher(type, severity)
    response = 0
    responders = find_small_responders(type)

    response = check_responders(responders, severity, response) { |capacity| capacity > severity }
    if response < severity
      responders = responders.order(capacity: :asc)
      response = check_responders(responders, severity, response) { |capacity| capacity < severity }
    end

    response
  end

  # Loop through and dispatch responders
  def check_responders(responders, severity, response)
    res = response
    responders.each do |responder|
      # Don't want to throw the highest capacity at every problem
      # next if block returns true
      next if yield(responder.capacity)

      responder.emergency_code = code
      res += responder.capacity
      responder.save

      break if res >= severity
    end

    res
  end

  # Find responders by type that are on duty and not currently dispatched
  # in descending order of capacity
  def find_small_responders(type)
    Responder.where(type: type, on_duty: true, emergency_code: nil).order(capacity: :desc)
  end
end
