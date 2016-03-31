'use strict'
util           = require 'util'
{EventEmitter} = require 'events'
debug          = require('debug')('meshblu-google-vision')
{Client, Feature, Request, Image} = require('vision-cloud-api')

FACE_DETECTION = new (Feature)('FACE_DETECTION')
LOGO_DETECTION = new (Feature)('LOGO_DETECTION')
LABEL_DETECTION = new (Feature)('LABEL_DETECTION')
TEXT_DETECTION = new (Feature)('TEXT_DETECTION')
SAFE_SEARCH_DETECTION = new (Feature)('SAFE_SEARCH_DETECTION')
IMAGE_PROPERTIES = new (Feature)('IMAGE_PROPERTIES')
TYPE_UNSPECIFIED = new (Feature)('TYPE_UNSPECIFIED')
LANDMARK_DETECTION = new (Feature)('LANDMARK_DETECTION')

MESSAGE_SCHEMA =
  type: 'object'
  properties:
    image:
      type: 'string'
      required: true
    base64:
      type: 'boolean'
      default: false
    url:
      type: 'boolean'
      default: false
    FACE_DETECTION:
      type: 'boolean'
      default: false
    LOGO_DETECTION:
      type: 'boolean'
      default: false
    LABEL_DETECTION:
      type: 'boolean'
      default: false
    TEXT_DETECTION:
      type: 'boolean'
      default: false
    SAFE_SEARCH_DETECTION:
      type: 'boolean'
      default: false
    IMAGE_PROPERTIES:
      type: 'boolean'
      default: false
    TYPE_UNSPECIFIED:
      type: 'boolean'
      default: false
    LANDMARK_DETECTION:
      type: 'boolean'
      default: false

OPTIONS_SCHEMA =
  type: 'object'
  properties:
    auth:
      type: 'string'
      required: true

class Plugin extends EventEmitter
  constructor: ->
    @options = {}
    @messageSchema = MESSAGE_SCHEMA
    @optionsSchema = OPTIONS_SCHEMA

  setFeatures: (payload) =>
    features = []

    features.push FACE_DETECTION if payload.FACE_DETECTION == true
    features.push LOGO_DETECTION if payload.LOGO_DETECTION == true
    features.push LABEL_DETECTION if payload.LABEL_DETECTION  == true
    features.push TEXT_DETECTION if payload.TEXT_DETECTION  == true
    features.push SAFE_SEARCH_DETECTION if payload.SAFE_SEARCH_DETECTION  == true
    features.push IMAGE_PROPERTIES if payload.IMAGE_PROPERTIES  == true
    features.push TYPE_UNSPECIFIED if payload.TYPE_UNSPECIFIED  == true
    features.push LANDMARK_DETECTION if payload.LANDMARK_DETECTION  == true

    features

  onMessage: (message) =>
    self = @

    payload = message.payload
    @features = @setFeatures payload

    image = new Image url: payload.image if payload.url
    image = new Image base64: payload.image if payload.base64
    image.build()

    request = new Request image: image, features: @features
    client = new Client auth: self.options.auth

    client.annotate([ request ]).then((response) =>
      response =
        devices: ['*']
        payload: response
      self.emit 'message', response
    ).catch (err) ->
      debug err

  onConfig: (device) =>
    @setOptions device.options

  setOptions: (options={}) =>
    @options = options
    @auth = @options.auth

module.exports =
  messageSchema: MESSAGE_SCHEMA
  optionsSchema: OPTIONS_SCHEMA
  Plugin: Plugin
