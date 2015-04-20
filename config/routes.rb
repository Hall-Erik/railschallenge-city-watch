Rails.application.routes.draw do
  resources :responders, param: :name, defaults: { format: :json }

  resources :emergencies, param: :code, defaults: { format: :json }
end
