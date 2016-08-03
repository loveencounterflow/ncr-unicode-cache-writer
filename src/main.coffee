

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
@read_intervals = ( handler ) ->
  @READER.read ( error, S ) =>
    return handler error if error?
    handler null, S.intervals

#-----------------------------------------------------------------------------------------------------------
@read_isl = ( handler ) ->
  @read_intervals ( error, intervals ) =>
    return handler error if error?
    isl = ISL.new()
    ISL.add isl, interval for interval in intervals
    handler null, isl

# #===========================================================================================================
# # MAIN
# #-----------------------------------------------------------------------------------------------------------
# @main = ( handler = null ) ->
#   #.........................................................................................................
#   S =
#     intervals:        []
#   #.........................................................................................................
#   step ( resume ) =>
#     yield @read_planes_and_areas      S, resume
#     yield @read_block_names           S, resume
#     yield @read_rsgs_and_block_names  S, resume
#     yield @read_tags                  S, resume
#     yield @write                      S, resume
#     # debug '6592', S.interval_by_rsgs
#     # debug '6592', S.intervals
#     setImmediate ( => handler null ) if handler?
#   #.........................................................................................................
#   return null


############################################################################################################
unless module.parent?
  @main()




