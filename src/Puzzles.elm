module Puzzles exposing (Puzzle, allLayers, puzzles)

-- PUZZLES
-- Each puzzle is a list of layer IDs in bottom-to-top stacking order.


type alias Puzzle =
    List String


puzzles : List Puzzle
puzzles =
    [ [ "001", "002", "003" ]
    , [ "002", "004" ]
    , [ "001", "003", "005" ]
    ]


allLayers : List String
allLayers =
    [ "001", "002", "003", "004", "005" ]
