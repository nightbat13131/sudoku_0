class_name Utilties extends RefCounted

const SODOKU_GUESS = &"Sudoku Guess"
const INPUT_UNDO = &"undo"
const INPUT_REDO = &"redo"


enum Difficulty {EASY = 0, MEDIUM = 1, HARD = 2}

## valid SUDOCU cell values are 1+. Map out the meaing of alternate values.
enum Sudoku_Cell_Alts {EMPTY = 0, GUESS_BLOCKED = -1 }
