# 2015-9-10
# Adapted from: https://gist.github.com/johnbintz/36bd6d6bcd9e6cfcb8f4

lock '3.4.0'

set :application, 'replicon-code-challenge'
set :repo_url, 'git@github.com:RaphaelDeLaGhetto/replicon-code-challenge.git'

set :deploy_to, "/home/deploy/#{fetch(:application)}"

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/application.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log',
                                               'tmp/pids',
                                               'tmp/cache',
                                               'tmp/sockets',
                                               'vendor/bundle',
                                               'public/system',
                                               'node_modules')
namespace :deploy do

  desc 'Install node modules'
  task :npm_install do
    on roles(:app) do
      execute "cd #{release_path} && npm install"
    end
  end

  desc 'Build Docker images'
  task :build do
    system "docker build -t #{fetch(:application)}-image ."
  end

  desc 'Restart application'
  task :restart do
    on roles(:app) do
      execute "docker stop #{fetch(:application)} ; true"
      execute "docker rm #{fetch(:application)} ; true"
      execute "docker run --restart=always --name #{fetch(:application)} --expose 80 --expose 443 -e VIRTUAL_HOST=gofish.mobi --link postgres:postgres -d #{fetch(:application)}-image"
    end
  end

  before :updated, 'deploy:npm_install' 
  after :publishing, 'deploy:build'
  after :publishing, 'deploy:restart'
end

# deploy
#namespace :deploy do
#
#  # 2015-4-14 https://gist.github.com/ryanray/7579912
#  desc 'Install node modules'
#  task :npm_install do
#    on roles(:app) do
#      execute "cd #{release_path} && npm install"
#    end
#  end
#                      
#  desc 'Restart application'
#  task :restart do
#    on roles(:app), in: :sequence, wait: 5 do 
#      execute :touch, release_path.join('tmp/restart.txt')
#    end
#  end
#
#  desc "Build missing paperclip styles"
#  task :build_missing_paperclip_styles do
#    on roles(:app) do
#      #execute "cd #{current_path}; RAILS_ENV=production $HOME/.rbenv/bin/rbenv bundle exec rake paperclip:refresh:missing_styles"
#      # 2015-5-12
#      # http://stackoverflow.com/questions/29022523/build-missing-styles-on-paperclip-errors-out-on-missing-bundle
#      execute "cd #{current_path}; RAILS_ENV=production $HOME/.rbenv/bin/rbenv exec bundle exec rake paperclip:refresh:missing_styles"
#    end
#  end
#
#  before :updated, 'deploy:npm_install' 
#  after :deploy, 'deploy:build_missing_paperclip_styles'
#  after :publishing, 'deploy:restart'
#  after :finishing, 'deploy:cleanup'
#end
