Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    resource :blog_info, only: %i(show)
  end
end
