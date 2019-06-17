
require "config"
require "nbinit"
require("core.init")

print("appentry========")
nb.exports.appconfig = require("appconfig")
require("app.App").new():run()