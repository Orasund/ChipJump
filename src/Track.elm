module Track exposing (..)

import Array exposing (Array)
import Note exposing (Note(..))


type alias Track =
    Array (List Note)


default : Track
default =
    ([ [ C2, C1, C3 ]
     , [ A2 ]
     , [ F2 ]
     , [ E2 ]
     , [ C2, G1 ]
     , [ A1 ]
     , [ F1, C2 ]
     , [ D2 ]
     , [ F1, C2 ]
     , [ F1, A2 ]
     , [ C1, F2 ]
     , [ C1, E2 ]
     , [ F1, C2, G1 ]
     , [ F1, A1 ]
     , [ A1, F1, C2 ]
     , [ D2 ]
     ]
        |> List.repeat 4
        |> List.concat
    )
        ++ [ [ C2 ] ]
        |> Array.fromList



--c*d*ef*g*a*b
--CEG
--FAC
--GBD


next : Track -> ( List Note, Track )
next track =
    case track |> Array.toList of
        head :: tail ->
            ( head, tail ++ [ head ] |> Array.fromList )

        [] ->
            ( [], Array.empty )
