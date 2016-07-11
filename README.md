# toygun

it's a bunch of state machines that can be serialized to a database for concurrency/failure tolerance

# requirements

    postgres, redis, `bundle install`

# tests

    bundle exec rspec

# db

    createdb toygun_test
    bundle exec rake db:setup

    bundle exec rake db:

# info

check out lib/toygun/* for the mechanics

lib/resources/* for examples

