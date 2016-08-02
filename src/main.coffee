

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
{ step }                  = require 'coffeenode-suspend'


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
resolve         = ( path ) -> PATH.resolve __dirname,                 '..', path
resolve_ucd     = ( path ) -> resolve PATH.join 'Unicode-UCD-9.0.0',        path
resolve_extras  = ( path ) -> resolve PATH.join 'extras',                   path

#-----------------------------------------------------------------------------------------------------------
@$show = ( S ) => $ ( x ) => urge JSON.stringify x

#-----------------------------------------------------------------------------------------------------------
interval_from_block_name = ( S, rsg, block_name ) ->
  unless ( R = S.interval_by_names[ block_name ] )?
    throw new Error "RSG #{rsg}: unknown Unicode block #{rpr block_name}"
  return R

#-----------------------------------------------------------------------------------------------------------
interval_from_rsg = ( S, rsg ) ->
  unless ( R = S.interval_by_rsgs[ rsg ] )?
    debug '4020', S.interval_by_rsgs
    throw new Error "unknown RSG #{rpr rsg}"
  return R

#-----------------------------------------------------------------------------------------------------------
append_tag = ( S, interval, tag ) ->
  if ( target = interval[ 'tag' ] )?
    if CND.isa_list target
      target.push tag
    else
      interval[ 'tag' ] = [ target, tag, ]
  else
    interval[ 'tag' ] = [ tag, ]
  return null


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

#-----------------------------------------------------------------------------------------------------------
@$read_target_and_tag = ( S ) =>
  range_pattern = /^\^([0-9a-f]{1,6})(?:\.\.([0-9a-f]{4,6}))?$/i
  return $ ( [ rsg_or_range, tag, ], send ) =>
    if ( match = rsg_or_range.match range_pattern )?
      [ _, lo_hex, hi_hex, ]  = match
      lo                      = parseInt lo_hex, 16
      hi                      = if ( hi_hex? and hi_hex.length > 0 ) then ( parseInt hi_hex, 16 ) else lo
      S.intervals.push { lo, hi, tag, }
    else
      interval = interval_from_rsg S, rsg_or_range
      append_tag S, interval, tag
  #.........................................................................................................
  return null


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@read_block_names = ( S, handler ) ->
  path                = resolve_ucd 'Blocks.txt'
  input               = D.new_stream { path, }
  type                = 'block'
  S.interval_by_names = {}
  #.........................................................................................................
  input
    .pipe D.$split_tsv()
    # .pipe D.$sample 1 / 10, seed: 872
    .pipe @$block_interval_from_line  S
    .pipe $ ( interval ) =>
      { "#{type}": name, }      = interval
      S.interval_by_names[ name ]  = interval
      S.intervals.push interval
    # .pipe @$show                      S
    .pipe $ 'finish', handler
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@read_rsgs_and_block_names = ( S, handler ) ->
  path                = resolve_extras 'rsgs.txt'
  input               = D.new_stream { path, }
  S.interval_by_rsgs  = {}
  #.........................................................................................................
  input
    .pipe D.$split_tsv splitter: /[\x20\t]{2,}/g
    # .pipe D.$sample 1 / 40, seed: 872
    .pipe $ ( [ rsg, block_name, ] ) =>
      interval                  = interval_from_block_name S, rsg, block_name
      interval[ 'rsg' ]         = rsg
      S.interval_by_rsgs[ rsg ] = interval
    .pipe $ 'finish', handler
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@read_tags = ( S, handler ) ->
  path                = resolve_extras 'tags.txt'
  input               = D.new_stream { path, }
  #.........................................................................................................
  input
    .pipe D.$split_tsv splitter: /[\x20\t]{2,}/g
    # .pipe D.$show()
    .pipe @$read_target_and_tag S
    .pipe $ 'finish', handler
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@write = ( S, handler ) ->
  # path                = resolve_extras 'tags.txt'
  path  = '/tmp/u-intervals.json'
  json  = JSON.stringify S.intervals, null, '  '
  #.........................................................................................................
  FS.writeFile path, json, =>
    help "output written to #{path}"
    handler()
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@main = ( handler = null ) ->
  #.........................................................................................................
  S =
    intervals:        []
  #.........................................................................................................
  step ( resume ) =>
    yield @read_block_names           S, resume
    yield @read_rsgs_and_block_names  S, resume
    yield @read_tags                  S, resume
    yield @write                      S, resume
    # debug '6592', S.interval_by_rsgs
    # debug '6592', S.intervals
    setImmediate ( => handler null ) if handler?
  #.........................................................................................................
  return null


############################################################################################################
unless module.parent?
  @main()




