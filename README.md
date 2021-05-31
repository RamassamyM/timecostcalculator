# Rails Application
## Made by Cosmike.com

# Installation

## Required installations on the system
- For Windows : WSL2 & Ubuntu
- Rbenv & Nvm (for managing versions of ruby and node)
- Ruby (for the language) & Node (for the installation of Javascript package with NPM/Yarn)
- Rails (gem) (for the app)
- PostgreSQL (for storing users and settings)
- Redis (key/value database for background jobs sending emails; it is used by sidekick job system)

- Febooti (or Linux Shell scripts) to schedule a daily task that will launch the expiry emailing system

### Scheduled expiry requirements
You need redis as a database storage for jobs, if not installed, install on linux like that: 
```bash
sudo apt-get install redis-server
sudo service redis-server start
```

## App installation
### Importing codebase from Github
```bash
git clone git@github.com:RamassamyM/timecostcalculator.git
```
### Installing dependencies
```bash
bundle install
```
`bundle install --without development test` in production

For sidekiq (that monitors email sending jobs with rails) installation :
```bash
bundle binstub sidekiq
```
```
yarn
```

### Installing secrets
create a master.key file in config folder with the master
or EDITOR="nano --wait" bin/rails credentials:edit


## Production installation
### Configuring database
Create .env file in the root folder of the app : add key & values : 
  -database credentials : 
  ```yaml
  TIMECOSTCALCULATOR_DATABASE_PASSWORD=xxx
  TIMECOSTCALCULATOR_DATABASE_USERNAME=xxx
  ```
  Then create the user & password in PostGreSQL : 
  ```bash
  sudo -u postgres createuser -s xxx
  sudo -u postgres psql
  \password xxx
  ```
  or you can create in psql cli but you do not need to create database with the same name as in .env file)
  ```bash
  sudo -u postgres psql
  postgres=# create database mydb;
  postgres=# create user myuser with encrypted password 'mypass';
  postgres=# grant all privileges on database mydb to myuser;
  ```
  To launch postgreSQL cli interface on Mac OS: 
  ```bash
  psql postgres
  ```
  then
  ```postgres
  postgres=# CREATE ROLE xxxx WITH LOGIN PASSWORD 'xxxxx'; 
  postgres=# \du
  ```
  - Exit the PostgreSQL console with this command: `\q`
  - Check if config for database is good in `config/database.yml` :
  ```yaml
    production:
    <<: *default
    host: localhost
    adapter: postgresql
    encoding: utf8
    database: appname_production
    pool: 5
    username: <%= ENV['TIMECOSTCALCULATOR_DATABASE_USER'] %>
    password: <%= ENV['TIMECOSTCALCULATOR_DATABASE_PASSWORD'] %>
  ```
  - Generate the secret key, which will be used to verify the integrity of signed cookies:
  ```bash
  rake secret
  ```
  - Add the secret key to your .env file :
  ```yaml
  SECRET_KEY_BASE=your_generated_secret
  ```
### Creating production database & seeding database with initial data
- Create Production Database
```bash
RAILS_ENV=production rake db:create
```
- Launch migrations to generate tables in database and fill up with data from seed :
```bash
RAILS_ENV=production rails db:migrate db:seed
```
- Create a User admin : launch rails console 
```bash
RAILS_ENV=production rails c
```
and then type :
```ruby
User.create(email:'', password: '', admin: true)
```
### Configuring SMTP for production :
In `timecostcalculator/config/initializers/smtp.rb` update gmail_username and gmail_password

Note: at the beginning emails will arrive in SPAM in the mail boxes of the recipients.
Make sure to send first emails with the email account to these recipients and make sure they accept in not spam and reply to you


### Launching in production with Rails and Puma: 

1. Check that you serve assets from Rails and not set for Nginx of Apache : 
make a change in `config/environments/production.rb`
  ```ruby
    config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
    to
    config.public_file_server.enabled = true
  ```

2. Set webpack for production (see bin/webpack) : for that you need to add in your .env :
```yaml
RAILS_ENV=production
RACK_ENV=production
NODE_ENV=production
```
3. Compile assets for production : 
(To make it a clean and straightforward compile job, you need to delete public/assets and public/packs folder)
  ```yaml
    RAILS_ENV=production rake assets:precompile
    RAILS_ENV=production RACK_ENV=production NODE_ENV=production bin/webpack
  ```

4. Launch Rails server binding to the public IP address of the server: 
  ```bash
    rails server -e production -p 3000 --binding=0.0.0.0
  ```
  You can run a server as a daemon by passing a -d option.
  To find the computer ip address : 
  ```bash
  curl ifconfig.me
  ```
  You can also set the public IP address directly :
  ```bash
  RAILS_ENV=production rails server --binding=your_server_IP
  ```
  Note if you face any problem, you can try : 
  ```bash
  RACK_ENV=production bundle exec puma -p 3000
  ```

5. Launch Sidekiq in a new tab :
  ```bash
    sidekiq
  ```

6. Now visit this URL in a web browser:
  http://your_server_IP:3000/
  Login as admin user & change settings for csv files

  **Do not forget to write / at the end of the directory path**
  
### Installation helps
- Check these websites for installation : 
https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-puma-and-nginx-on-ubuntu-14-04

- See if necessary:
https://www.youtube.com/watch?v=yCK3easuYm4

## How to Start, Stop & Restart Services in Ubuntu

Services are essential background processes that are usually run while booting up and shut down with the OS.

### Method 1: Managing services in Linux with systemd
- List all services
```bash
systemctl list-unit-files --type service -all
```
Combine it with the grep command and you can display just the `yourname` services:
```bash
sudo systemctl | grep yourname
```

## To bind Rails with IP address in Windows and WSL2 Linux environment
- WSL2 is a virtual environment with its own IP address on the computer.
- To find this IP address : 
```bash
ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
```

- Then if you cannot access to it in the network : you have to bind the port of the WSL2 to the port of the computer : 
(replace the IP address with the good one of the WSL2 Virtual Machine). This has to be entered in a Powershell (windows) terminal (not in the terminal of Ubuntu in the WSL2)
```bash
netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=192.168.101.100
```
