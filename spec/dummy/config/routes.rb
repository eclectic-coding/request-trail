Rails.application.routes.draw do
  get "/ping", to: "ping#index"
end