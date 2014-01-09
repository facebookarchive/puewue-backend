# PUE/WUE Dashboard

An intergrated, full-stack web application, providing a dashboard for
displaying near real-time data from multiple data centers.

## Deploying the Dashboard

### Software requirements

In order to deploy this application, see [README](README.md) for the initial
requirements, plus a few extra requirements needed:

- Redis 2.6.x

Depending on your server platform, you will require to perform tasks like
asset compilation and ensuring the right settings are in place for the
application during deployment.

### Configuring the application

For the application to start, two minimum settings needs to be in place:
ElasticSearch and Redis connection options.

Those are taken from the environment variables ELASTICSEARCH_URL and REDIS_URL
respectively.

If you can't place those settings as environment variables (due server
limitations), feel free to place them into `.env.production` file on your
production environment. The `.env.production` file needs to live at the same
level as the default one (`.env` at the root of the repository).

Please refer to this file to see the other settings you can customize, including
the SFTP connection settings for data retrieval.

### Datacenter configuration

Given the Dashboard supports multiple datacenters, you will need to create a
configuration file, which will be used by both importer and presentation tasks.

Please take a look to `config/datacenters.sample.yml`, copy it as
`config/datacenters.yml` and tweak as you need.

### Deployment steps

At this time, you can use deployment strategies like Capistrano or EngineYard
cloud system.

For any of those, you will need to ensure the following:

- Environment variables (or the .env files) are in place
- Datacenter configuration is also in place
- Your deploy recipes ensure gems installation (via Bundler)

During installation, your recipes will need to ensure the application
dependencies are installed, so running `bundle install` should deal with it.

## Feeding data into the system

While the application pulls and display information from ElasticSearch, the
initial format it accepts for this data is a series of CSV files.

These files, named specially to identify each data center, can be imported in
two different ways: into the filesystem by `sftp:download` task or into Redis
as storage by `sftp:fetch` task.

In any of the cases, the format of the data is the same: a series of columns
that represent the time (timestamp) of the measurement and the metrics at that
time:

- PUE
- WUE
- Temperature
- Humidity
- Util KWh
- IT KWh
- Total Water Usage

Timestamps needs to be stored in UTC with no timezone reference so all data
can be presented independently of the timezone of the reading.

The following is an example on how an average CSV file will look like:

    Timestamp,PUE,WUE,Temp,humidity,UtilKWh,ITKWh,TotaWaterUsage
    2013-06-26 14:00:00.000,1.08,0.06,56.35,83.81999999999999,349.98,324.95,0.00
    ...

Floating point values will be depreciated after 3 decimals.

The application will attempt to import every row of the CSV files and will
present verbose information in the console when there is a problem with either
the CSV file or the import process.

### Naming the CSV files

As mentioned before, the name of those CSV files is important, since this name
is used to identify to which datacenter the data needs to be associated with.

For example, a Datacenter with `DC1` as `short_name` will require CSV files
with that short name at the beginning:

    DC1_Some_file.CSV

This is the only requirement for the CSV files as the measurements are already
self contained.

Please refer to [Datacenter configuration](#datacenter-configuration) to know
how to identify and name your datacenters.
