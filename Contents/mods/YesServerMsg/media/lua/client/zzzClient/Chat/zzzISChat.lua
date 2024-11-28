ServerMessageUI = ISUIElement:derive("ServerMessageUI")

function ServerMessageUI:initialise()
    ISUIElement.initialise(self)
    self.servermsg = nil
    self.servermsgTimer = 0
    self:setVisible(false)
end

function ServerMessageUI:prerender()
    if self.servermsg and ISChat.instance.isClosed then
        local x = getCore():getScreenWidth() / 2 - self:getX()
        local y = getCore():getScreenHeight() / 4 - self:getY();
        self:drawTextCentre(self.servermsg, x, y, 1, 0.1, 0.1, 1, UIFont.Title)
        self.servermsgTimer = self.servermsgTimer - UIManager.getMillisSinceLastRender()
        if self.servermsgTimer < 0 then
            self.servermsg = nil
            self.servermsgTimer = 0
        end
    end
end

function ServerMessageUI:setServerMessage(message)
    self.servermsg = message
    self.servermsgTimer = 5000 -- Display for 5 seconds
end

local originalISChat_addLineInChat = ISChat.addLineInChat
function ISChat.addLineInChat(message, tabID)
    local chat = ISChat.instance
    if message:isServerAlert() then
        local msg = ""
        if message:isShowAuthor() then
            msg = message:getAuthor() .. ": "
        end
        msg = msg .. message:getText()
        chat.serverMessageUI:setServerMessage(msg)
    end
    originalISChat_addLineInChat(message)
end

local original_ISChat_initialise = ISChat.initialise
function ISChat:initialise()
    self.serverMessageUI = ServerMessageUI:new(0, 0, 0, 0)
    self.serverMessageUI:initialise()
    self.serverMessageUI:addToUIManager()
    self.serverMessageUI:setVisible(false)
    original_ISChat_initialise(self)
end



local original_ISChat_close = ISChat.close
function ISChat:close()
    original_ISChat_close(self)
    self.isClosed = true
    self.serverMessageUI:setVisible(true)
end

-- local original_ISChat_prerender = ISChat.prerender
-- function ISChat:prerender()
--     if self.isClosed then
--         self.serverMessageUI:setVisible(true)
--     end
--     original_ISChat_prerender(self)
-- end

local original_ISChat_focus = ISChat.focus
function ISChat:focus()
    if self.isClosed then
        self.isClosed = false
    end
    original_ISChat_focus(self)
end