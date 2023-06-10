module Config exposing (..)


lilyPadSize : Float
lilyPadSize =
    100


waveSize : Float
waveSize =
    200


bigStoneSize : Float
bigStoneSize =
    100


smallStoneSize : Float
smallStoneSize =
    100


horizontalSpaceBetweenPlatforms : Float
horizontalSpaceBetweenPlatforms =
    (screenWidth - sidePaddings * 2 - lilyPadSize) / 6


verticalSpaceBetweenPlatforms : Float
verticalSpaceBetweenPlatforms =
    80


screenHeight : Float
screenHeight =
    600


sidePaddings : Float
sidePaddings =
    50


screenWidth : Float
screenWidth =
    400


playerSize : Float
playerSize =
    60


minBpm : Float
minBpm =
    60


bpmIncrease : Float
bpmIncrease =
    0.25


bpmPercentDecrease : Float
bpmPercentDecrease =
    0.07


jumpTime : Float
jumpTime =
    1 / 4


maxJumpSize : Int
maxJumpSize =
    2


beatsPerBar : Int
beatsPerBar =
    8


backgroundColor : String
backgroundColor =
    "#010f16"


playerColor : String
playerColor =
    "#ce9f39"


lilyPadColor : String
lilyPadColor =
    "#6d7753"


fireflyColor : String
fireflyColor =
    "#ee3907"


padColor : String
padColor =
    "#001518"


playerZIndex : Int
playerZIndex =
    100


inactiveLilyPadZIndex : Int
inactiveLilyPadZIndex =
    10


activeLilyPadZIndex : Int
activeLilyPadZIndex =
    1
