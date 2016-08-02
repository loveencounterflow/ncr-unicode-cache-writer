

############################################################################################################
# njs_util                  = require 'util'
PATH                      = require 'path'
FS                        = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'NCR-UNICODE-CACHE-WRITER'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
D                         = require 'pipedreams'
{ $, $async, }            = D
require 'pipedreams/lib/plugin-tsv'
# require 'pipedreams/lib/plugin-tabulate'


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
resolve     = ( path ) -> PATH.resolve __dirname, path
resolve_ucd = ( path ) -> resolve PATH.join 'Unicode-UCD-9.0.0', path


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@read_block_names = ( S ) ->
  path    = resolve_ucd 'Blocks.txt'
  input   = D.new_stream { path, }
  # sink    = D.new_stream 'devnull'
  done    = -> urge 'ok'
  #.........................................................................................................
  $split_fields = =>
    pattern = /^([0-9a-f]{4,6})\.\.([0-9a-f]{4,6});\s+(.+)$/i
    return $ ( [ line, ], send ) =>
      match = line.match pattern
      return send.error new Error "not a valid line: #{rpr line}" unless match?
      [ _, lo_hex, hi_hex, name, ] = match
      lo = parseInt lo_hex, 16
      hi = parseInt hi_hex, 16
      send { lo, hi, name, }
  #.........................................................................................................
  input
    # .pipe D.$split()
    .pipe D.$split_tsv()
    .pipe $split_fields()
    .pipe $ ( interval ) => urge JSON.stringify interval
    .pipe $ 'finish', done
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@main = ->
  S = {}
  @read_block_names S


############################################################################################################
unless module.parent?
  @main()




