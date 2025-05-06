# LostNFound App

Web application for the Lost & Found platform that allows users to post or search for lost items.

Please also note the Web API that it uses: https://github.com/ForYourSafety/lostnfound-api/

## Install

Install this application by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

## Configuration

Copy the `config/secrets.yml.example` file to `config/secrets.yml` and fill in the required values.

To obtain a SESSION_SECRET, run the following command:

```shell
rake generate:session_secret
```

This will generate a random session secret that you can use in your `secrets.yml` file.

## Test

This web app does not contain any tests yet :(

## Execute

Launch the application using:

```shell
rake run:dev
```

The application expects the API application to also be running (see `config/app.yml` for specifying its URL)
