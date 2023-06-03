module Track exposing (..)


type alias Track =
    List (List Int)


default : Track
default =
    [ [ 0 ]
    , [ 2 ]
    , [ 4 ]
    , [ 3 ]
    , [ 0 ]
    , [ 2, -2 ]
    , [ 4, -4 ]
    , [ 3, -3 ]
    ]
        |> List.repeat 4
        |> List.concat


next : Track -> ( List Int, Track )
next track =
    case track of
        head :: tail ->
            ( head, tail ++ [ head ] )

        [] ->
            ( [], [] )
