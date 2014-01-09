# Facebook Power

Simple application that displays Facebook's datacenter power consumption and
other information.

For detailed information on the application's front-end architecture, please visit the [wiki]("https://github.com/LyricaMcT/PUE-WUE-Dashboard/wiki/PUE-WUE-Dashboard").

## Development requirements

To run this application locally, you will need:

- Ruby 1.9.3 (see patchlevel in .ruby-version)
- Bundler (`gem install bundler`)
- Foreman (`gem install foreman`)
- ElasticSearch (0.20.4 at this time)

### Installing dependencies

Thanks to Bundler, installing dependencies is easy. Simply run `bundle install`
inside the root of the application.

### Running the application locally

Before running the application, please start ElasticSearch first by doing:

    bin/elasticsearch -f

Later you can `Ctrl+C` to stop it.

Once dependencies have been installed, you can run the application locally by
doing:

    foreman start -f Procfile.dev

That will start `web` and other defined process needed during development.

You will normally access the application by visiting `http://localhost:5000/`
(Port 5000 is the default by foreman)

### Populating local data

To test the application locally, it will be necessary populate ElasticSearch
with enough information to generate histograms.

First, start ElasticSearch and then perform the following tasks:

    rake db:reset

To reset the `measurements` index in ElasticSearch. Next:

    rake db:populate

Which will generate enough data going back 5 days by default. You can generate
more data by providing an option to db:populate:

    rake db:populate[10]

To generate 10 days back of data.

If you want to populate recent (less than 24 hours), use `1` as option.

After this, the data is processed as timeline and available at the following
URL:

    http://localhost:5000/timeline/center-1/24-hours.json

Where `center-1` represents the Datacenter and `24-hours` the time period to
be used.

Please see [timeline.rb](lib/power/timeline.rb) for other available periods.

### Configuration and environment variables

This project follows the principle of [Twelve-Factor App](http://12factor.net/) design,
so no configuration file is stored in the repository.

All configuration is loaded from environment variables.

To avoid forcing you setup those variables in your environment, you can copy the
`KEY=VALUE` of those into `.env.development` file, which has been excluded
from the repository.

For example, to setup SFTP credentials, do the following:

    echo 'SFTP_URL=sftp://me@localhost/data/pue_wue' >> .env.development
    echo 'SFTP_KEY=sftp_private.key' >> .env.development

You can overload and customize specific variables when running tests (so your
development data doesn't get clobbered).

Simply create `.env.test` with the environment variables you need, for example,
`REDIS_URL`

    # .env
    REDIS_URL=redis://localhost:6379/0

    # .env.test
    REDIS_URL=redis://localhost:6379/2

This will use a different URL when running tests (in this case, a different
DB on the same Redis).

## Deployment

For deployment instructions, please see [DEPLOY](DEPLOY.md) document.

## Licensing

The source of this project is licensed under Apache License 2.0. See [LICENSE](LICENSE).
