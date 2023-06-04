module View.Common exposing (..)

import Config
import Note exposing (Note)


calcPlatformPosition : { ratioToNextBeat : Float, beatsPlayed : Int, start : Int, note : Note } -> ( Float, Float )
calcPlatformPosition args =
    let
        ratio =
            args.ratioToNextBeat
    in
    ( Config.horizontalSpaceBetweenPlatforms
        * toFloat (Note.toInt args.note)
    , (Config.platformHeight + Config.verticalSpaceBetweenPlatforms)
        * (toFloat -args.start + ratio + toFloat args.beatsPlayed)
        + Config.screenHeight
        - (Config.platformHeight
            * 2
          )
    )
