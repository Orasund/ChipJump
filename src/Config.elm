module Config exposing (..)


lilyPadSize : Float
lilyPadSize =
    90


horizontalSpaceBetweenPlatforms : Float
horizontalSpaceBetweenPlatforms =
    (screenWidth - lilyPadSize) / 14


verticalSpaceBetweenPlatforms : Float
verticalSpaceBetweenPlatforms =
    100


screenHeight : Float
screenHeight =
    600


screenWidth : Float
screenWidth =
    400


playerSize : Float
playerSize =
    60


bpm : Float
bpm =
    60


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
