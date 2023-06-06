module Port exposing (..)

import Json.Encode as E exposing (Value)
import Note exposing (Note)


playSound : String -> List Note -> Value
playSound instrument notes =
    E.object
        [ ( "name", E.string "playSound" )
        , ( "sound"
          , notes
                |> List.map Note.toString
                |> E.list E.string
          )
        , ( "instrument"
          , E.string instrument
          )
        ]


toggleMute : Value
toggleMute =
    E.object
        [ ( "name", E.string "toggleMute" ) ]


setVolume : Float -> Value
setVolume amount =
    E.object
        [ ( "name", E.string "setVolume" )
        , ( "amount", E.float amount )
        ]
