module Song exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Note exposing (Note(..))


type alias Instrument =
    String


type alias Song =
    Dict Instrument (Array (List Note))


default : Song
default =
    [ ( lilyPadInstrument
      , ([ Note.bar
            [ [ C2, C1, C3 ]
            , [ A2 ]
            , [ F2 ]
            , [ E2 ]
            ]
         , Note.bar
            [ [ C2, G1 ]
            , [ A1 ]
            , [ F1, C2 ]
            , [ D2 ]
            ]
         , Note.bar
            [ [ F1, C2 ]
            , [ D2 ]
            , [ F1, A2 ]
            , []
            , [ C1, F2 ]
            , [ G2 ]
            , [ D1, E2 ]
            , [ D2 ]
            ]
         , Note.bar
            [ [ F1, C2, G1 ]
            , [ F1, A1 ]
            , [ A1, F1, C2 ]
            , [ D2 ]
            ]
         ]
            |> List.concat
            |> List.repeat 4
            |> List.concat
        )
            ++ [ [ C2 ] ]
            |> Array.fromList
      )
    ]
        |> Dict.fromList



--c*d*ef*g*a*b
--CEG
--FAC
--GBD


lilyPadInstrument : Instrument
lilyPadInstrument =
    "lilyPadInstrument"


waveInstrument : Instrument
waveInstrument =
    "waveInstrument"
