meshblu = require 'meshblu'
async = require 'async'
debug = require('debug')('socker')
MeshbluConfig = require 'meshblu-config'
moment = require 'moment'


class Command
  constructor: ->
    @meshbluConfig = new MeshbluConfig()

  run: =>
    @startTime = moment()
    @conn = meshblu.createConnection @meshbluConfig.toJSON()
    @conn.on 'ready', @onReady
    @conn.on 'notReady', @onNotReady
    @conn.on 'error', @onError
    @conn.on 'connect_error', @onConnectError

  onReady: ({@uuid,@token}) =>
    console.log 'ready', JSON.stringify uuid: @uuid, token: @token

    async.series [
      @data
      @device
      @devices
      @generateAndStoreToken
      @message
      @register
      @subscribe
      @whoami
    ], @finishUp

  finishUp: =>
    console.log 'all done'
    process.exit 0

  data: (callback) =>
    console.log 'data'
    @conn.data {uuid: @uuid, infected: 'papercut'}, =>
      console.log 'dataed'
      @conn.getdata {uuid: @uuid, token: @token, start: @startTime.format()}, (data) =>
        console.log 'getdataed'
        debug 'getdataed', data
        callback()

  device: (callback) =>
    console.log 'device'
    @conn.device {uuid: @uuid}, (device) =>
      console.log 'deviced'
      debug 'device', device
      callback()

  devices: (callback) =>
    console.log 'devices'
    @conn.devices {uuid: @uuid}, (devices) =>
      console.log 'devicesed'
      debug 'devicesed', devices
      callback()

  generateAndStoreToken: (callback) =>
    console.log 'generateAndStoreToken'
    @conn.generateAndStoreToken {uuid: @uuid}, (response) =>
      console.log 'generateAndStoreTokened'
      debug 'generateAndStoreTokened', response
      @conn.revokeToken response, =>
        console.log 'revokeTokened'
        callback()

  message: (callback) =>
    console.log 'message'
    @conn.message {devices: [@uuid], topic: 'head explodes'},
      console.log 'messaged'
      callback()

  register: (callback) =>
    console.log 'register'
    @conn.register {math: 'read the warning signs'}, (device) =>
      console.log 'registered'
      debug 'registered', device
      @conn.update {uuid: device.uuid, meat: 'grinder'}, =>
        console.log 'updated'
        @conn.unregister {uuid: device.uuid}, =>
          console.log 'unregistered'
          callback()

  subscribe: (callback) =>
    console.log 'subscribe'
    @conn.subscribe {uuid: @uuid}, =>
      console.log 'subscribed'
      @conn.unsubscribe {uuid: @uuid}, =>
        console.log 'unsubscribed'
        callback()

  whoami: (callback) =>
    console.log 'whoami'
    @conn.whoami {}, (iam) =>
      console.log 'whoamied'
      debug 'whoamied', iam
      callback()

  onNotReady: (params) =>
    console.log 'notReady', params

  onError: (error) =>
    console.log 'error', error

  onConnectError: (error) =>
    console.log 'connect_error', error

command = new Command()
command.run()
