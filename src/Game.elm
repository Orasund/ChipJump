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
    , platforms : Dict PlatformId { position : ( Int, Int ), active : Bool }
    , player : PlayerPos
    }


togglePlatform : PlatformId -> Game -> Game
togglePlatform id game =
    { game
        | platforms =
            game.platforms
                |> Dict.update id
                    (Maybe.map (\platform -> { platform | active = not platform.active }))
    }


nextPlayerPos : Game -> Game
nextPlayerPos game =
    let
        player =
            case game.player of
                OnPlatform platformId ->
                    OnPlatform platformId

                Jumping { to } ->
                    Jumping { from = to, to = to + 3 }
    in
    { game | player = player }


new : Game
new =
    let
        track =
            Track.default

        platforms =
            track
                |> List.indexedMap
                    (\j list ->
                        list |> List.map (\i -> { position = ( i, j ), active = False })
                    )
                |> List.concat
                |> List.indexedMap Tuple.pair
                |> Dict.fromList

        player =
            Jumping { from = 0, to = 5 }
    in
    { track = track
    , platforms = platforms
    , player = player
    }
