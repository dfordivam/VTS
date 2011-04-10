
set :application, "Visitor Tracking System"
set :repository,  "git@github.com:dfordivam/VTS.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, "bitnami"
set :branch, "master"

set :deploy_via, :remote_cache
set :deploy_to, "/home/bitnami/servers/VTS.git"

role :web, "ip-10-243-73-132.ec2.internal"                          # This may be the same as your `Web` server
role :app, "ip-10-243-73-132.ec2.internal"                          # This may be the same as your `Web` server
role :db,  "ip-10-243-73-132.ec2.internal", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

 namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
 end

shared_path = "/home/bitnami/servers/VTS.git/shared"
release_path = "/home/bitnami/servers/VTS.git/current"

namespace :customs do
  task :config_database_yml, :roles => :app do
    run <<-CMD
      ln -nfs #{shared_path}/system/database.yml #{release_path}/config/database.yml
    CMD
  end
  task :config_production_rb, :roles => :app do
    run <<-CMD
      ln -nfs #{shared_path}/system/production.rb #{release_path}/config/environments/production.rb
    CMD
  end
end
