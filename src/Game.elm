module Game exposing (..)

import Dict exposing (Dict)
import Track exposing (Track)


type alias PlatformId =
    Int


type PlayerPos
    = OnPlatform PlatformId
    | Jumping { from : PlatformId, to : PlatformId }


type alias Game =
    { track : Track
    , platforms : Dict PlatformId ( Int, Int )
    , player : PlayerPos
    }


new : Game
new =
    let
        track =
            Track.default

        platforms =
            track
                |> List.indexedMap
                    (\j list ->
                        list |> List.map (\i -> ( i, j ))
                    )
                |> List.concat
                |> List.indexedMap Tuple.pair
                |> Dict.fromList

        player =
            OnPlatform 0
    in
    { track = track
    , platforms = platforms
    , player = player
    }
