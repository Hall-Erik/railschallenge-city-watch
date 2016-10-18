class Emergency < ActiveRecord::Base
  has_many :responders, foreign_key: 'emergency_code', primary_key: 'code'
  validates :code, uniqueness: true, presence: true
  validates :fire_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :police_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :medical_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  before_create :dispatcher
  before_update :resolve

  private

  # If emergency is resolved, free up the responders
  def resolve
    return unless resolved_at_changed?
    Responder.where(emergency_code: code).find_each do |responder|
      responder.emergency_code = nil
      responder.save
    end
  end

  # Starts the process of dispatching responders to this emergency
  def dispatcher
    fire_response = (fire_severity > 0) ? dispatch('Fire', fire_severity) : 0
    police_response = (police_severity > 0) ? dispatch('Police', police_severity) : 0
    medical_response = (medical_severity > 0) ? dispatch('Medical', medical_severity) : 0

    return unless fire_response >= fire_severity &&
      police_response >= police_severity && medical_response >= medical_severity
    self.full_response = true
  end

  # Respond to a specific type of emergency
  def dispatch(type, severity)
    response = 0
    responders = Responder.where(type: type, on_duty: true, emergency_code: nil).order(capacity: :desc)

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
end
