# DATA OBJECTS
* Source(location)
  * location: local or remote path to a source of templates directories
  * METHODS
    *

* Project(path)
  * path: local path to empty project dir
  * METHODS
    *

* Template(path)
  * path: local path of compiled project, or local tmp path of downloaded source & template
  * METHODS

* Data(object)
  * object: deep hash of key/values required for the desired template
  * METHODS

## Settings()
  * METHODS
    * load(type, path)
      * type: [:user, :template, :project]
      * path: local path to a Turplefile

# CONTROLLER OBJECTS
## Interpolate
* template
  * Template instance
* project
  * Project instance
* data
  * Data instance

# CLI FLOW
* load all available settings
  * defaults
  * :user (if available)
  * :template (if available)
  * :project (if available)
