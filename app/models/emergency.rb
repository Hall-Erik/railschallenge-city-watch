class Emergency < ActiveRecord::Base
  has_many :responders, foreign_key: 'emergency_code', primary_key: 'code'
  validates :code, uniqueness: true, presence: true
  validates :fire_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :police_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :medical_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  before_create :dispatch
  before_update :resolve

  def resolve
    return unless resolved_at_changed?
    Responder.where(emergency_code: code).find_each do |responder|
      responder.emergency_code = nil
      responder.save
    end
  end

  private

  # Called after_create
  # Starts the process of dispatching responders to this emergency
  # using several extra methods to keep RuboCop happy
  def dispatch
    full_response = dispatch_types

    return unless full_response
    self.full_response = true
  end

  # Call the dispatcher method for all emergency types
  def dispatch_types
    # x_response is the sum of the capacity of responders of type x
    fire_response = (fire_severity > 0) ? dispatcher('Fire', fire_severity) : 0
    police_response = (police_severity > 0) ? dispatcher('Police', police_severity) : 0
    medical_response = (medical_severity > 0) ? dispatcher('Medical', medical_severity) : 0
    full_response?(fire_response, police_response, medical_response)
  end

  # RuboCop wants a small ABC size, so I put this in its own method
  def full_response?(fire_response, police_response, medical_response)
    fire_response >= fire_severity && police_response >= police_severity && medical_response >= medical_severity
  end

  # Respond to a specific type of emergency
  def dispatcher(type, severity)
    response = 0
    responders = find_responders(type)

    response = check_responders(responders, severity, response) { |capacity| capacity > severity }
    if response < severity
      responders = responders.order(capacity: :asc)
      response = check_responders(responders, severity, response) { |capacity| capacity < severity }
    end

    response
  end

  # Loop through and dispatch responders
  def check_responders(responders, severity, response)
    responders.each do |responder|
      # Don't want to throw the highest capacity at every problem
      # next, if block returns true
      next if yield(responder.capacity)

      responder.emergency_code = code
      response += responder.capacity
      responder.save

      break if response >= severity
    end

    response
  end

  # Find responders by type that are on duty and not currently dispatched
  # in descending order of capacity
  def find_responders(type)
    Responder.where(type: type, on_duty: true, emergency_code: nil).order(capacity: :desc)
  end
end
