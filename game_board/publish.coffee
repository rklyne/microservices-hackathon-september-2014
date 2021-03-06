#!/usr/bin/env coffee
# ^runs with CoffeeScript
# 
# Publishes a single message to a given topic
#
context = require('rabbit.js').createContext('amqp://54.76.117.95:5672')
argv = require('optimist').argv
topic_exchange = 'combo'

unless (argv.t? || argv.topic?)
  throw new Error "No topic supplied, use -t or --topic"
unless (argv.m? || argv.message?)
  throw new Error "No message supplied, use -m or --message"

if argv.h || argv.help
  console.log "Usage: ./publish.coffee --topic topic_name --message 'JSON message to send'"
  process.exit()

context.on 'ready', ->
  publisher = context.socket 'PUB', { routing: 'topic' }
  publisher.on 'error', (err) -> 
    console.log "Crashed: #{err}"
  publisher.connect topic_exchange, ->
    console.log 'publisher connected'
    topic = argv.t ? argv.topic 
    message = argv.m ? argv.message 
    console.log "publishing to topic #{topic} message #{message}"
    publisher.publish topic, message, 'utf8'
    exit = -> process.exit()
    setTimeout(exit, 1000)
 