Local Settings
==============

This package allows you to extend the current config with project-local settings.

![demo](https://raw.githubusercontent.com/s-shin/local-settings/master/demo.gif)

Installation
------------

```
apm install local-settings
```

Usage
-----

* Make `.atomrc.cson` file in the root of the current workspace.
  `.atomrc.cson` can include any settings which are available in `config.cson`.
* Execute `Local Settings: Enable` from the command palette (`cmd+shift+p`).
* If you edit `.atomrc.cson` after enabled, execute `Local Settings: Reload`.
* If you want to restore settings, execute `Local Settings: Disable`.

Configuration
-------------

You can change the project-local config file name.

```
'local-settings':
  'configFileName': '.atomrc' # '.cson' is automatically appended
```
