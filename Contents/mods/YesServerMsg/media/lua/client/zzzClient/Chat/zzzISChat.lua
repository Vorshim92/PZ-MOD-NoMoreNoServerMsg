ServerMessageUI = ISUIElement:derive("ServerMessageUI")

function ServerMessageUI:initialise()
    ISUIElement.initialise(self)
    self.servermsg = nil
    self.servermsgTimer = 0
    self:setVisible(false)
end

function ServerMessageUI:prerender()
    if self.servermsg then
        local x = getCore():getScreenWidth() / 2 - self:getX()
        local y = getCore():getScreenHeight() / 4 - self:getY();
        self:drawTextCentre(self.servermsg, x, y, 1, 0.1, 0.1, 1, UIFont.Title)
        self.servermsgTimer = self.servermsgTimer - UIManager.getMillisSinceLastRender()
        if self.servermsgTimer < 0 then
            self.servermsg = nil
            self.servermsgTimer = 0
            self:setVisible(false) -- we disable it when the message is over
        end
    end
end

function ServerMessageUI:setServerMessage(message)
    self.servermsg = message
    self.servermsgTimer = 5000 -- Display for 5 seconds
    self:setVisible(true)
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
    -- Here, we disable the server message UI vanilla
    chat.servermsg = nil;
    chat.servermsgTimer = 0;
end

local original_ISChat_initialise = ISChat.initialise
function ISChat:initialise()
    self.serverMessageUI = ServerMessageUI:new(0, 0, 0, 0)
    self.serverMessageUI:initialise()
    self.serverMessageUI:addToUIManager()
    self.serverMessageUI:setVisible(false) -- we avoid useless rendering with setVisible(false)
    original_ISChat_initialise(self)
end