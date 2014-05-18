module.exports = (env) ->
  convict = env.require "convict"
  Q = env.require 'q'
  assert = env.require 'cassert'
  _ = env.require 'lodash'

  exec = Q.denodeify(require("child_process").exec)
 
  class MaxThermostat extends env.plugins.Plugin
 
    init: (app, @framework, config) =>
      conf = convict require("./maxthermostat-config-schema")
      conf.load config
      conf.validate()
      @config = conf.get ""
      @checkBinary()

      # wait till all plugins are loaded
      @framework.on "after init", =>
        # Check if the mobile-frontent was loaded and get a instance
        mobileFrontend = @framework.getPlugin 'mobile-frontend'
        if mobileFrontend?
          mobileFrontend.registerAssetFile 'js', "pimatic-max-thermostat/app/js.coffee"
          # mobileFrontend.registerAssetFile 'css', "pimatic-max-thermostat/app/css/css.css"
<<<<<<< HEAD
          mobileFrontend.registerAssetFile 'html', "pimatic-max-thermostat/app/template.html"
        else
=======
          mobileFrontend.registerAssetFile 'html', "pimatic-max-thermostat/app/html.jade"
      else
>>>>>>> a145baa3dbcf8dc6d62d4916d1e4fb0f89b1f264
          env.logger.warn "MaxThermostat could not find the mobile-frontend. No gui will be available"



    checkBinary: ->
      command = "php #{plugin.config.binary}" # define the binary
      command += "#{plugin.config.host} #{plugin.config.port}" # select the host and port of the cube
      command += "#{@config.RoomID} #{@config.deviceNo}" # select the RoomID and deviceNo
      command += "check" # see if max.php is there
      exec(command).catch( (error) ->
        if error.message.match "not found"
          env.logger.error "max.php binary not found. Check your config!"
        else
          env.logger.info "Found max.php"
      ).done()
 
    createDevice: (deviceConfig) =>
      switch deviceConfig.class
        when "MaxThermostatDevice"
          @framework.registerDevice(new MaxThermostatDevice deviceConfig)
          return true
        else
          return false

  plugin = new MaxThermostat
 
  class MaxThermostatDevice extends env.devices.Device
 
    constructor: (config) ->
      conf = convict _.cloneDeep(require("./device-config-schema"))
      conf.load config
      conf.validate()
      @config = conf.get ""

      @name = config.name
      @id = config.id
      super()


      getState: () ->
        if @_state? then return Q @_state
        # Built the command to get the thermostat status
        command = "php #{plugin.config.binary}" # define the binary
        command += "#{plugin.config.host} #{plugin.config.port}" # select the host and port of the cube
        command += "#{@config.RoomID} #{@config.deviceNo}" # select the RoomID and deviceNo
        command += "status" # get status of the thermostat
        # and execue it.
        return exec(command).then( (streams) ->
          stdout = streams[0]
          stderr = streams[1]
          stdout = stdout.trim()
          data = JSON.parse stdout
          config.actTemp = data.actTemp
          config.mode = data.mode
          config.comfyTemp = data.comfyTemp
          config.ecoTemp = data.ecoTemp
        )


      changeModeTo: (mode) ->
        if @mode is mode then return
        # Built the command
        command = "php #{plugin.config.binary}" # define the binary
        command += "#{plugin.config.host} #{plugin.config.port}" # select the host and port of the cube
        command += "#{@config.RoomID} #{@config.deviceNo}" # select the RoomID and deviceNo
        command += "mode #{@mode}" # set mode of the thermostat
        # and execue it.
        return exec(command).then( (streams) =>
          stdout = streams[0]
          stderr = streams[1]
          env.logger.debug stderr if stderr.length isnt 0
          @_setMode(mode)
         )

<<<<<<< HEAD
      changeTermperatureTo: (temperature) ->
        if @temperature is temperature then return
        # Built the command
        command = "php #{plugin.config.binary}" # define the binary
        command += "#{plugin.config.host} #{plugin.config.port}" # select the host and port of the cube
        command += "#{@config.RoomID} #{@config.deviceNo}" # select the RoomID and deviceNo
        command += "temp #{@temperature}" # set temperature of the thermostat
        # and execue it.
        return exec(command).then( (streams) =>
          stdout = streams[0]
          stderr = streams[1]
          env.logger.debug stderr if stderr.length isnt 0
          @_setMode(mode)
        )
      getTemplateName: -> "MaxThermostatDevice"
=======
    changeTermperatureTo: (temperature) ->
      if @temperature is temperature then return
      # Built the command
      command = "php #{plugin.config.binary}" # define the binary
      command += "#{plugin.config.host} #{plugin.config.port}" # select the host and port of the cube
      command += "#{@config.RoomID} #{@config.deviceNo}" # select the RoomID and deviceNo
      command += "temp #{@temperature}" # set temperature of the thermostat
      # and execue it.
      return exec(command).then( (streams) =>
        stdout = streams[0]
        stderr = streams[1]
        env.logger.debug stderr if stderr.length isnt 0
        @_setMode(mode)
      )
    getTemplateName: -> "MaxThermostatDevice"
>>>>>>> a145baa3dbcf8dc6d62d4916d1e4fb0f89b1f264

  return plugin
