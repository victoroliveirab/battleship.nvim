return {
    BATTLESHIP_AUTO_GROUP = "BattleshipAuGroup",
    BATTLESHIP_NAMESPACE = "BattleshipNamespace",
    ---@type string[]
    BOARD_ROWS = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J" },
    BOARD_ROWS_INDEXES = {
        A = 1,
        B = 2,
        C = 3,
        D = 4,
        E = 5,
        F = 6,
        G = 7,
        H = 8,
        I = 9,
        J = 10,
    },
    CHARS_MAP = {
        PIPE = "│",
        DASH = "─",
    },
    UI = {
        ---@type InterfaceOptions
        BOARD_DEFAULT_OPTS = {
            height = 20,
            width = 45,
            row = 5,
            col = 10,
            title = " Attack Board ",
        },
        ---@type InterfaceOptions
        PROMPT_DEFAULT_OPTS = {
            height = 1,
            width = 45,
            row = 27,
            col = 10,
        },
        ---@type InterfaceOptions
        LOG_DEFAULT_OPTS = {
            height = 23,
            width = 30,
            row = 5,
            col = 58,
        },
    },
    SHIPS = {
        Destroyer = 2,
        Submarine = 3,
        Cruiser = 3,
        Battleship = 4,
        Carrier = 5,
    },
}
