_ = require "lodash"
fs = require "fs"
path = require "path"
temp = require("temp").track()
CSON = require "season"
{CompositeDisposable} = require "event-kit"

DEFAULT_CONFIG_FILE_PATH = '.atomrc'

module.exports =
  config:
    'autoEnable':
      'default': true
      'description': 'Whether to automatically load the local settings file when the project is opened.'
      'title': 'Auto-Enable'
      'type': 'boolean'
    'configFilePath':
      'default': DEFAULT_CONFIG_FILE_PATH
      'description':
        'This is the name of the file containing the local settings. **Note that the *.cson* is appended automatically.**'
      'title': 'Local Configuration File Name'
      'type': 'string'

  activate: (state) ->
    @isEnabled = false

    @configFileName = atom.config.get("local-settings.configFilePath")

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add "atom-workspace",
      "local-settings:enable": => @enable()
      "local-settings:disable": => @disable()
      "local-settings:reload": => @disable => @enable()

    self = this

    @subscriptions.add atom.config.onDidChange 'local-settings.configFilePath', (event) ->
        self.configFileName = event.newValue || DEFAULT_CONFIG_FILE_PATH
        self.disable => self.enable() if self.isEnabled

    @subscriptions.add atom.config.onDidChange 'local-settings.autoEnable', (event) ->
        self.enable() if event.newValue

    @enable() if atom.config.get("local-settings.autoEnable")

  deactivate: ->
    temp.cleanupSync()
    @subscriptions.dispose()

  enable: ->
    return if @isEnabled
    @isEnabled = true
    # save current config file path
    @defaultConfigPath = atom.config.configFilePath
    # load local config file in the current workspace
    projectPath = atom.project.getPaths()[0]
    localConfigPath = CSON.resolve path.join(projectPath, @configFileName)
    return unless localConfigPath
    CSON.readFile localConfigPath, (err, localConfigData) =>
      return console.error err if err
      # create temporary config and load it
      tmpConfigData = {}
      CSON.readFile @defaultConfigPath, (err, defaultConfigData) ->
        defaultConfigData = {} if err
        _.merge tmpConfigData, defaultConfigData, localConfigData
        temp.open {prefix: "local-settings", suffix: ".cson"}, (err, info) ->
          return console.error err if err
          fs.write info.fd, CSON.stringify(tmpConfigData)
          atom.config.configFilePath = info.path
          atom.config.load()

  disable: (callback) ->
    return unless @isEnabled
    @isEnabled = false
    temp.cleanup (err, stats) =>
      # restore and reload
      atom.config.configFilePath = @defaultConfigPath
      atom.config.load()
      callback?()
