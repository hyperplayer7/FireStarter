# >---------------------------------------------------------------------------<
#
#            _____       _ _   __          ___                  _ 
#           |  __ \     (_) |  \ \        / (_)                | |
#           | |__) |__ _ _| |___\ \  /\  / / _ ______ _ _ __ __| |
#           |  _  // _` | | / __|\ \/  \/ / | |_  / _` | '__/ _` |
#           | | \ \ (_| | | \__ \ \  /\  /  | |/ / (_| | | | (_| |
#           |_|  \_\__,_|_|_|___/  \/  \/   |_/___\__,_|_|  \__,_|
#
#   This template was generated by RailsWizard, the amazing and awesome Rails
#     application template builder. Get started at http://railswizard.org
#
# >---------------------------------------------------------------------------<

# >----------------------------[ Initial Setup ]------------------------------<

initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
end
RUBY

@recipes = ["activerecord", "cucumber", "env_yaml", "haml", "active_admin", "sass", "html5", "authorization", "sitemap_generator", "cleanup"] 

def recipes; @recipes end
def recipe?(name); @recipes.include?(name) end

def say_custom(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}" end
def say_recipe(name); say "\033[1m\033[36m" + "recipe".rjust(10) + "\033[0m" + "  Running #{name} recipe..." end
def say_wizard(text); say_custom(@current_recipe || 'wizard', text) end

def ask_wizard(question)
  ask "\033[1m\033[30m\033[46m" + (@current_recipe || "prompt").rjust(10) + "\033[0m\033[36m" + "  #{question}\033[0m"
end

def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end

def no_wizard?(question); !yes_wizard?(question) end

def multiple_choice(question, choices)
  say_custom('question', question)
  values = {}
  choices.each_with_index do |choice,i| 
    values[(i + 1).to_s] = choice[1]
    say_custom (i + 1).to_s + ')', choice[0]
  end
  answer = ask_wizard("Enter your selection:") while !values.keys.include?(answer)
  values[answer]
end

@current_recipe = nil
@configs = {}

@after_blocks = []
def after_bundler(&block); @after_blocks << [@current_recipe, block]; end
@after_everything_blocks = []
def after_everything(&block); @after_everything_blocks << [@current_recipe, block]; end
@before_configs = {}
def before_config(&block); @before_configs[@current_recipe] = block; end



# >-----------------------------[ ActiveRecord ]------------------------------<

@current_recipe = "activerecord"
@before_configs["activerecord"].call if @before_configs["activerecord"]
say_recipe 'ActiveRecord'

config = {}
config['database'] = multiple_choice("Which database are you using?", [["MySQL", "mysql"], ["Oracle", "oracle"], ["PostgreSQL", "postgresql"], ["SQLite", "sqlite3"], ["Frontbase", "frontbase"], ["IBM DB", "ibm_db"]]) if true && true unless config.key?('database')
config['auto_create'] = yes_wizard?("Automatically create database with default configuration?") if true && true unless config.key?('auto_create')
@configs[@current_recipe] = config

if config['database']
  say_wizard "Configuring '#{config['database']}' database settings..."
  old_gem = gem_for_database
  @options = @options.dup.merge(:database => config['database'])
  gsub_file 'Gemfile', "gem '#{old_gem}'", "gem '#{gem_for_database}'"
  template "config/databases/#{@options[:database]}.yml", "config/database.yml.new"
  run 'mv config/database.yml.new config/database.yml'
end

after_bundler do
  rake "db:create:all" if config['auto_create']
end


# >-------------------------------[ Cucumber ]--------------------------------<

@current_recipe = "cucumber"
@before_configs["cucumber"].call if @before_configs["cucumber"]
say_recipe 'Cucumber'


@configs[@current_recipe] = config

gem 'cucumber-rails', :group => [:development, :test]
gem 'capybara', :group => [:development, :test]

after_bundler do
  generate "cucumber:install --capybara#{' --rspec' if recipes.include?('rspec')}#{' -D' unless recipes.include?('activerecord')}"
end


# >--------------------------------[ EnvYAML ]--------------------------------<

@current_recipe = "env_yaml"
@before_configs["env_yaml"].call if @before_configs["env_yaml"]
say_recipe 'EnvYAML'


@configs[@current_recipe] = config

say_wizard "Generating config/env.yaml..."

append_file "config/application.rb", <<-RUBY

