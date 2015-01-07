[![Gem Version](https://badge.fury.io/rb/turple.svg)](http://badge.fury.io/rb/turple)
[![Build Status](https://travis-ci.org/brewster1134/turple.svg?branch=master)](https://travis-ci.org/brewster1134/turple)
[![Coverage Status](https://coveralls.io/repos/brewster1134/turple/badge.png)](https://coveralls.io/r/brewster1134/turple)

# Turple
Quick project templating, with optional cli wizard support

Turple can take a custom template and use it to bootstrap projects structures you commonly use instead of **copy/pasting** an old project and **find/replacing** to make it a new project.

### Install
```sh
gem install turple
```

Optionally you can create a `Turplefile` in your home directory *(~/Turplefile)* and include your own custom sources, and even common template data. This will prevent you from having to define your sources everytime you create a new project.

```yaml
sources:
  my_remote_source: my_github_user/turple-templates
  my_local_source: ~/Documents/turple-templates
data:
  developer:
    name: Jane Doe
```

### Usage

I always make projects the same way. There are a bunch of tools for (supposedly) making this easier/faster, but I don't like any of them. They are either too opinionated or too limiting. This is what I like.

Turple takes any kind of template format you want, a bunch of data, and in*turple*ates it.

Turple is best used from a command line, but it can be used directly in ruby as well. **CLI FIRST...**

### CLI

Turple requires a path to a template, and an optional destination. If no destination is passed, it will put everything in a `turple` folder in your current working directory.

```sh
turple --template /path/to/template --destination my_new_project_name

# or with shorter aliases
turple -t /path/to/template -d my_new_project_name
```

Turple will scan the template, determine what data is needed to process it, and prompt you for any missing data. If you wanted to run turple without the wizard, just put a `Turplefile` into your destination directory with the necessary data. Assuming our template requires a single piece of information called `foo`, our destination Turplefile could look something like this.

```yaml
data:
  foo: bar
```

### Turplefile

`Turplefile` files are yaml formatted files that provided various information to turple.  Turple checks in multiple locations for a Turplefile.

* Home Directory *(~/Turplefile)*
  * Define your own custom defaults...  Set your sources, preferred template configuration, and even common template data *(e.g. developer.name)*
* Template
  * Templates require a Turplefile with a configuration *(esp if different from the turple defaults)* and an optional data map for use with the wizard.
* Destination
  * This file can have preset data (good for bypassing the wizard)

### Turple Templates

A turple template is simply a directory containing a Turplefile, and any amount of custom folders and files your project template needs. The Turplefile inside a template has different data than a destination file. It has instructions on how to prompt a user for data, and the configuration details on how the template is built. _This example uses the default turple configuration._

###### Remote Template
You can easily use remote templates directly, or share other user's templates by passing turple a remote source in addition to a template name. Simply separate the source name from the template name with 2 hashes (`##`).

Turple uses the [Sourcerer](https://github.com/brewster1134/sourcerer) gem to download remote sources to a tmp directory, so you can use any supported Sourcerer format *(including github shorthand!)*

```
turple -t brewster1134/turple_templates##javascript
```

To customize a template, you can modify the configuration in a template's Turplefile

### Configuration

```yaml
name: Foo Project Template
configuration:
  file_ext: turple
  path_regex: '\[([A-Z_\.]+)\]'
  path_separator: .
  content_regex: '<>([a-z_\.]+)<>'
  content_separator: .
data_map:
  foo: What is the foo called?
```

* `name` is just a friendly name for the template. its optional. we can use the template directory name for that.
* `configuration` has some very important details. (again, these are the defaults, so if your template does not have a custom configuration, it uses these values)
  * `file_ext` is the file extension turple looks for to tell it there is content inside the file that needs processed
  * `path_regex` this is a string representing a regex match to variable names
  * `path_separator` this is a string representing a character(s) to seperate variables strung togehter
  * `content_regex` & `content_separator` are the same as with a path, but to match file contents rather than a path.
* `data_map` is a hash that matches the same structure as the data required for a template, but instead provides the details to prompt a user in case a peice of required data is missing.

## Example Template

Say you design a template using the turple default configuration, and you create a file structure like so...
```
foo_template
  |__ my_[FOO.BAR]_dir
  |   |
  |   |__ my_[FOO.BAZ]_file.txt.turple
  |
  |__ Turplefile
```

and say your `my_[FOO.BAZ]_file.txt.turple` file contains the following
```
This <>foo.baz<> file is in the <>foo.bar<> folder.
```

With a simple Turplefile containing...
```
name: Foo Template
data_map:
  foo:
    bar: What is the foo bar?
    baz: What is the foo baz?
```

* Notice how the path variables match the `path_regex`
* Notice how the separator of the path variables match the `path_separator`
* Notice how the content variables match the `content_regex`
* Notice how the separator of the content variables match the `content_separator`

**Let's run Turple!**
```sh
Saving to: /your/current/directory/turple
There is some missing data. You will be prompted to enter each value.
What is the foo bar?
>>> # enter your value here
What is the foo baz?
>>> # enter your value here
================================================================================
                              !TURPLE SUCCESS!
================================================================================
Turpleated `Foo Template` to a new project `turple`
Paths Turpleated: 2
   Turpleated in: 1.1ms
================================================================================
```

### Ruby
You can run turple directly in ruby if needed as well. _This example matches the template from the above example._

```ruby
require 'turple'

Turple.ate '~/Code/templates/mini_ruby_project', {
  :foo => {
    :bar => 'foobar',
    :baz => 'foobaz'
  }
}, {
  :destination => '/path/to/your/new/project',
}
```

most notably the passing of the destination in the 3rd argument _(the configuration hash)_

### Development & Testing
```shell
gem install yuyi
yuyi -m https://raw.githubusercontent.com/brewster1134/turple/master/yuyi_menu
bundle install
bundle exec guard
```
