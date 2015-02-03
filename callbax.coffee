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
    fn.split   = @split
    fn

  next: (handler) =>
    new Callbax @functionize @fn, handler

  pass: (handler) =>
    unless typeof handler is 'function'
      throw new Error 'handler function required'
 
    @functionize @fn, (err, args...) =>
      unless @error err
        handler args...

  split: (split_fns..., handler) =>
    unless split_fns.length
      throw new Error 'split functions required'
    unless typeof handler is 'function'
      throw new Error 'split handler function required'

    check_done = ->
      done = 0
      for k, v of path_done when v
        done += 1
      if done is path_count
        handler()

    path_count = split_fns.length
    path_done  = {}
    errored    = false

    for split_fn, split_id in split_fns
      if Array.isArray split_fn
        args = split_fn[1 ..]
        split_fn = split_fn[0]
      else
        args = []
      unless typeof split_fn is 'function'
        throw new Error 'split_fn must be a function'

      path_done[split_id] = 0
      do (split_id) =>
        split_fn args..., new Callbax @functionize @fn, (err) ->
          unless errored
            if err
              errored = true
              handler err

            path_done[split_id] = 1
            check_done()


module.exports = (callback) ->
  new Callbax callback
