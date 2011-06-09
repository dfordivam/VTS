default_run_options[:pty] = true 

set :application, "Visitor Tracking System"
set :repository,  "git@github.com:dfordivam/VTS.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#set :deploy_via, :remote_cache
#set :branch, "master"

prod_server = "184.73.192.153"
staging_server = "50.17.185.45"
if (!env.nil? && env == "production")
  puts "Deploying to Production server"
  set :user, "bitnami"
  set :deploy_to, "/home/bitnami/servers/vts"
  role :web, prod_server                          # This may be the same as your `Web` server
  role :app, prod_server
  role :db,  prod_server, :primary => true # This is where Rails migrations will run
  server_root = "/home/bitnami/servers/vts"
  set :branch, "deploy"
else
  puts "Deploying to Staging server"
  set :user, "bitnami"
  set :deploy_to, "/home/bitnami/servers/VTS.git"
  role :web, staging_server                          # This may be the same as your `Web` server
  role :app, staging_server                          # This may be the same as your `Web` server
  role :db,  staging_server, :primary => true # This is where Rails migrations will run
  server_root = "/home/bitnami/servers/VTS.git"
  set :branch, "staging"
end

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

namespace :custom_code do
  task :config_database_yml, :roles => :app do
    run  "ln -nfs #{server_root}/shared/system/database.yml #{server_root}/current/config/database.yml"
  end
  task :config_production_rb, :roles => :app do
    run "ln -nfs #{server_root}/shared/system/production.rb #{server_root}/current/config/environments/production.rb"
  end
  task :config_pdf_manuals, :roles => :app do
    run "ln -nfs #{server_root}/shared/system/VTS_English_User_Guide.pdf #{server_root}/current/public/downloads/VTS_English_User_Guide.pdf"
    run "ln -nfs #{server_root}/shared/system/VTS_Hindi_User_Guide.pdf #{server_root}/current/public/downloads/VTS_Hindi_User_Guide.pdf"
  end
end

after "deploy:symlink", "custom_code:config_database_yml"
after "deploy:symlink", "custom_code:config_production_rb"
after "deploy:symlink", "custom_code:config_pdf_manuals"
