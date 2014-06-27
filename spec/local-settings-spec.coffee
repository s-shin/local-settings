LocalSettings = require "../lib/local-settings"
{Config, WorkspaceView} = require "atom"
path = require "path"

# describe "LocalSettings", ->
#   [activationPromise] = []
#
#   beforeEach ->
#     atom.workspaceView = new WorkspaceView
#     waitsForPromise -> atom.packages.activatePackage "local-settings"
#
#   it "should change and restore settings by `local-settings:enable` and `local-settings:disable`", ->
#     cfg =
#       fontSize: atom.config.get "editor.fontSize"
#       fontFamily: atom.config.get "editor.fontFamily"
#
#     atom.workspaceView.trigger "local-settings:enable"
#     expect(atom.config.get("editor.fontSize")).toBe 20
#     expect(atom.config.get("editor.fontFamily")).toBe "Helvetica"
#     atom.workspaceView.trigger "local-settings:disable"
#     expect(atom.config.get("editor.fontSize")).toBe cfg.fontSize
#     expect(atom.config.get("editor.fontFamily")).toBe cfg.fontFamily
