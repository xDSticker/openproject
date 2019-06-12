# OpenProject 8.x to OpenProject 9.x Debian/Ubuntu Upgrade Guide (Manual installation)

OpenProject 9.x is being released at https://github.com/opf/openproject under the branch `stable/9`.
Follow the following steps to perform the upgrade:

First, perform a backup for your current environment

```bash
[openproject@debian]# cd /home/openproject/openproject
[openproject@debian]# RAILS_ENV="production" bundle exec rake backup:database:create
# Backup will be created under backup/
```

Depending on from what version you're upgrading, you may need to add the correct remote
Then, check out the stable version of OpenProject 9.x.

```bash
[openproject@debian]# cd /home/openproject/openproject
[openproject@debian]# git remote -v | grep openproject-ce
```

If this returns anything, update the remote to the correct URL.

```bash
[openproject@debian]# git remote set-url origin https://github.com/opf/openproject.git
```

Then, refresh that origin and checkout the stable/9 branch.

```bash
[openproject@debian]# git fetch && git checkout stable/9
```

After upgrading the installation files, you need to migrate the installation to OpenProject 9.0 with the following steps:

```bash
[openproject@debian]# cd /home/openproject/openproject
[openproject@debian]# rm -rf frontend/node_modules && npm install
[openproject@debian]# RAILS_ENV="production" bundle exec rake db:migrate
[openproject@debian]# RAILS_ENV="production" bundle exec rake db:seed
[openproject@debian]# RAILS_ENV="production" bundle exec rake assets:precompile
[openproject@debian]# touch tmp/restart.txt
```

After performing these steps, the server should be running OpenProject 9.0.x.


## Upgrade notes

These following points are some known issues around the update to 9.0.
It does not contain the entire list of changes.