require 'env_yaml'
RUBY

create_file "lib/env_yaml.rb", <<-RUBY
require 'yaml'
begin
  env_yaml = YAML.load_file(File.dirname(__FILE__) + '/../config/env.yml')
  if env_hash = env_yaml[ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development']
    env_hash.each_pair do |k,v|
      ENV[k] = v.to_s
    end
  end
rescue StandardError => e
end

RUBY

create_file "config/env.yml", <<-YAML
defaults: &defaults
  ENV_YAML: true

development:
  <<: *defaults

test:
  <<: *defaults

production:
  <<: *defaults
YAML

def env(k,v,rack_env='development')
  inject_into_file "config/env.yml", :after => "#{rack_env}:\n  <<: *defaults" do
    <<-YAML
#{k}: #{v.inspect}    
YAML
  end
end


# >---------------------------------[ HAML ]----------------------------------<

@current_recipe = "haml"
@before_configs["haml"].call if @before_configs["haml"]
say_recipe 'HAML with Formtastic'


@configs[@current_recipe] = config

gem 'haml', '>= 3.0.0'
gem 'haml-rails'
gem 'formtastic'
gem 'jquery-rails'


# >------------------------------[ ActiveAdmin ]-------------------------------<

@current_recipe = "active_admin"
@before_configs["active_admin"].call if @before_configs["active_admin"]
say_recipe 'ActiveAdmin with CkEditor'

gem 'devise'
gem 'activeadmin'
gem "ckeditor"
gem "paperclip"
gem 'kaminari'

after_bundler do
  generate 'active_admin:install'
  generate 'ckeditor:install'
  generate 'ckeditor:models --orm=active_record --backend=paperclip'
end


# >---------------------------------[ SASS ]----------------------------------<

@current_recipe = "sass"
@before_configs["sass"].call if @before_configs["sass"]
say_recipe 'SASS'


@configs[@current_recipe] = config

unless recipes.include? 'haml'
  gem 'haml', '>= 3.0.0'
end

# >---------------------------------[ html5 ]---------------------------------<

@current_recipe = "html5"
@before_configs["html5"].call if @before_configs["html5"]
say_recipe 'HTML5 Boiler Plate and Skeleton CSS'

@configs[@current_recipe] = config

gem 'frontend-helpers'

after_bundler do
  # Download HTML5 Boilerplate plugins.js (converted to CoffeeScript)
  get "https://github.com/russfrisch/h5bp-rails/raw/master/assets/plugins.js.coffee", "app/assets/javascripts/plugins.js.coffee"
  
  # Download Skeleton CSS
  get "https://raw.github.com/necolas/normalize.css/master/normalize.css", "app/assets/stylesheets/normalize.css.scss"
  get "https://raw.github.com/dhgamache/Skeleton/master/stylesheets/base.css", "app/assets/stylesheets/base.css.scss"
  get "https://raw.github.com/dhgamache/Skeleton/master/stylesheets/layout.css", "app/assets/stylesheets/layout.css.scss"
  get "https://raw.github.com/dhgamache/Skeleton/master/stylesheets/skeleton.css", "app/assets/stylesheets/skeleton.css.scss"
  get "https://raw.github.com/dhgamache/Skeleton/master/javascripts/tabs.js", "app/assets/javascripts/tabs.js"
  
  # Fix application.css
  inside('app/assets/stylesheets/') do
    FileUtils.rm_rf 'application.css'
    FileUtils.touch 'application.css'
  end
  
  # Use Skeleton CSS
  prepend_to_file 'app/assets/stylesheets/application.css' do
"/*
* This is a manifest file that'll automatically include all the stylesheets available in this directory
* and any sub-directories. You're free to add application-wide styles to this file and they'll appear at
* the top of the compiled file, but it's generally better to create a new file per style scope.
*= require normalize
*= require base
*= require layout
*= require skeleton
*= require styles
*= require_self
*/
  "
  end

  # Add Modernizr-Rails dependency to get Modernizr.js support,
  # optional blueprint-rails, coffeebeans, and Heroku dependencies.
  gsub_file 'Gemfile', /gem 'jquery-rails'/ do
"# JavasScript libs
gem 'jquery-rails'
gem 'modernizr-rails'

# Stylesheet libs
# gem 'blueprint-rails'

# Ajax request CoffeeScript support
# gem 'coffeebeans'

# Heroku deployment requirements
# group :production do
#   gem 'therubyracer-heroku'
#   gem 'pg'
# end
"
  end
  
  # Download HTML5 Boilerplate Site Root Assets
  get "https://raw.github.com/paulirish/html5-boilerplate/master/apple-touch-icon-114x114-precomposed.png", "public/apple-touch-icon-114x114-precomposed.png"
  get "https://raw.github.com/paulirish/html5-boilerplate/master/apple-touch-icon-57x57-precomposed.png", "public/apple-touch-icon-57x57-precomposed.png"
  get "https://raw.github.com/paulirish/html5-boilerplate/master/apple-touch-icon-72x72-precomposed.png", "public/apple-touch-icon-72x72-precomposed.png"
  get "https://raw.github.com/paulirish/html5-boilerplate/master/apple-touch-icon-precomposed.png", "public/apple-touch-icon-precomposed.png"
  get "https://raw.github.com/paulirish/html5-boilerplate/master/apple-touch-icon.png", "public/apple-touch-icon.png"
  get "https://raw.github.com/paulirish/html5-boilerplate/master/crossdomain.xml", "public/crossdomain.xml"
  get "https://raw.github.com/paulirish/html5-boilerplate/master/humans.txt", "public/humans.txt"
  
  # Add FrontendHelpers
  inject_into_file 'app/controllers/application_controller.rb', :after => "protect_from_forgery\n" do
<<-'RUBY'
  include FrontendHelpers::Html5Helper
RUBY
  end

  # Haml version of default application layout
  remove_file 'app/views/layouts/application.html.erb'
  remove_file 'app/views/layouts/application.html.haml'

  # There is Haml code in this script. Changing the indentation is perilous between HAMLs.
  create_file 'app/views/layouts/application.html.haml' do <<-HAML
- html_tag class: 'no-js' do
  %head
    %title #{app_name}
    %meta{:charset => "utf-8"}
    %meta{"http-equiv" => "X-UA-Compatible", :content => "IE=edge,chrome=1"}
    %meta{:name => "viewport", :content => "width=device-width, initial-scale=1, maximum-scale=1"}
    = stylesheet_link_tag :application
    = javascript_include_tag :application
    = csrf_meta_tags
  %body{:class => params[:controller]}
    #container.container
      %header
        - flash.each do |name, msg|
          = content_tag :div, msg, :id => "flash_\#{name}" if msg.is_a?(String)
      #main{:role => "main"}
        = yield
      %footer
HAML
  end
end

# >-----------------------------[ Authorization ]-------------------------------<
@current_recipe = "authorization"
@before_configs["authorization"].call if @before_configs["authorization"]
say_recipe 'Authorization with CanCan'

@configs[@current_recipe] = config

gem 'cancan'

after_bundler do
  generate 'cancan:ability'
end

# >-----------------------------[ Sitemap Generator ]-------------------------------<
@current_recipe = "sitemap_generator"
@before_configs["sitemap_generator"].call if @before_configs["sitemap_generator"]
say_recipe 'Sitemap Generator'

@configs[@current_recipe] = config

gem 'sitemap_generator'

after_bundler do
  run "rake sitemap:install"
  #load ability.rb to allow initial management
  gsub_file 'app/models/ability.rb', /def initialize\(user\)/ do
    "# let ActiveAdmin allow initial user sign-up
    def initialize(user)
      can :manage, :all
    "
  end
end

# >-----------------------------[ Cleanup ]-------------------------------<
@current_recipe = "cleanup"
@before_configs["cleanup"].call if @before_configs["cleanup"]
say_recipe 'Clean Up'

after_bundler do
  # delete public/index.html
  remove_file 'public/index.html'
  
  # run the generated migrations
  run 'bundle exec rake db:migrate'
  
  # generate the Home controller
  run 'bundle exec rails g controller Home index'
  
  # make home#index as root
  gsub_file 'config/routes.rb', /devise_for :admin_users, ActiveAdmin::Devise.config/ do
"
devise_for :admin_users, ActiveAdmin::Devise.config
root :to => 'home#index'
"
  end
end

@current_recipe = nil

# >-----------------------------[ Run Bundler ]-------------------------------<

say_wizard "Running Bundler install. This will take a while."
run 'bundle install'
say_wizard "Running after Bundler callbacks."
@after_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}

@current_recipe = nil
say_wizard "Running after everything callbacks."
@after_everything_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}
