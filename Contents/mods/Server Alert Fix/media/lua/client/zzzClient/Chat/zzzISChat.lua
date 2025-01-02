ServerMessageUI = ISUIElement:derive("ServerMessageUI")

function ServerMessageUI:new (x, y, width, height)
    local o = {}
    o = ISUIElement:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.x = x;
    o.y = y;
    o.width = width;
    o.height = height;
    o.servermsg = "";
    o.servermsgTimer = 0;
    ServerMessageUI.instance = o;
    return o
end

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
    self:setVisible(true)
    self.servermsg = message
    self.servermsgTimer = SandboxVars.ServerAlertFix.Timer or 5000 -- Display for 5 seconds
    if self.servermsgTimer == 0 then
        self.servermsg = nil
        self:setVisible(false)
    end
end

function ServerMessageUI.getInstance()
    if not ServerMessageUI.instance then
        local ui = ServerMessageUI:new(0, 0, 0, 0)
        ui:initialise()
        ui:addToUIManager()
    end
    return ServerMessageUI.instance
end


local originalISChat_addLineInChat = ISChat.addLineInChat
function ISChat.addLineInChat(message, tabID)
    -- Chiamiamo la versione originale
    originalISChat_addLineInChat(message, tabID)

    -- Se il messaggio è un alert del server
    if message:isServerAlert() then
        -- Here, we disable the server message UI vanilla
        local chat = ISChat.instance
        if chat then
            chat.servermsg = nil
            chat.servermsgTimer = 0
        end

        -- Ricaviamo autore e testo
        local author = message:isShowAuthor() and message:getAuthor() or ""
        local text   = message:getText()

        -- Componiamo il messaggio
        local fullMsg
        if author ~= "" then
            fullMsg = author .. ": " .. text
        else
            fullMsg = text
        end

        -- Mostriamo il messaggio attraverso la nostra UI personalizzata
        local myUI = ServerMessageUI.getInstance()
        myUI:setServerMessage(fullMsg)  -- durata 5 secondi (ms)
    end
end