To see all changes, [please browse the release notes](https://www.openproject.org/release-notes/openproject-9-0-0/).

### MySQL is being deprecated

OpenProject 9.0. is deprecating MySQL support. You can expect full MySQL support for the course of 9.0 releases, but we
are likely going to be dropping MySQL completely in one of the following releases.

For more information regarding motivation behind this and migration steps, please see https://www.openproject.org/deprecating-mysql-support/
In this post, you will find documentation for a mostly-automated migration script to PostgreSQL to help you get up and running with PostgreSQL.

# OpenProject 7.x to OpenProject 8.x Debian/Ubuntu Upgrade Guide (Manual installation)

OpenProject 8.x is being released at https://github.com/opf/openproject-ce using the branch `stable/8`.
Follow the following steps to perform the upgrade:

These following points are some known issues around the update to 8.0. It does not contain the entire list of changes. To see all changes, [please browse the release notes](https://www.openproject.org/release-notes/openproject-8-0/).

### Migration from Textile to Markdown

OpenProject 8.0. has removed Textile, all previous content is migrated to GFM Markdown using [pandoc](https://pandoc.org). This will happen automatically during the migration run. A recent pandoc version will be downloaded by OpenProject.

For more information, please visit this separate guide: https://github.com/opf/openproject/tree/dev/docs/user/textile-to-markdown-migration

### Frontend changes, Angular is now in production

OpenProject 8.0. uses Angular for the majority of the frontend application. The `npm install` step should automatically take care of the installation, however in some cases there were leftover `node_modules` entries that resulted in an incomplete frontend application. To ensure the correct versions are installed, we thus recommend you remove `frontend/node_modules` entirely before running `npm install` again.

### SQL mode changes for MySQL 8.0.

MySQL 8.0. removes the deprecated SQL mode `no_auto_create_user` that we enforced up until 7.4. You will need to remove this mode from your `config/database.yml` should you have used it. For more information, see https://community.openproject.com/wp/28524

# OpenProject 6.x to OpenProject 7.x Debian/Ubuntu Upgrade Guide (Manual installation)

Please look at the steps in the section about the upgrade to OpenProject 6.0. OpenProject 7.x is being released under the branch `stable/7`. The other steps are identical.

### Frontend changes, bower is no longer required

With OpenProject 7.0., we no longer depend on `bower` for some on the frontend assets. Please ensure you remove `<OpenProject root>/frontend/bower_components` and `<OpenProject root>/frontend/bower.json`.

### When running with MySQL: Required changes in sql_mode

If you're upgrading to OpenProject 7.x with a MySQL installation, you will need to update your database.yml to reflect some necessary changes to MySQL `sql_mode` made as part of the migration to Rails 5. Please see the `config/database.yml.example` file for more information.

# OpenProject 5.0.x to OpenProject 6.0 Debian/Ubuntu Upgrade Guide

Upgrading your OpenProject 5.0.x installation to 6.0 is very easy. Please upgrade your OpenProject installation first to the latest stable 6.0 path.
If you checked out the OpenProject installation through Git, you can use the `stable/6` branch which points to the latest stable release.

```bash
[openproject@debian]# cd /home/openproject/openproject
[openproject@debian]# git fetch && git checkout stable/6
```

After upgrading the installation files, you need to migrate the installation to OpenProject 6.0 with the following steps:

```bash
[openproject@debian]# cd /home/openproject/openproject
[openproject@debian]# npm install
[openproject@debian]# RAILS_ENV="production" bundle exec rake db:migrate
[openproject@debian]# RAILS_ENV="production" bundle exec rake db:seed
[openproject@debian]# RAILS_ENV="production" bundle exec rake assets:precompile
[openproject@debian]# touch tmp/restart.txt
```

After performing these steps, the server should be running OpenProject 6.0.x.


# OpenProject 4.2 to OpenProject 5.0 Debian/Ubuntu Upgrade Guide

One of the main new features of OpenProject 5.0 is that it provides management of repositories directly within the user interface (with so-called *managed* repositories).

Starting with OpenProject 5.0, you can explicitly select the SCM vendor you want to associate to your project, and let OpenProject generate the repository on the filesystem on the fly.

If you haven't configured serving repositories through Apache before, you'll find the [repository integration guide](./repository-integration.md) to guide you through the necessary steps to configure this integration.

For the other steps necessary to upgrade to OpenProject 5.0 please look
at the sections below and exchange `v4.1.0` with `v5.0.0`.

## Changed Rails Path

OpenProject 5.0 employs Rails 4.2.x, which contains a number of changes regarding paths. Foremost, files previously located in the `scripts` directory now reside in `bin` (e.g., `delayed_job`).

### Secret Token

With an update to Rails 4.1+, you now must generate a secret key base for the production environment with `./bin/rake secret` and make that available through the environment variable `SECRET_KEY_BASE`.

You will likely set the environment variable in `/etc/environment` or use your server's environment mechanism (i.e., `SetEnv` in Apache).

## Upgrading to Managed Repositories

You can create repositories explicitly on the filesystem using managed repositories.
Enable managed repositories for each SCM vendor individually using the templates
defined in configuration.yml. For more information, please refer to the [repository integration guide](./repository-integration.md).

This functionality was previously provided as a cron job `reposman.rb`.
This script has been integrated into OpenProject.
Please remove any existing cronjobs that still use this script.

### Convert Repositories Created by Reposman

If you want to convert existing repositories previously created (by reposman.rb or manually)
into managed repositories, use the following command:

    $ ./bin/rake scm:migrate:managed[URL prefix (, URL prefix, ...)]

the URL prefix denotes a common prefix of repositories whose status should be upgraded to `:managed`.
Example:

If you have executed reposman.rb with the following parameters:

    $ reposman.rb [...] --svn-dir "/opt/svn" --url "file:///opt/svn"

Then you can pass the task a URL prefix `file:///opt/svn` and the rake task will migrate all repositories
matching this prefix to `:managed`.
You may pass more than one URL prefix to the task.

### Listing Potential Conflicting Identifiers

As managed repositories on the filesystem are uniquely associated using the project identifier, any existing directories in the managed repositories root *may* cause a conflict in the future when trying to create a repository with the same name.

To help you identify these conflicts, you can run the following rake task, which will list entries in the managed repositories path with no associated project:

    $ ./bin/rake scm:find_unassociated

# OpenProject 4.1 to OpenProject 4.2 Debian/Ubuntu Upgrade Guide

Please look at the steps in the section about the upgrade to OpenProject 4.1. Just exchange `v4.1.0` to `v4.2.0` when checking out the git repository.

# OpenProject 4.0 to OpenProject 4.1 Debian/Ubuntu Upgrade Guide

This guide describes the upgrade process from OpenProject 4.0 to 4.1 on Debian 7.7 and Ubuntu 14.04 LTS step by step.

Note: We strongly recommend to update your OpenProject installation to the latest available 4.0 version (currently 4.0.9), before attempting an update to 4.1.


## Preparation

* Backup your current Openproject installation. Typically you should backup the attachment
  folder of your installation, the subversion repositories (if applicable) and your database.
  For more information please have a look at our [backup guide](backup-guide.md)

* Before Upgrading, check that all the installed OpenProject plugins support the new
  OpenProject version. Remove incompatible plugins before attempting an upgrade. Stop
  the OpenProject Server. You may even add a maintenance page, if you feel comfortable
  with that.

* If you run the worker process with a cronjob, disable the cronjob temporarily.
* Stop the (delayed\_job) worker process. In case you run the worker process through
  `RAILS_ENV=production bundle exec script/delayed_job start`, execute the following:
  `RAILS_ENV=production bundle exec script/delayed_job stop`.

## Update your system

```bash
[root@debian]# apt-get update
[root@debian]# apt-get upgrade
```

## Get the new OpenProject Source Code
Change into the directory where OpenProject is installed and switch to the operating-system-user the OpenProject operates as. We assume that OpenProject is installed in `/home/openproject/openproject` by the `openproject` user.

```bash
[root@debian]# su - openproject -c "bash -l"
[openproject@debian]# cd ~/openproject/openproject
```

Remove manual changes and modifications (If you have modified OpenProject source files and want to preserve those changes, back up your changes, and re-apply them later):

```bash
[openproject@debian]# git reset --hard
[openproject@debian]# git fetch
[openproject@debian]# git checkout v4.1.0
```

## Upgrade Ruby
OpenProject 4.1 requires Ruby to be installed in version 2.1.x. Assuming you have installed Ruby via RVM, do the following to upgrade your Ruby installation:

```bash
[openproject@debian]# rvm get stable
[openproject@debian]# export -f rvm_debug
[openproject@debian]# rvm install 2.1.5
[openproject@debian]# rvm use --default 2.1.5
[openproject@debian]# gem install bundler
[openproject@debian]# bundle install
```

### Update application server configuration
This sections only applies to you, if you serve OpenProject via Apache and Passenger. If you serve OpenProject in a different way, be sure to check that it still works.

During the upgrade of the Ruby version, we have potentially installed a new Ruby and Passenger version. The versions of Ruby and Passenger appear in the Apache configuration like this:

```apache
LoadModule passenger_module /home/openproject/.rvm/gems/ruby-2.1.4/gems/passenger-4.0.53/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
  PassengerRoot /home/openproject/.rvm/gems/ruby-2.1.4/gems/passenger-4.0.53
  PassengerDefaultRuby /home/openproject/.rvm/gems/ruby-2.1.4/wrappers/ruby
</IfModule>
```
Please run the following commands to upgrade passenger and re-install the Apache module:

```bash
[openproject@debian]# gem update passenger
[openproject@debian]# gem cleanup passenger
[openproject@debian]# passenger-install-apache2-module
```

The output of passenger-install-apache2-module2 tells you how to configure Apache. It is basically the same as what is already installed, except for the updated version numbers.

Don’t forget to restart apache after the configuration change:

```bash
[root@debian]# service apache2 reload
```

## Node.js installation
Node.js is necessary to precompile the assets (JavaScript and CSS). We will install the latest 0.12.x version of Node.js via nodeenv:

```bash
[openproject@debian]# exit
[root@debian]# apt-get install python python-pip
[root@debian]# pip install nodeenv
[root@debian]# su - openproject -c "bash -l"
[openproject@debian]# cd /home/openproject
[openproject@debian]# nodeenv nodeenv
[openproject@debian]# source ./nodeenv/bin/activate
```

As a reference, the following Node.js and NPM versions have been installed on our system:

```bash
[openproject@debian]# node --version
                      v0.12.2
[openproject@debian]# npm --version
                      1.4.28
```

## The Upgrade

Now that the sources and dependencies are in place, you can migrate the Database and do the upgrade.

Before actually migrating the database, please remove all temporary files from the previous installation (caches, sessions) by running the following command.

```bash
[openproject@debian]# cd /home/openproject/openproject
[openproject@debian]# RAILS_ENV="production" bundle exec rake tmp:clear
```

If you do not clear the temporary files, you may encounter an error of the form `NoMethodError: undefined method `map' for #<String ..>` in the `config/initializers/30-patches.rb` files.
The actual upgrade commands are as follows:

```bash
[openproject@debian]# cd /home/openproject/openproject
[openproject@debian]# npm install
[openproject@debian]# RAILS_ENV="production" bundle exec rake db:migrate
[openproject@debian]# RAILS_ENV="production" bundle exec rake db:seed
[openproject@debian]# RAILS_ENV="production" bundle exec rake assets:precompile
[openproject@debian]# touch tmp/restart.txt
```

To make sure that all work package attachments are indexed, so that their content can be used in work package filters
run:

```bash
[openproject@debian]# RAILS_ENV="production" rake attachments:extract_fulltext_where_missing
```



*Side note:* If you are using `RAILS_ENV="development"` the task `bundle exec rake assets:webpack` needs to be run. This step is not necessary for `production` because it is part of the `asset:precompile` tasks.

**NOTE** `db:seed` can also be invoked with a 'LOCALE' environment variable defined, specifying the language in which to seed. Note however, that specifying different locales for calls to `db:seed` might lead to a mixture of languages in your data. It is therefore advisable to use the same language for all calls to `db:seed`.

## The Aftermath
* Re-enable the `delayed_job` cron job that was disabled in the first step.
* If you have put up a maintenance page, remove it.
* Start the OpenProject server again
* Watch for further OpenProject updates in our news, or on twitter.

## Questions, Comments, and Feedback
If you have any further questions, comments, feedback, or an idea to enhance this guide, please tell us at the appropriate forum.

Also, please take a look at the Frequently [Asked Questions](https://www.openproject.org/help/faq/).
