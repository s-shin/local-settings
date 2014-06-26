_ = require "lodash"
fs = require "fs"
path = require "path"
temp = require("temp").track()
CSON = require "season"

CFG =
  configFileName:
    key: "local-settings.configFileName"
    default: ".atomrc"

module.exports =

  configFileName: CFG.configFileName.default

  activate: (state) ->
    @isEnabled = false

    atom.config.observe CFG.configFileName.key, =>
      @configFileName = atom.config.get(CFG.configFileName.key) \
        or CFG.configFileName.default

    atom.workspaceView.command "local-settings:enable", => @enable()
    atom.workspaceView.command "local-settings:disable", => @disable()
    atom.workspaceView.command "local-settings:reload", => @disable => @enable()

  destroy: ->
    atom.config.unobserve CFG.configFileName.key
    temp.cleanupSync()

  enable: ->
    return if @isEnabled
    @isEnabled = true
    # save current config file path
    @defaultConfigPath = atom.config.configFilePath
    # load local config file in the current workspace
    localConfigPath = CSON.resolve path.join(atom.project.path, @configFileName)
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
