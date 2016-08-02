


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'NCR-UNICODE-CACHE-WRITER/tests'
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
suspend                   = require 'coffeenode-suspend'
step                      = suspend.step
#...........................................................................................................
test                      = require 'guy-test'
### short for 'cache writer': ###
CW                        = require './main'


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
@_prune = ->
  for name, value of @
    continue if name.startsWith '_'
    delete @[ name ] unless name in include
  return null

#-----------------------------------------------------------------------------------------------------------
@_main = ( handler = null ) ->
  test @, 'timeout': 3000

#-----------------------------------------------------------------------------------------------------------
hex = ( n ) -> '0x' + n.toString 16
s   = ( x ) -> JSON.stringify x


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@[ "demo" ] = ( T, done ) ->
  step ( resume ) =>
    yield CW.main resume
    done()
  #.........................................................................................................
  return null


############################################################################################################
unless module.parent?
  include = []
  # @_prune()
  @_main()

  # @[ "(v3) match, intersect" ]()


