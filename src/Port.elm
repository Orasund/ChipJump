module Port exposing (..)

import Json.Encode as E exposing (Value)
import Note exposing (Note)


playSound : List Note -> Value
playSound notes =
    E.object
        [ ( "name", E.string "playSound" )
        , ( "sound"
          , notes
                |> List.map Note.toString
                |> E.list E.string
          )
        ]
