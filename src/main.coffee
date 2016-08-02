

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
#...........................................................................................................
suspend                   = require 'coffeenode-suspend'
step                      = suspend.step


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
resolve     = ( path ) -> PATH.resolve __dirname, '..', path
resolve_ucd = ( path ) -> resolve PATH.join 'Unicode-UCD-9.0.0', path

#-----------------------------------------------------------------------------------------------------------
@$show = ( S ) => $ ( x ) => urge JSON.stringify x


#===========================================================================================================
# TRANSFORMS
#-----------------------------------------------------------------------------------------------------------
@$block_interval_from_line = ( S ) =>
  type    = 'block'
  pattern = /^([0-9a-f]{4,6})\.\.([0-9a-f]{4,6});\s+(.+)$/i
  return $ ( [ line, ], send ) =>
    match = line.match pattern
    return send.error new Error "not a valid line: #{rpr line}" unless match?
    [ _, lo_hex, hi_hex, short_name, ] = match
    lo    = parseInt lo_hex, 16
    hi    = parseInt hi_hex, 16
    name  = "#{type}:#{short_name}"
    send { lo, hi, name, type: type, "#{type}": short_name, }
  #.........................................................................................................
  return null


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@read_block_names = ( S, handler ) ->
  path    = resolve_ucd 'Blocks.txt'
  input   = D.new_stream { path, }
  #.........................................................................................................
  input
    .pipe D.$split_tsv()
    .pipe @$block_interval_from_line  S
    .pipe @$show                      S
    .pipe $ 'finish', handler
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@main = ( handler = null ) ->
  S = {}
  step ( resume ) =>
    yield @read_block_names S, resume
    handler null if handler?
  #.........................................................................................................
  return null


############################################################################################################
unless module.parent?
  @main()




