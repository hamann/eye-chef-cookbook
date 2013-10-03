bundle install --path vendor/bundle
vagrant plugin install vagrant-berkshelf vagrant-omnibus
bundle exec kitchen test
