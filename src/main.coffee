

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
# #...........................................................................................................
# D                         = require 'pipedreams'
# { $, $async, }            = D
# require 'pipedreams/lib/plugin-tsv'
# # require 'pipedreams/lib/plugin-tabulate'
#...........................................................................................................
{ step }                  = require 'coffeenode-suspend'
#...........................................................................................................
ISL                       = require 'interskiplist'
@READER                   = require './reader'

#-----------------------------------------------------------------------------------------------------------
@read = ( handler ) ->
  @READER.read ( error, S ) =>
    return handler error if error?
    handler null, S

#-----------------------------------------------------------------------------------------------------------
@read_intervals = ( handler ) ->
  @read ( error, S ) =>
    return handler error if error?
    handler null, S.intervals

#-----------------------------------------------------------------------------------------------------------
@read_isl = ( handler ) ->
  @read_intervals ( error, intervals ) =>
    return handler error if error?
    isl = ISL.new()
    ISL.add isl, interval for interval in intervals
    handler null, isl

#===========================================================================================================
# WRITE CACHES
#-----------------------------------------------------------------------------------------------------------
@write = ( S, handler = null ) ->
  @read_intervals ( error, intervals ) =>
    return handler error if error?
    # json = JSON.stringify intervals, null, '  '
    # echo json
    echo '['
    for idx in [ 0 ... intervals.length - 2 ] by +1
      echo ( JSON.stringify intervals[ idx ] ) + ','
    echo ( JSON.stringify intervals[ intervals.length - 1 ] )
    echo ']'
    handler() if handler?
  #.........................................................................................................
  return null

  # write_to_file = no
  # help "#{S.intervals.length} intervals"
  # #.........................................................................................................
  # if write_to_file
  #   path = '/tmp/u-intervals.json'
  #   FS.writeFile path, json, =>
  #     help "written to #{path}"
  #     handler()
  # else


############################################################################################################
unless module.parent?
  @write()




