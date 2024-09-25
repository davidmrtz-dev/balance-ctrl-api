source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.4'

gem 'administrate'
gem 'attr_encrypted'
gem 'devise', '~> 4.7', '>= 4.7.3'
gem 'devise_token_auth'
gem 'discard', '~> 1.2'
gem 'faker', '>= 2.13.0'
gem 'figaro'
gem 'flipper-active_record', '~> 1.1.0'
gem 'flipper-ui', '~> 1.1.0'
gem 'net-http'
gem 'pg', '>= 0.18', '< 2.0'
gem 'rack-cors'
gem 'rails', '~> 6.1.1'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'colorize'
  gem 'database_cleaner-active_record'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'rails-erd'
  gem 'rspec-rails'
  gem 'rubocop', '~> 1.0', '< 2.0'
  gem 'rubocop-rails', '~> 2.0', '< 3.0'
  gem 'shoulda-matchers'
  gem 'solargraph'
  gem 'timecop'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'puma', '~> 5.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
