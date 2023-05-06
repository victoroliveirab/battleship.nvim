local AttackBoard = require("battleship.boards.attack")
local DefenseBoard = require("battleship.boards.defense")
local BoardUI = require("battleship.ui.board")
local PromptUI = require("battleship.ui.prompt")

local constants = require("battleship.constants")

---@class Game
---@field difficulty string
---@field boards { player: { attack: AttackBoard, defense: DefenseBoard }, cpu: { attack: AttackBoard, defense: DefenseBoard } }
---@field is_player_turn boolean
---@field ui { board: BoardInterface, prompt: PromptInterface }
local Game = {}

---@class GameOptions
---@field difficulty string?

---Creates a new game
---@param options table?
---@return Game
function Game:new(options)
    options = options or {}
    local difficulty = options.difficulty or "medium"
    local data = {
        difficulty = difficulty,
        boards = {
            player = {
                attack = AttackBoard:new({ name = "Attack Board" }),
                defense = DefenseBoard:new({ name = "Your Board" }),
            },
            cpu = {
                attack = AttackBoard:new({ name = "CPU Attack Board" }),
                defense = DefenseBoard:new({ name = "CPU Defense Board" }),
            },
        },
        is_player_turn = true,
        ui = {
            board = BoardUI:new(constants.UI.BOARD_DEFAULT_OPTS),
            prompt = PromptUI:new(constants.UI.PROMPT_DEFAULT_OPTS),
        },
    }
    setmetatable(data, self)
    self.__index = self
    return data
end

function Game:start()
    self.boards.player.attack:set_opposite(self.boards.cpu.defense)
    self.boards.cpu.attack:set_opposite(self.boards.player.defense)

    self.ui.board:show()
    self.ui.prompt:show()

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = self.ui.prompt.buf,
        callback = function()
            self:close()
            return true
        end,
    })

    self:loop()
end

function Game:loop()
    local board_ui = self.ui.board
    local prompt_ui = self.ui.prompt

    if self.is_player_turn then
        local attack_board = self.boards.player.attack
        board_ui:print_board(attack_board, constants.BOARD_ROWS)
        prompt_ui:read(function(coordinates)
            local row = string.upper(coordinates.row)
            local col = coordinates.col + 1
            local status = attack_board:guess(row, col)
            if not status then
                return self:loop()
            end
            local size = status.hit
            if status.game_over then
                self:handle_hit(row, col, tostring(size))
                return self:handle_game_over()
            end
            self.is_player_turn = false
            if size == 0 then
                self:handle_miss(row, col)
                return self:loop()
            end

            self:handle_hit(row, col, tostring(size))
            return self:loop()
        end)
    else
        -- For now: just pick a random spot
        local attack_board = self.boards.cpu.attack

        while true do
            local row = constants.BOARD_ROWS[math.random(1, 10)]
            local col = math.random(1, 10)
            local status = attack_board:guess(row, col)
            if status then
                if status.game_over then
                    return self:handle_game_over()
                end
                self.is_player_turn = true
                return self:loop()
            end
        end
    end
end

function Game:handle_game_over()
    if self.is_player_turn then
        print("YOU WON!!!")
    else
        print("you lost :(")
    end
end

function Game:handle_miss(row, col)
    local board_ui = self.ui.board
    board_ui:update_board(row, col, "~")
end

function Game:handle_hit(row, col, value)
    local board_ui = self.ui.board
    board_ui:update_board(row, col, value)
end

function Game:close()
    local board_ui = self.ui.board
    local prompt_ui = self.ui.prompt

    vim.api.nvim_win_close(board_ui.win, true)
    vim.api.nvim_win_close(prompt_ui.win, true)
    vim.api.nvim_buf_delete(board_ui.buf, { force = true })
    vim.api.nvim_buf_delete(prompt_ui.buf, { force = true })
end

return Game
