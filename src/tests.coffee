


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
    help 'ok'
    done()
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "test Unicode ISL against select codepoints" ] = ( T, done ) ->
  probes_and_matchers = [
    ["a",{"plane":"Basic Multilingual Plane (BMP)","area":"ASCII & Latin-1 Compatibility Area","block":"Basic Latin","rsg":"u-latn"}]
    ["ä",{"plane":"Basic Multilingual Plane (BMP)","area":"ASCII & Latin-1 Compatibility Area","block":"Latin-1 Supplement","rsg":"u-latn-1"}]
    ["ɐ",{"plane":"Basic Multilingual Plane (BMP)","area":"General Scripts Area","block":"IPA Extensions","rsg":"u-ipa-x"}]
    ["ա",{"plane":"Basic Multilingual Plane (BMP)","area":"General Scripts Area","block":"Armenian"}]
    ["三",{"plane":"Basic Multilingual Plane (BMP)","area":"CJKV Unified Ideographs Area","block":"CJK Unified Ideographs","rsg":"u-cjk","tag":["cjk","ideograph"]}]
    ["ゆ",{"plane":"Basic Multilingual Plane (BMP)","area":"CJK Miscellaneous Area","block":"Hiragana","rsg":"u-cjk-hira","tag":["cjk","japanese","kana","hiragana"]}]
    ["㈪",{"plane":"Basic Multilingual Plane (BMP)","area":"CJK Miscellaneous Area","block":"Enclosed CJK Letters and Months","rsg":"u-cjk-enclett","tag":["cjk"]}]
    ["《",{"plane":"Basic Multilingual Plane (BMP)","area":"CJK Miscellaneous Area","block":"CJK Symbols and Punctuation","rsg":"u-cjk-sym","tag":["cjk","punctuation"]}]
    ["》",{"plane":"Basic Multilingual Plane (BMP)","area":"CJK Miscellaneous Area","block":"CJK Symbols and Punctuation","rsg":"u-cjk-sym","tag":["cjk","punctuation"]}]
    ["𫠠",{"plane":"Supplementary Ideographic Plane (SIP)","block":"CJK Unified Ideographs Extension E","rsg":"u-cjk-xe","tag":["cjk","ideograph"]}]
    ["﹄",{"plane":"Basic Multilingual Plane (BMP)","area":"Compatibility and Specials Area","block":"CJK Compatibility Forms","rsg":"u-cjk-cmpf","tag":["cjk","vertical"]}]
    ["﹅",{"plane":"Basic Multilingual Plane (BMP)","area":"Compatibility and Specials Area","block":"CJK Compatibility Forms","rsg":"u-cjk-cmpf","tag":["cjk"]}]
    ["𝍖",{"plane":"Supplementary Multilingual Plane (SMP)","area":"Symbols Area","block":"Tai Xuan Jing Symbols","rsg":"u-txj-sym","tag":["cjk","yijing","taixuanjing","tetragram"]}]
    ["𝍗",{"plane":"Supplementary Multilingual Plane (SMP)","area":"Symbols Area","block":"Tai Xuan Jing Symbols","rsg":"u-txj-sym","tag":["reserved"]}]
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
    "test Unicode ISL against select codepoints"
    ]
  @_prune()
  @_main()

  # @[ "(v3) match, intersect" ]()


