#!/usr/bin/env coffee


class Callbax
  callback: null
  cleaners: null
  fn:       null

  constructor: (@callback) ->
    unless typeof callback is 'function'
      throw new Error 'callback function required'
 
    @cleaners = []

    return @fn = @functionize callback, (args...) =>
      @done args...

  cleanup: (fn) =>
    unless typeof fn is 'function'
      throw new Error 'handler function required'
 
    (@cleaners ?= []).push fn

  done: (args...) =>
    if args[0]?
      @error args...
    else
      @callback args...

  error: (args...) =>
    unless args[0]?
      return false

    if cleaner = @cleaners?.pop()
      cleaner args[0], (stop_propagation) =>
        unless stop_propagation
          @error args...
    else
      @callback args...
    true

  functionize: (source_fn, fn) =>
    for key, value of source_fn
      fn[key] = value

    fn.cleanup = @cleanup
    fn.error   = @error
    fn.pass    = @pass
    fn.next    = @next
    fn

  next: (handler) =>
    new Callbax handler

  pass: (handler) =>
    unless typeof handler is 'function'
      throw new Error 'handler function required'
 
    @functionize @fn, (err, args...) =>
      unless @error err
        handler args...


module.exports = (callback) ->
  new Callbax callback
