###*
# Buffer manipulation
###



Buffer = (index, client) ->
  @index = index
  @client = client
  return


###*
# Get lines on the buffer
# @param {int} from - The first line index
# @param {int} [to=from] - The Last line index
# @return Promise object
###
Buffer::get_line = ->
  from = arguments[0]
  to = from
  if (typeof arguments[1] == 'number') && (parseInt(arguments[1]) == arguments[1])
    to = arguments[1]
  @client.send_method('buffer_get_slice', @index, from, to, true, true)


###*
# Replace lines on the buffer
# @param {int} from - The first line index
# @param {int} [to=from] - The Last line index
# @param {string[]} content - An array of strings to use as replacement
# @return
###
Buffer::set_line = ->
  from = arguments[0]
  to = from
  if (typeof arguments[1] == 'number') && (parseInt(arguments[1]) == arguments[1])
    to = arguments[1]
  content = arguments[arguments.length - 1]
  self = @
  @get_length()
    .then((buffer_length) ->
      if from >= buffer_length
        gap = from - buffer_length
        keep = buffer_length-1
        self.get_line(keep)
        .then((keep_content) ->
          content.unshift('') for num in [1..gap] if gap != 0
          content.unshift(keep_content[0])
          self.client.send_method('buffer_set_slice', self.index, keep, to, true, true, content)
        )
      else
        self.client.send_method('buffer_set_slice', self.index, from, to, true, true, content)
    )


###*
# Delete a line on the buffer
# @param {int} index - The line index
# @return
###
Buffer::delete_line = (index) ->
  @client.send_method('buffer_del_line', @index, index)


###*
# Get the buffer line count
# @return
###
Buffer::get_length = ->
  @client.send_method('buffer_get_length', @index)


exports.create_buffer = (index, client) ->
  buffer = new Buffer(index, client)
  return buffer
