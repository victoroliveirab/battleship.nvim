local AttackBoard = require("battleship.boards.attack")
local DefenseBoard = require("battleship.boards.defense")
local BoardUI = require("battleship.ui.board")
local PromptUI = require("battleship.ui.prompt")
local LogUI = require("battleship.ui.log")

local constants = require("battleship.constants")

---@class Game
---@field difficulty string
---@field boards { player: { attack: AttackBoard, defense: DefenseBoard }, cpu: { attack: AttackBoard, defense: DefenseBoard } }
---@field is_player_turn boolean
---@field ui { board: BoardInterface, prompt: PromptInterface, log: LogInterface }
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
            log = LogUI:new(constants.UI.LOG_DEFAULT_OPTS),
        },
    }
    setmetatable(data, self)
    self.__index = self
    return data
end

function Game:configure()
    self.boards.player.attack:set_opposite(self.boards.cpu.defense)
    self.boards.cpu.attack:set_opposite(self.boards.player.defense)

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

    self.ui.board:print_board(self.boards.player.attack, constants.BOARD_ROWS)
    self:loop()
end

function Game:loop()
    local log_ui = self.ui.log
    local prompt_ui = self.ui.prompt

    if self.is_player_turn then
        local attack_board = self.boards.player.attack
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
                log_ui:print("Player miss on " .. row .. tostring(col - 1))
                self:handle_miss(row, col)
                return self:loop()
            end

            log_ui:print("Player hit on " .. row .. tostring(col - 1))
            self:handle_hit(row, col, tostring(size))
            return self:loop()
        end)
    else
        -- For now: just pick a random spot
        local attack_board = self.boards.cpu.attack

        local row, col, status
        while not status do
            row = constants.BOARD_ROWS[math.random(1, 10)]
            col = math.random(1, 10)
            status = attack_board:guess(row, col)
            if status then
                if status.game_over then
                    return self:handle_game_over()
                end
            end
        end

        local size = status.hit
        local result = size == 0 and "miss" or "hit"
        log_ui:print("CPU " .. result .. " on " .. row .. tostring(col - 1))

        self.is_player_turn = true
        return self:loop()
    end
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

function Game:handle_game_over()
    local log_ui = self.ui.log
    if self.is_player_turn then
        log_ui:print("Player wins!")
    else
        log_ui:print("CPU wins.")
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
    local log_ui = self.ui.log

    vim.api.nvim_win_close(log_ui.win, true)
    vim.api.nvim_win_close(board_ui.win, true)
    vim.api.nvim_win_close(prompt_ui.win, true)
    vim.api.nvim_buf_delete(log_ui.buf, { force = true })
    vim.api.nvim_buf_delete(board_ui.buf, { force = true })
    vim.api.nvim_buf_delete(prompt_ui.buf, { force = true })
end

return Game
