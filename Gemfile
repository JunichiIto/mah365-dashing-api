source 'https://rubygems.org'
ruby '2.1.1'
gem 'rails', '4.1.0'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'spring',        group: :development
gem 'figaro', :github=>"laserlemon/figaro"
gem 'pg'
gem 'slim-rails'
gem 'unicorn'
gem 'unicorn-rails'
gem 'feed-normalizer'
gem 'newrelic_rpm'
group :production, :staging do
  gem 'rails_12factor'
end
group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'heroku_san'
end
group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails', '>= 3.0.0.beta2'
end
group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'faker'
  gem 'launchy'
  gem 'selenium-webdriver'
end
