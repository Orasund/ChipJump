module Note exposing (Note, a1, a2, a3, a4, b1, b2, b3, b4, bang, bar, c1, c2, c3, c4, d1, d2, d3, d4, e1, e2, e3, e4, f1, f2, f3, f4, g1, g2, g3, g4, pause, toInt, toString)

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
    | D3
    | E3
    | F3
    | G3
    | A3
    | B3
    | C4
    | D4
    | E4
    | F4
    | G4
    | A4
    | B4


bang : Note
bang =
    C1


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

        D3 ->
            15

        E3 ->
            16

        F3 ->
            17

        G3 ->
            18

        A3 ->
            19

        B3 ->
            20

        C4 ->
            21

        D4 ->
            22

        E4 ->
            23

        F4 ->
            24

        G4 ->
            25

        A4 ->
            26

        B4 ->
            27


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

        D3 ->
            "D3"

        E3 ->
            "E3"

        F3 ->
            "F3"

        G3 ->
            "G3"

        A3 ->
            "A3"

        B3 ->
            "B3"

        C4 ->
            "C4"

        D4 ->
            "D4"

        E4 ->
            "E4"

        F4 ->
            "F4"

        G4 ->
            "G4"

        A4 ->
            "A4"

        B4 ->
            "B4"


bar : List (List Note) -> List (List Note)
bar list =
    if List.length list < Config.beatsPerBar then
        list
            |> List.concatMap (\l -> [ l, [] ])
            |> bar

    else
        list


c1 =
    [ C1 ]


d1 =
    [ D1 ]


e1 =
    [ E1 ]


f1 =
    [ F1 ]


g1 =
    [ G1 ]


a1 =
    [ A1 ]


b1 =
    [ B1 ]


c2 =
    [ C2 ]


d2 =
    [ D2 ]


e2 =
    [ E2 ]


f2 =
    [ F2 ]


g2 =
    [ G2 ]


a2 =
    [ A2 ]


b2 =
    [ B2 ]


c3 =
    [ C3 ]


d3 =
    [ D3 ]


e3 =
    [ E3 ]


f3 =
    [ F3 ]


g3 =
    [ G3 ]


a3 =
    [ A3 ]


b3 =
    [ B3 ]


c4 =
    [ C4 ]


d4 =
    [ D4 ]


e4 =
    [ E4 ]


f4 =
    [ F4 ]


g4 =
    [ G4 ]


a4 =
    [ A4 ]


b4 =
    [ B3 ]


pause =
    []
