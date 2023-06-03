module Track exposing (..)

import Array exposing (Array)
import Note exposing (Note(..))


type alias Track =
    Array (List Note)


default : Track
default =
    [ [ C2 ]
    , [ A2 ]
    , [ F2 ]
    , [ E2 ]
    , [ C2 ]
    , [ A1, E2 ]
    , [ F1, F2 ]
    , [ E1, A2 ]
    ]
        |> List.repeat 4
        |> List.concat
        |> Array.fromList


next : Track -> ( List Note, Track )
next track =
    case track |> Array.toList of
        head :: tail ->
            ( head, tail ++ [ head ] |> Array.fromList )

        [] ->
            ( [], Array.empty )
