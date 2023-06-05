module Song exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Note exposing (..)


type alias Instrument =
    String


type alias Song =
    Dict Instrument (Array (List Note))


default : Song
default =
    let
        part1 =
            [ Note.bar [ a2, f2, e2, c2 ++ g1 ]
            , Note.bar [ a1, f1 ++ c2, d2, c2 ++ c1 ++ c3 ]
            ]

        part2 =
            [ Note.bar
                [ a2 ++ c2 ++ f2
                , pause
                , f2
                , g2
                , e1 ++ g1 ++ c2
                , d2
                , c2
                , pause
                ]
            , Note.bar
                [ a1
                , pause
                , f1 ++ a1 ++ c1
                , e1
                , d2
                , c1
                , c2 ++ e1 ++ g1
                , g1
                ]
            ]

        part3 =
            [ Note.bar
                [ c2 ++ e1 ++ g1
                , d2
                , a2 ++ c2 ++ f2
                , pause
                , f2 ++ a1 ++ c2
                , g2
                , e1 ++ g1 ++ c2
                , pause
                ]
            , Note.bar
                [ c2 ++ e2 ++ g2
                , g1
                , a1 ++ c2 ++ f2
                , pause
                , f1 ++ a1 ++ c1
                , e1
                , d2 ++ b1 ++ g1
                , c1
                ]
            ]

        part4 =
            [ Note.bar [ a1 ++ a2, f1 ++ f2, e1 ++ e2, c1 ++ c2 ++ g1 ]
            , Note.bar [ a1 ++ a2, f1 ++ f2 ++ c2, d2 ++ d1, c2 ++ c1 ++ c3 ]
            ]
    in
    [ ( lilyPadInstrument
      , [ c2, pause ]
            ++ ([ part1
                , part2
                , part1
                , part3
                , part4
                , part2
                , part4
                , part3
                ]
                    |> List.concat
                    |> List.concat
                    |> List.repeat 1
                    |> List.concat
               )
            ++ [ c2 ++ c1 ++ c3 ]
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
