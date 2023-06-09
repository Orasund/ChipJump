module View.Common exposing (..)

import Config
import Note exposing (Note)


calcLilyPadPosition : { ratioToNextBeat : Float, beatsPlayed : Int, start : Int, note : Note } -> ( Float, Float )
calcLilyPadPosition args =
    let
        ratio =
            args.ratioToNextBeat
    in
    ( Config.horizontalSpaceBetweenPlatforms
        * toFloat (Note.toInt args.note + 5 |> modBy 7)
    , Config.verticalSpaceBetweenPlatforms
        * (toFloat -args.start + ratio + toFloat args.beatsPlayed)
        + Config.screenHeight
        - (Config.lilyPadSize
            * 2
          )
    )
