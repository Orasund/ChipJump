module Track exposing (..)


type alias Track =
    List (List Int)


default : Track
default =
    [ 0, 1, -1 ] |> List.repeat 4


next : Track -> ( List Int, Track )
next track =
    case track of
        head :: tail ->
            ( head, tail ++ [ head ] )

        [] ->
            ( [], [] )
