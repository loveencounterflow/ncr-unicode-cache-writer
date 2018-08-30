


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
{ step }                  = require 'coffeenode-suspend'
#...........................................................................................................
test                      = require 'guy-test'
### short for 'cache writer': ###
CW                        = require './main'
ISL                       = require 'interskiplist'


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
  test @, 'timeout': 30000

#-----------------------------------------------------------------------------------------------------------
hex = ( n ) -> '0x' + n.toString 16
s   = ( x ) -> JSON.stringify x


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@[ "demo" ] = ( T, done ) ->
  self = @
  step ( resume ) ->
    yield CW.main resume
    help 'ok'
    done()
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "superficial API test" ] = ( T, done ) ->
  self = @
  step ( resume ) ->
    S         = yield CW.read           resume
    intervals = yield CW.read_intervals resume
    #.......................................................................................................
    # debug '3984', Object.keys S
    T.eq ( Object.keys S ), [ 'intervals', 'interval_by_names', 'interval_by_rsgs', ]
    T.eq S.intervals, intervals
    T.ok S.intervals isnt intervals
    #.......................................................................................................
    isl_1     = yield CW.read_isl       resume
    isl_2     = ISL.new()
    ISL.add isl_2, interval for interval in intervals
    delete isl_1[ '%self' ]
    delete isl_2[ '%self' ]
    T.eq isl_1, isl_2
    help 'ok'
    #.......................................................................................................
    done()

#-----------------------------------------------------------------------------------------------------------
@[ "test Unicode ISL against select codepoints" ] = ( T, done ) ->
  probes_and_matchers = [
    ["a",{"tag":["assigned"],"plane":"Basic Multilingual Plane (BMP)","area":"ASCII & Latin-1 Compatibility Area","block":"Basic Latin","rsg":"u-latn"}]
    ["ä",{"tag":["assigned"],"plane":"Basic Multilingual Plane (BMP)","area":"ASCII & Latin-1 Compatibility Area","block":"Latin-1 Supplement","rsg":"u-latn-1"}]
    ["ɐ",{"tag":["assigned"],"plane":"Basic Multilingual Plane (BMP)","area":"General Scripts Area","block":"IPA Extensions","rsg":"u-ipa-x"}]
    ["ա",{"tag":["assigned"],"plane":"Basic Multilingual Plane (BMP)","area":"General Scripts Area","block":"Armenian"}]
    ["三",{"tag":["assigned","cjk","ideograph"],"plane":"Basic Multilingual Plane (BMP)","area":"CJKV Unified Ideographs Area","block":"CJK Unified Ideographs","rsg":"u-cjk"}]
    ["ゆ",{"tag":["assigned","cjk","japanese","kana","hiragana"],"plane":"Basic Multilingual Plane (BMP)","area":"CJK Miscellaneous Area","block":"Hiragana","rsg":"u-cjk-hira"}]
    ["㈪",{"tag":["assigned","cjk"],"plane":"Basic Multilingual Plane (BMP)","area":"CJK Miscellaneous Area","block":"Enclosed CJK Letters and Months","rsg":"u-cjk-enclett"}]
    ["《",{"tag":["assigned","cjk","punctuation"],"plane":"Basic Multilingual Plane (BMP)","area":"CJK Miscellaneous Area","block":"CJK Symbols and Punctuation","rsg":"u-cjk-sym"}]
    ["》",{"tag":["assigned","cjk","punctuation"],"plane":"Basic Multilingual Plane (BMP)","area":"CJK Miscellaneous Area","block":"CJK Symbols and Punctuation","rsg":"u-cjk-sym"}]
    ["𫠠",{"tag":["assigned","cjk","ideograph"],"plane":"Supplementary Ideographic Plane (SIP)","block":"CJK Unified Ideographs Extension E","rsg":"u-cjk-xe"}]
    ["﹄",{"tag":["assigned","cjk","vertical"],"plane":"Basic Multilingual Plane (BMP)","area":"Compatibility and Specials Area","block":"CJK Compatibility Forms","rsg":"u-cjk-cmpf"}]
    ["﹅",{"tag":["assigned","cjk"],"plane":"Basic Multilingual Plane (BMP)","area":"Compatibility and Specials Area","block":"CJK Compatibility Forms","rsg":"u-cjk-cmpf"}]
    ["𝍖",{"tag":["assigned","cjk","yijing","taixuanjing","tetragram"],"plane":"Supplementary Multilingual Plane (SMP)","area":"Symbols Area","block":"Tai Xuan Jing Symbols","rsg":"u-txj-sym"}]
    ["𝍗",{"tag":["unassigned","cjk","yijing","taixuanjing","tetragram"],"plane":"Supplementary Multilingual Plane (SMP)","area":"Symbols Area","block":"Tai Xuan Jing Symbols","rsg":"u-txj-sym"}]
    ["𞹛",{"tag":["assigned"],"plane":"Supplementary Multilingual Plane (SMP)","area":"General Scripts Area (RTL)","block":"Arabic Mathematical Alphabetic Symbols"}]
    ["𞹜",{"tag":["unassigned"],"plane":"Supplementary Multilingual Plane (SMP)","area":"General Scripts Area (RTL)","block":"Arabic Mathematical Alphabetic Symbols"}]
    ["𞹝",{"tag":["assigned"],"plane":"Supplementary Multilingual Plane (SMP)","area":"General Scripts Area (RTL)","block":"Arabic Mathematical Alphabetic Symbols"}]
    ["𞹞",{"tag":["unassigned"],"plane":"Supplementary Multilingual Plane (SMP)","area":"General Scripts Area (RTL)","block":"Arabic Mathematical Alphabetic Symbols"}]
    ["𞹟",{"tag":["assigned"],"plane":"Supplementary Multilingual Plane (SMP)","area":"General Scripts Area (RTL)","block":"Arabic Mathematical Alphabetic Symbols"}]
    ["𞹠",{"tag":["unassigned"],"plane":"Supplementary Multilingual Plane (SMP)","area":"General Scripts Area (RTL)","block":"Arabic Mathematical Alphabetic Symbols"}]
    ["𞹡",{"tag":["assigned"],"plane":"Supplementary Multilingual Plane (SMP)","area":"General Scripts Area (RTL)","block":"Arabic Mathematical Alphabetic Symbols"}]
    ]
  #.........................................................................................................
  reducers =
    name:     'skip'
    type:     'skip'
    comment:  'skip'
  #.........................................................................................................
  CW.read_isl ( error, isl ) =>
    throw error if error?
    # for [ probe, matcher, ] in probes_and_matchers
    #   echo s [ probe, ISL.aggregate isl, probe, reducers ]
    for [ probe, matcher, ] in probes_and_matchers
      T.eq ( ISL.aggregate isl, probe, reducers ), matcher
    done()
  #.........................................................................................................
  return null


############################################################################################################
unless module.parent?
  include = [
    # "demo"
    "superficial API test"
    "test Unicode ISL against select codepoints"
    ]
  @_prune()
  @_main()

  # @[ "(v3) match, intersect" ]()


