[![Gem Version](https://badge.fury.io/rb/turple.svg)](http://badge.fury.io/rb/turple)
[![Build Status](https://travis-ci.org/brewster1134/turple.svg?branch=master)](https://travis-ci.org/brewster1134/turple)
[![Coverage Status](https://coveralls.io/repos/brewster1134/turple/badge.png)](https://coveralls.io/r/brewster1134/turple)

# Turple
recursive templating

Turple supports processing the following...

* directories
* single files
* strings (booorrrinnnng)

### Usage

I always make projects the same way.  There are a bunch of tools for making this faster, but i didnt like any of them.  This is what i like.

Turple takes any kind of template format you want, a bunch of data, and in*turple*ates it.

Turple accepts 3 arguments
* a path to a directory, a path to a file, or a string
* an object of data
* some options

Say you have a super simple project template like this... (these are the actual file and directory names, and this convention is the turple default)
```shell
~/Code/templates/mini_ruby_project/
 |_ [PROJECT.NAME]
      |_ lib
         |_ [PROJECT.NAME].rb
```

And the `[PROJECT.NAME].rb` file contains...
```ruby
class <>project.class<>
  def initialize
    puts 'hello <>greeting<>'
  end
end
```

So then you want to make a new project, so you go...

```ruby
require 'turple'

Turple.new '~/Code/templates/mini_ruby_project', {
  project: {
    name: 'project_foo',
    class: 'ProjectFoo'
  },
  greeting: 'world!'
}, {
  options: 'more about options below...'
}
```

And now you have a new directory!
```shell
~/Code/templates/mini_ruby_project/
 |_ project_foo
      |_ lib
         |_ project_foo.rb
```

And the `project_foo.rb` file now contains...
```ruby
class ProjectFoo
  def initialize
    puts 'hello world!'
  end
end
```

### Development & Testing

```shell
gem install yuyi
yuyi -m https://raw.githubusercontent.com/brewster1134/turple/master/yuyi_menu
bundle install
bundle exec guard
```
