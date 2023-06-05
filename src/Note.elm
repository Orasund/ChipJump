module Note exposing (..)

import Config


type Note
    = C1
    | D1
    | E1
    | F1
    | G1
    | A1
    | B1
    | C2
    | D2
    | E2
    | F2
    | G2
    | A2
    | B2
    | C3


toInt : Note -> Int
toInt note =
    case note of
        C1 ->
            0

        D1 ->
            1

        E1 ->
            2

        F1 ->
            3

        G1 ->
            4

        A1 ->
            5

        B1 ->
            6

        C2 ->
            7

        D2 ->
            8

        E2 ->
            9

        F2 ->
            10

        G2 ->
            11

        A2 ->
            12

        B2 ->
            13

        C3 ->
            14


toString : Note -> String
toString note =
    case note of
        C1 ->
            "C1"

        D1 ->
            "D1"

        E1 ->
            "E1"

        F1 ->
            "F1"

        G1 ->
            "G1"

        A1 ->
            "A1"

        B1 ->
            "B1"

        C2 ->
            "C2"

        D2 ->
            "D2"

        E2 ->
            "E2"

        F2 ->
            "F2"

        G2 ->
            "G2"

        A2 ->
            "A2"

        B2 ->
            "B2"

        C3 ->
            "C3"


bar : List (List Note) -> List (List Note)
bar list =
    if List.length list < Config.beatsPerBar then
        list
            |> List.concatMap (\l -> [ l, [] ])
            |> bar

    else
        list
