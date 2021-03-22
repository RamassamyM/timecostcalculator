# Rails Application
## Made by Michael

## Installation

- git clone
- bundle install
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


Check these websites for isntallation : 
https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-puma-and-nginx-on-ubuntu-14-04
