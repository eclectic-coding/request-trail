Rails.application.routes.draw do
  get "/ping", to: "ping#index"
  get "/favicon.ico", to: proc { [204, {}, []] }
end