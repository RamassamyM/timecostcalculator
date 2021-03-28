# Rails Application
## Made by Michael

## Installation

### Requirements on the system
- For Windows : WSL2 & Ubuntu
- Rbenv & Nvm (for managing versions of ruby and node)
- Ruby (for the language) & Node (for the installation of Javascript package with NPM/Yarn)
- Rails (gem) (for the app)
- PostgreSQL (for storing users and settings)
- Redis (key/value database for background jobs sending emails; it is used by sidekick job system)

- Febooti (or Linux Shell scripts) to schedule a daily task that will launch the expiry emailing system

### Installing the app
- git clone
- bundle install
- for sidekiq : bundle binstub sidekiq

- edit env file : with database password : 'TIMECOSTCALCULATOR_DATABASE_PASSWORD' (if necessary create user with password for PostgreSQL)
  - sudo -u postgres createuser -s appname
  - sudo -u postgres psql
  - \password appname
  Exit the PostgreSQL console with this command:
  - \q
  Edit config for database : 
  - config/database.yml
        production:
        <<: *default
        host: localhost
        adapter: postgresql
        encoding: utf8
        database: appname_production
        pool: 5
        username: <%= ENV['APPNAME_DATABASE_USER'] %>
        password: <%= ENV['APPNAME_DATABASE_PASSWORD'] %>
- Generate the secret key, which will be used to verify the integrity of signed cookies:
rake secret
First, set the SECRET_KEY_BASE variable like this (replace the highlighted text with the secret that you just generated and copied):

SECRET_KEY_BASE=your_generated_secret
Next, set the APPNAME_DATABASE_USER variable like this (replace the highlighted “APPNAME” with your your application name, and “appname” with your production database username):

APPNAME_DATABASE_USER=appname
Lastly, set the APPNAME_DATABASE_PASSWORD variable like this (replace the highlighted “APPNAME” with your your application name, and “prod_db_pass” with your production database user password):

APPNAME_DATABASE_PASSWORD=prod_db_pass
Save and exit.

You may view which environment variables are set for your application with the rbenv-vars plugin by running this command:

rbenv vars

Create Production Database
Now that your application is configured to talk to your PostgreSQL database, let’s create the production database:

RAILS_ENV=production rake db:create

Do it also : for these commands : 
- RAILS_ENV=production rails db:migrate db:seed
- rails c
    - create a user admin
- for production :
  - precompile assets and javascript with webpack :
    - You should also precompile the assets:

RAILS_ENV=production rake assets:precompile

- launch server in dev mode : rails s
- for binding for access in private network : rails server --binding=0.0.0.0
- to find the computer ip address : curl ifconfig.me


To test out if your application works, you can run the production environment, and bind it to the public IP address of your server (substitute your server’s public IP address):

RAILS_ENV=production rails server --binding=your_server_IP
Now visit this URL in a web browser:

http://your_server_IP:3000/

Check also : 
RAILS_ENV=production puma -p 3030
(working with Capistrano)
Note : 2013 : seems Puma only cares about RAILS_ENV when used with capistrano. Can you use RACK_ENV or use -e instead? That should work:

RACK_ENV=production bundle exec puma -p 3000

Check these websites for isntallation : 
https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-puma-and-nginx-on-ubuntu-14-04


## How to Start, Stop & Restart Services in Ubuntu

Services are essential background processes that are usually run while booting up and shut down with the OS.

### Method 1: Managing services in Linux with systemd
1. List all services
‘systemctl list-unit-files --type service -all‘

Combine it with the grep command and you can display just the 'yourname' services:

sudo systemctl | grep yourname



## 
Access issue in Windows installtion with WSL2 : 
WSL2 is a virtual environment with its own IP address on the computer.
To find this IP address : 
‘‘‘
ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
‘‘‘

Then if you cannot access to it in the network : you have to bind the port of the WSL2 to the port of the computer : 
(replace the IP address with the good one of the WSL2 Virtual Machine). This has to be entered in a Powershell (windows) terminal (not in the terminal of Ubuntu in the WSL2)
‘‘‘
netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=192.168.101.100
‘‘‘


https://www.youtube.com/watch?v=yCK3easuYm4



Note en vrac : 
The server can be run on a different port using the -p option. The default development environment can be changed using -e.

$ bin/rails server -e production -p 4000
The -b option binds Rails to the specified IP, by default it is localhost. You can run a server as a daemon by passing a -d option.


### Scheduled expiry emails
install redis : 
‘‘‘sudo apt-get install redis-server‘‘‘

Open a new terminal tab and run:
‘sidekiq‘
