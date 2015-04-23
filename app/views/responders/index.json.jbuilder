if @capacity
  json.capacity @capacity
else
  json.responders(@responders,
        :emergency_code,
        :type,
        :name,
        :capacity,
        :on_duty)
end