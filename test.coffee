
callbax = require './callbax'
fs      = require 'fs'

test1 = (cb) ->
  fn1 = (a, b, cb) ->
    cb.cleanup (err, next) ->
      console.log 'this should not happen #1'
      next()

    fn2 a, b, cb

  fn2 = (a, b, cb) ->
    cb.cleanup (err, next) ->
      next 1
      fn3 a, b, cb

    fs.writeFile 'test.tmp', '1', (err) ->
      if err
        console.log 'this should not happen #1'
        process.exit 1

      fs.readFile 'notavail.tmp', cb.pass (data) ->
        console.log 'this should not happen #2'
        process.exit 1

  fn3 = (a, b, cb) ->
    fs.readFile 'test.tmp', cb.pass ->
      cb null, 'done', b

  fn1 1, 2, cb.next (err, a, b) ->
    if err
      console.error 'this should not happen #3', err
      process.exit 1
    else unless a is 'done' and b is 2
      console.error 'this should not happen #4', a, b
      process.exit 1
    else
      console.log 'test1: success'
      cb()


test2 = (cb) ->
  cleanups = []

  fn1 = (a, b, cb) ->
    cb.cleanup (err, next) ->
      cleanups.push 'a'
      next()

    fn2 a, b, cb

  fn2 = (a, b, cb) ->
    cb.cleanup (err, next) ->
      cleanups.push 'b'
      next()

    cb.whatevz = x: 1

    fs.unlink 'test.tmp', xcb = cb.pass ->
      unless xcb.whatevz.x is 1
        cb.error new Error 'callback property carry-over failed'

      cb.cleanup (err, next) ->
        cleanups.push 'c'
        next 1
        fn3 a, b, cb

      fs.readFile 'test.tmp', cb.pass (data) ->
        console.log 'this should not happen #2-1'
        process.exit 1

  fn3 = (a, b, cb) ->
    cb.cleanup (err, next) ->
      cleanups.push 'd'
      next()

    fs.readFile 'test.tmp', cb.pass (data) ->
      console.log 'this should not happen #2-2'
      process.exit 1

  fn1 1, 2, cb.next (err, a, b) ->
    if not err or a? or b? or cleanups.join('') isnt 'cdba'
      console.error 'this should not happen #2-3', err, a, b, cleanups
      process.exit 1
    else
      console.log 'test2: success'
      cb null, cleanups


test1 callbax ->
  test2 callbax ->
    process.exit 0
