replicon-code-challenge
=======================

This is my submission to the [Replicon](http://replicon.com) code challenge. It
is fully-featured in line with the requirements outlined
[here](docs/RepliconPreScreen.pdf).

# Download

```
git clone https://github.com/RaphaelDeLaGhetto/replicon-code-challenge.git
```

# Install dependencies

```
cd replicon-code-challenge
bundle install
npm install
```

# Configure

`config/application.yml` is where [figaro](https://github.com/laserlemon/figaro)
stores all your secret configuration details, so you need to create it manually:

```
vim config/application.yml
```

Paste this and save:

```
# General
app_name: 'replicon-code-challenge'
app_title: 'Replicon Demo Scheduler'

# Email
default_from: 'noreply@example.com'
#gmail_username: "noreply@example.com"
#gmail_password: "secretp@ssword"

# Production
#host: "example.com"
#secret_key_base: "SomeRakeSecretHexKey"
#provider_database_password: 'secretp@ssword'
```

# Database

```
rake db:create
rake db:migrate
```

# Tests

## Rails

```
rake
```

## React

```
npm test
```

# Run server

```
rails s
```
