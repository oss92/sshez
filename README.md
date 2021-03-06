# Sshez
[![Dependency Status](https://gemnasium.com/GomaaK/sshez.svg)](https://gemnasium.com/GomaaK/sshez)
[![Gem Version](https://badge.fury.io/rb/sshez.svg)](https://badge.fury.io/rb/sshez)
[![Code Climate](https://codeclimate.com/github/GomaaK/sshez/badges/gpa.svg)](https://codeclimate.com/github/GomaaK/sshez)
[![Inline docs](http://inch-ci.org/github/GomaaK/sshez.svg?branch=master)](http://inch-ci.org/github/GomaaK/sshez)
[![security](https://hakiri.io/github/GomaaK/sshez/master.svg)](https://hakiri.io/github/GomaaK/sshez/master)
![](http://ruby-gem-downloads-badge.herokuapp.com/sshez?type=total)

If you have multiple servers that you access on daily bases! sshez helps you configure your ssh/config file so you will never need to remember ip or ports again.

### Example

Add an alias `mw_server`

    sshez add mw_server root@74.125.224.72 -p 120

you will be able to use

    sshez connect mw_server

## Installation

    $ gem install sshez

## Usage

    sshez -h

    Usage:
        sshez add <alias> (role@host) [options]
        sshez connect <alias>
        sshez remove <alias>
        sshez list
        sshez reset

    Specific options:
        -p, --port PORT                  Specify a port
        -i, --identity_file [key]        Add identity
        -b, --batch_mode                 Batch Mode
        -t, --test                       Writes nothing

    Common options:
        -v, --version                    Show version
        -h, --help                       Show this message

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Gomaak/sshez. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).



## Missing

*   All the other options in [ssh documentation](http://linux.die.net/man/5/ssh_config)
