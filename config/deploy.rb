# 2015-9-10
# Adapted from: https://gist.github.com/johnbintz/36bd6d6bcd9e6cfcb8f4

lock '3.4.0'

set :application, 'replicon-code-challenge'
set :repo_url, 'git@github.com:RaphaelDeLaGhetto/replicon-code-challenge.git'

set :deploy_to, "/home/deploy/#{fetch(application)}"

desc 'Build Docker images'
task :build do
  execute "cd #{release_path} && npm install"

  # build the actual docker image, tagging the push for the remote repo
  system "docker build -t #{fetch(:application)}-image ."
end

desc 'go'
task :go => ['build']

namespace :deploy do
  task :restart do
    on roles(:app) do
      # in case the app isn't running on the other end
      execute "docker stop #{fetch(:application)} ; true"

      # have to remove it otherwise --restart=always will run it again on reboot!
      execute "docker rm #{fetch(:application)} ; true"
                                                              
      # modify this to suit how you want to run your app
      execute "docker run --restart=always --name #{fetch(:application)} --expose 80 --expose 443 -e VIRTUAL_HOST=gofish.mobi --link postgres:postgres -d #{fetch(:application)}-image"
    end
  end
end
