local AttackBoard = require("battleship.boards.attack")
local DefenseBoard = require("battleship.boards.defense")
local BoardUI = require("battleship.ui.board")
local PromptUI = require("battleship.ui.prompt")
local LogUI = require("battleship.ui.log")
local AIFactory = require("battleship.ais.factory")

local constants = require("battleship.constants")

---@class Game
---@field difficulty string
---@field boards { player: { attack: AttackBoard, defense: DefenseBoard }, cpu: { attack: AttackBoard, defense: DefenseBoard } }
---@field is_player_turn boolean
---@field ui { board: BoardInterface, prompt: PromptInterface, log: LogInterface }
---@field ai CpuAI
local Game = {}

---@class GameOptions
---@field difficulty string?

---Creates a new game
---@param options table?
---@return Game
function Game:new(options)
    options = options or {}
    local difficulty = options.difficulty or "easy"
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
            log = LogUI:new(constants.UI.LOG_DEFAULT_OPTS),
        },
    }
    data.ai = AIFactory(difficulty, data.boards.cpu.attack)
    setmetatable(data, self)
    self.__index = self
    return data
end

function Game:configure()
    self.boards.player.attack:set_opposite(self.boards.cpu.defense)
    self.boards.cpu.attack:set_opposite(self.boards.player.defense)

    self.ui.board:attach_boards({
        attack = self.boards.player.attack,
        defense = self.boards.cpu.attack,
    })

    vim.api.nvim_create_autocmd("VimResized", {
        group = constants.BATTLESHIP_AUTO_GROUP,
        callback = function()
            vim.schedule(function()
                self:on_resize()
            end)
        end,
    })

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = self.ui.prompt.buf,
        callback = function()
            pcall(function()
                self:close()
            end)
            return true
        end,
    })

    vim.keymap.set({ "n", "i" }, "<C-h>", function()
        self.ui.board:toggle()
        self.ui.board:render()
    end, { buffer = self.ui.prompt.buf, silent = true })

    vim.keymap.set("n", "<Esc>", function()
        self:close()
        return true
    end, { buffer = self.ui.prompt.buf, silent = true })
end

function Game:start()
    self:configure()

    self.ui.log:show()
    self.ui.board:show()
    self.ui.prompt:show()

    self.ui.board:render()
    self:loop()
end

function Game:loop()
    local prompt_ui = self.ui.prompt

    if self.is_player_turn then
        local attack_board = self.boards.player.attack
        prompt_ui:read(function(coordinates)
            local row = string.upper(coordinates.row)
            local col = coordinates.col + 1
            local status = attack_board:guess(row, col)
            return self:handle_move(row, col, status)
        end)
    else
        -- For now: just pick a random spot
        local attack_board = self.boards.cpu.attack
        local row = constants.BOARD_ROWS[math.random(1, 10)]
        local col = math.random(1, 10)
        local status = attack_board:guess(row, col)
        return self:handle_move(row, col, status)
    end
end

---Handle game end of turn
---@param row string
---@param col number
---@param status HitStatus|false
---@return nil
function Game:handle_move(row, col, status)
    if not status then
        return self:loop()
    end

    local board_ui = self.ui.board
    local log_ui = self.ui.log

    local size = status.hit
    local attacker = self.is_player_turn and "Player" or "CPU"
    local defender = attacker == "Player" and "CPU" or "Player"
    local effect = size > 0 and "hit" or "miss"
    log_ui:print(string.format("%s %s on %s%d", attacker, effect, row, col - 1))

    if self.is_player_turn then
        board_ui:update_board(row, col, effect == "hit" and tostring(size) or "~")
    end

    self.is_player_turn = not self.is_player_turn

    if size == 0 then
        return self:loop()
    end

    if status.game_over then
        return self:handle_game_over(attacker)
    end

    if status.destroyed then
        local terminator = attacker == "Player" and "!" or ""
        log_ui:print(
            string.format("%s %s sunk%s", defender, constants.SHIPS_NAMES[size], terminator)
        )
    end
    return self:loop()
end

function Game:on_resize()
    local client = vim.api.nvim_list_uis()[1]
    local new_height = client.height
    local new_width = client.width

    local board_min_width = self.ui.board.min_width
    local log_min_width = self.ui.log.min_width

    local board_min_height = self.ui.board.min_height
    local prompt_min_height = self.ui.prompt.min_height

    local min_width = board_min_width + log_min_width + 2
    local min_height = board_min_height + prompt_min_height + 2

    -- Takes paddings into account
    if new_width < min_width then
        error("UI too narrow for battleship.nvim", 2)
    end
    if new_height < min_height then
        error("UI too short for battleship.nvim", 2)
    end

    local padding_left = math.floor((new_width - min_width) / 2)
    local padding_top = math.min(5, math.floor((new_height - min_height) / 2))

    self.ui.board:resize({ col = padding_left, row = padding_top })
    self.ui.prompt:resize({ col = padding_left, row = padding_top + board_min_height + 2 })
    self.ui.log:resize({ col = padding_left + board_min_width + 2, row = padding_top })
end

---Handles game over
---@param winner string
function Game:handle_game_over(winner)
    local log_ui = self.ui.log
    if winner == "Player" then
        log_ui:print("Player wins!")
    else
        log_ui:print("CPU wins.")
    end
end

function Game:close()
    local board_ui = self.ui.board
    local prompt_ui = self.ui.prompt
    local log_ui = self.ui.log

    vim.api.nvim_win_close(log_ui.win, true)
    vim.api.nvim_win_close(board_ui.win, true)
    vim.api.nvim_win_close(prompt_ui.win, true)
    vim.api.nvim_buf_delete(log_ui.buf, { force = true })
    vim.api.nvim_buf_delete(board_ui.buf, { force = true })
    vim.api.nvim_buf_delete(prompt_ui.buf, { force = true })
end

return Game
