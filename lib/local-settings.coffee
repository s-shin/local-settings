_ = require "lodash"
fs = require "fs"
path = require "path"
temp = require("temp").track()
CSON = require "season"
{CompositeDisposable} = require "event-kit"

module.exports =
  config:
    autoEnable:
      title: "Auto-Enable"
      description: """
      Whether to automatically load the local settings file
      when the project is opened.
      """
      type: "boolean"
      default: true
    configFilePath:
      title: "Local Configuration File Name"
      description: """
      This is the name of the file containing the local settings.\n
      **Note that the *.cson* is appended automatically.**
      """
      type: "string"
      default: ".atomrc"

  activate: (state) ->
    @isEnabled = false

    @configFileName = atom.config.get("local-settings.configFilePath")

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add "atom-workspace",
      "local-settings:enable": => @enable()
      "local-settings:disable": => @disable()
      "local-settings:reload": => @disable => @enable()

    @subscriptions.add \
      atom.config.onDidChange "local-settings.configFilePath", ({newValue}) =>
        @configFileName = newValue || @config.configFilePath.default
        @disable => @enable() if @isEnabled

    # wait a few milliseconds so that enable correctly.
    setTimeout =>
      @enable() if atom.config.get("local-settings.autoEnable")
    , 100

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
    # Fix for issue #6 - when path is undefinied Atom throws error
    return if projectPath == undefined
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
