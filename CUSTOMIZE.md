# How to customize the dashboard

The following steps describe the necessary changes to customize the backend
and combine the open-source version with the frontend components.

## Requirements

Before we start, you need to ensure you have the requirements described in
[README](README.md):

- Ruby & Bundler
- Elasticsearch
- Redis
- Node.js

## Clone backend repository

We will use the backend repository as base and setup its source as `upstream`,
so we can use in the future to pull updates:

```console
$ git clone https://github.com/facebook/puewue-backend.git my-dashboard --origin upstream
...
$ cd my-dashboard
```

You would like to push the code as is to your own repository, so add it to
`origin` remote and push, e.g:

```console
$ git remote add origin git@myserver.com:my-dashboard.git
$ git push origin master -u
...
```

## Configurations

### Setup Datacenter information

Before we can move into anything, we need to setup the datacenter
configuration so application can run.

Copy `config/datacenters.sample.yml` as `config/datacenters.yml` and use as
base for your content.

Now, you can commit this file in the repository so the configuration is
persisted and can be deployed. Due default ignores, you will need to force
the addition to Git, e.g:

```console
$ git add --force config/datacenters.yml
$ git commit --message "Adding datacenters configuation"
...
```

### Setup local services configuration

Now with datacenter information, we need to customize the services which the
application is going to talk.

All this is managed via environment variables, and a sample can be found
in `.env.sample` (at the root of the codebase).

Copy this file as `.env.development` and customize to indicate the URL of
both Elasticsearch and Redis services.

Note: if you plan to run tests too, I recommend you also setup `.env.test`
configuration to avoid tests destroying your development data.

Important: contrary to the other configuration files, you must avoid
hardcoding services locations in your codebase, so do not commit this file
into your repository.

## Import frontend assets

For this application to be deployed, we need CSS, JS and sprite image used
by current HTML.

Invoke `assets:build` task, which will place these generated files
in `public/assets`:

```console
$ rake assets:build
...
```

Since these files most likely aren't going to change, we need them in our
codebase.

Please import them, similar to the import of `datacenters.yml`:

```console
$ git add --force public/assets/dashboard.min* public/assets/sprite.png
$ git commit -m "Add CSS/JS assets"
...
```

## Customize layout or HTML itself

Now we can proceed with your own customization of both `views/layout.erb` and
`views/index.erb`

Cheers!

