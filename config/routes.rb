Rails.application.routes.draw do
  resources :responders, param: :name, defaults: { format: :json }

  resources :emergencies, defaults: { format: :json }
end
