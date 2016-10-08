[![gem version](https://badge.fury.io/rb/Turple.svg)](https://badge.fury.io/rb/Turple)
[![dependencies](https://gemnasium.com/brewster1134/Turple.svg)](https://gemnasium.com/brewster1134/Turple)
[![docs](http://inch-ci.org/github/brewster1134/Turple.svg?branch=master)](http://inch-ci.org/github/brewster1134/Turple)
[![build](https://travis-ci.org/brewster1134/Turple.svg?branch=master)](https://travis-ci.org/brewster1134/Turple)
[![coverage](https://coveralls.io/repos/brewster1134/Turple/badge.svg?branch=master)](https://coveralls.io/r/brewster1134/Turple?branch=master)
[![code climate](https://codeclimate.com/github/brewster1134/Turple/badges/gpa.svg)](https://codeclimate.com/github/brewster1134/Turple)
[![omniref](https://www.omniref.com/github/brewster1134/Turple.png)](https://www.omniref.com/github/brewster1134/Turple)

# Turple
###### Build projects from complex directory structures
---
Most template solutions process the contents of a single file. _**But Turple...**_
###### Turple can...
* Process entire directory structures
* Interpolate both file contents and folder/file names
* Create projects from other projects
* Create projects interactively with a command line tool
* Build projects from remote templates

###### Turple is...
* Great for creating new projects based on your desired directory structure
* Great for quickly creating your opinionated projects exactly how you like them
* Great for sharing your project architecture

###### Turple is not...
* A templating _language_ and does not support template logic

###### Turple requires...
* OSX
* Ruby >= 2.0.0p247

### Install

```sh
# install the Turple gem
gem install Turple

# create a Turplefile configuration file in your home directory
Turple init
```

### Usage
#### From the command line...

```sh
# just run Turple! It will prompt you to enter all the required information
Turple

# to view other options
Turple help
```

#### In a ruby project...

```ruby
# with a local template or an existing Turple project...
Turple.ate template: '/name/or/path/to/template/or/existing/project', project: '/path/to/new/project'

# to use a specific template from a specific source...
Turple.ate source: 'brewster1134/Turple-templates', template: 'javascript', project: '/path/to/new/project'
```

### History
I always make projects the same way. With every new project, I create all the same folders & configure all the same files.

Copy/Pasting is a pain, since you have to go through and rename all your classes and namespaces, delete all the library specific code, and remove most of the library specific files.

Scaffolding tools like Yeoman are neat, but they setup opinionated projects based on someone else's opinion. Every library or tool you want to use, requires the tool to build support for it; And most of the options they support, I don't need. When it tried to cleverly assemble everything I wanted, I would still end up having to groom and modify it anyways.

So I started building Turple.

I could create a bare-bones directory structure with all the crazy customizations I wanted, create placeholder variables in both the file contents and the file/folder names, then run Turple to build my new project.

Instead of being prompted for what technologies I wanted to use, I would be prompted to fill in my variables.

Or to make things even quicker, I could just edit the yaml file in the project with the variable values, then just run Turple to build the new project.




# TODO: ALL THE DOCUMENTATION BELOW NEEDS UPDATED




### Turplefile

`Turplefile` files are yaml formatted files that provided various information to Turple. Turple checks in multiple locations for a Turplefile.

* Home Directory *(~/Turplefile)*
  * Define your own custom defaults... Set your sources, preferred template configuration, and even common template data *(e.g. developer.name)*
* Template
  * Templates require a Turplefile with a configuration *(esp if different from the Turple defaults)* and an optional data map for use with the wizard.
* Destination
  * This file can have preset data (good for bypassing the wizard)

### Turple Templates

A Turple template is simply a directory containing a Turplefile, and any amount of custom folders and files your project template needs. The Turplefile inside a template has different data than a destination file. It has instructions on how to prompt a user for data, and the configuration details on how the template is built. _This example uses the default Turple configuration._

###### Remote Template

You can easily use remote templates directly, or share other user's templates by passing Turple a remote source in addition to a template name. Simply separate the source name from the template name with 2 hashes (`##`).

Turple uses the [Sourcerer](https://github.com/brewster1134/sourcerer) gem to download remote sources to a tmp directory, so you can use any supported Sourcerer format *(including github shorthand!)*

```sh
# local template
Turple --template /path/to/template --destination new_project_name

# local template with shorter aliases
Turple -t /path/to/template -d new_project_name

# remote template (with source and template)
Turple -t brewster1134/Turple_templates##javascript

# remote template (with just template)
# this requires the source be loaded in your home Turplefile
Turple -t javascript

# already Turple'd project
Turple -t my_old_project_name -d new_project_name
```

### Configuration

A Turple template requires a Turplefile the defines the template's configuration. It can also include a data map that describes all the data a template requires.

```yaml
configuration:
  file_ext: Turple
  path_regex: '\[([A-Z_\.]+)\]'
  path_separator: .
  content_regex: '<>([a-z_\.]+)<>'
  content_separator: .
data_map:
  foo: What is the foo called?
  bar: The name of the bar.
```

* `configuration` has some very important details. (again, these are the defaults, so if your template does not have a custom configuration, it uses these values)
  * `file_ext` is the file extension Turple looks for to tell it there is content inside the file that needs processed
  * `path_regex` this is a string representing a regex match to variable names
  * `path_separator` this is a string representing a character(s) to seperate variables strung togehter
  * `content_regex` & `content_separator` are the same as with a path, but to match file contents rather than a path.
* `data_map` is a hash that matches the same structure as the data required for a template, but instead provides the details to prompt a user in case a peice of required data is missing.
  * data_map entries will be displayed with a prompt to enter missing data. you can pose a data map entry in the form of a question, or just a description of the data.

## Example Template

Say you design a template using the Turple default configuration, and you create a file structure like so...

```
foo_template
  |__ my_[FOO.BAR]_dir
  |   |
  |   |__ my_[FOO.BAZ]_file.txt.Turple
  |
  |__ Turplefile
```

and say your `my_[FOO.BAZ]_file.txt.Turple` file contains the following

```
This <>foo.baz<> file is in the <>foo.bar<> folder.
```

With a simple Turplefile containing...

```
data_map:
  foo:
    bar: What is the foo bar?
    baz: What is the foo baz?
```

* Notice how the path variables match the `path_regex`
* Notice how the separator of the path variables match the `path_separator`
* Notice how the content variables match the `content_regex`
* Notice how the separator of the content variables match the `content_separator`

**Now let's run Turple!**

```sh
Saving to: /your/current/directory/Turple
There is some missing data. You will be prompted to enter each value.
What is the foo bar?
>>> # enter your value here
What is the foo baz?
>>> # enter your value here
================================================================================
                              !Turple SUCCESS!
================================================================================
Turpleated `Foo Template` to a new project `Turple`
Paths Turpleated: 2
   Turpleated in: 1.1ms
================================================================================
```

### Ruby

You can run Turple directly in ruby if needed as well. _This example matches the template from the above example._

```ruby
require 'Turple'

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
yuyi -m https://raw.githubusercontent.com/brewster1134/Turple/master/Yuyifile
bundle install
bundle exec guard
```
