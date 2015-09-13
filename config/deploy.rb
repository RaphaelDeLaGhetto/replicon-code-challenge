lock '3.4.0'

set :application, 'replicon-code-challenge'
set :repo_url, 'https://github.com/RaphaelDeLaGhetto/replicon-code-challenge.git'

set :branch, 'master'
set :scm, :git

set :deploy_to, "/home/app/#{fetch(:application)}"

# Default value for :linked_files is []
set :copy_files, ['config/database.yml', 'config/secrets.yml', 'config/application.yml']

# Default value for :linked_files is []
#set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/application.yml')
#
## Default value for linked_dirs is []
#set :linked_dirs, fetch(:linked_dirs, []).push('log',
#                                               'tmp/pids',
#                                               'tmp/cache',
#                                               'tmp/sockets',
#                                               'vendor/bundle',
#                                               'public/system',
#                                               'node_modules')

namespace :deploy do

  desc 'Install node modules'
  task :npm_install do
    on roles(:app) do
      execute "cd #{release_path} && npm install"
    end
  end

#  desc 'Precompile assets'
#  task :rake_assets_precompile do
#    on roles(:app) do
#      execute "RAILS_ENV=production rake assets:precompile"
#    end
#  end


  desc 'Build Docker images'
  task :build do
    on roles(:app) do
    execute "cd #{release_path} && docker build -t #{fetch(:application)}-image ."
    end
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
#  before :updated, 'deploy:rake_assets_precompile'
  after :publishing, 'deploy:build'
  after :publishing, 'deploy:restart'
end

