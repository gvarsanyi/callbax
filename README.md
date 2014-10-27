callbex
=======

asynchronous callback extras and shortcuts for coffeescript / javascript


# Callbacks:
## Concept
Call a function with signiture:
    my_fn(arguments..., callback_fn)
Function returns asynchronous response by calling `callback_fn` with signiture:
    callback_fn(err, response_arguments...)
in which err is null or undefined unless an error-response is returned.

## Example
    my_fn arg1, arg2, (err, response_arg1, response_arg2) ->
      if err
        # error path
      else
        next_async_fn arg_x, (err) ->
          # ...

# Callbax extras
Callbax generates a function that has extensions providing extra functionality

## Clean-up / fall-back error handling logic (with option to stop propagation)
(description and examples here)

## Simple error filter (short cut for error check code blocks)
(description and examples here)
