
local utils = nb.load("utils")
local net = nb.load("net")

local PacketPaser = import(".PacketParserNew")
local Packets = import(".PacketsNew")

local Socket = class("SocketNew")

Socket.SocketConnected = "SocketConnected"
Socket.SocketConnectFailure = "SocketConnectFailure"
Socket.SocketClose = "SocketClose"
Socket.SocketClosed = "SocketClosed"
Socket.SocketRecvPacket = "SocketRecvPacket"
Socket.SocketError = "SocketError"

function Socket:ctor(sockName,sockHeader,netEndian)
    -- print("socket:ctor",sockName,sockHeader,netEndian)
    self.__name = sockName

    self:setProtocol(sockHeader, netEndian)
    self.__packetId = 0
    self.__packets = {}


    --默认解析器
    self.__parser = PacketPaser.new(self,sockName)
    self.__parser:setProtocol(sockHeader,self.m_endian)


    self.__log = core.Logger.new(sockName)


end


function Socket:setParser(parser,sockHeader,netEndian)
    self.__parser = parser
end


function Socket:setOption(opt,value)
    self.__socket:setOption(opt,value)
end


function Socket:setEvent(callback)
    self.__callback = callback
end


function Socket:onSocketEvent(eventType, param)
    if self.__callback then
        self.__callback(eventType, param);
    end
end


function Socket:connect(host, port, retryConnectWhenFailure)
    print("Socket:connect",host, port, retryConnectWhenFailure)
    self:disconnect(true)
    if not self.__socket then
        self.__socket = net.SocketTCP.new(host, port, retryConnectWhenFailure or false)
        self.__socket:addEventListener(net.SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected))
        self.__socket:addEventListener(net.SocketTCP.EVENT_CLOSE, handler(self, self.onClose))
        self.__socket:addEventListener(net.SocketTCP.EVENT_CLOSED, handler(self, self.onClosed))
        self.__socket:addEventListener(net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFailure))
        self.__socket:addEventListener(net.SocketTCP.EVENT_DATA, handler(self, self.onData))
    end
    self.__socket:setName(self.__name):connect()
end


function Socket:disconnect(noEvent)
    if self.__socket then
        local socket = self.__socket
        self.__socket = nil

        if noEvent then
            socket:removeAllEventListeners()
            socket:disconnect()
        else
            socket:disconnect()
            socket:removeAllEventListeners()
        end
    end

    if self.__parser and type(self.__parser.reset) == "function" then
        self.__parser:reset()
    end
    
end



function Socket:send(data)
    local ret
    if self.__socket then
        if type(data) == "string" then
            ret = self.__socket:send(data)
        else
            ret = self.__socket:send(data:getPack())
        end
    end

    return ret
end




function Socket:onData(evt)

    self.__log:debugf("[%d] Socket:onData. %s", checkint(evt.target.socketId), evt.name)
    
    local success, packets = self.__parser:read(evt.data)
    if not success then
        self:onSocketEvent(Socket.SocketError)
    else
        -- for i, v in ipairs(packets) do
        --     self.__log:debugf("[====PACK====][%x][%s]\n==>%s", v.cmd, table.keyof(self.protocol_, v.cmd), json.encode(v))
        --     self:dispatchEvent({name=SocketService.EVT_PACKET_RECEIVED, data=v})
        -- end
    end
end

function Socket:onConnected(evt)
    self.__log:debugf("[%d] Socket:onConnected. %s", checkint(evt.target.socketId), evt.name)

    if self.__parser and type(self.__parser.reset) == "function" then
        self.__parser:reset()
    end
    self:onSocketEvent(Socket.SocketConnected)
end

function Socket:onConnectFailure(evt)
    self.__log:debugf("[%d] Socket:onConnectFailure. %s", checkint(evt.target.socketId), evt.name)

    self:onSocketEvent(Socket.SocketConnectFailure)
end


function Socket:onClose(evt)
    self.__log:debugf("[%d] Socket:onClose. %s", checkint(evt.target.socketId), evt.name)
    self:onSocketEvent(Socket.SocketClose)
end

function Socket:onClosed(evt)
    self.__log:debugf("[%d] Socket:onClosed. %s", checkint(evt.target.socketId), evt.name)

    self:onSocketEvent(Socket.SocketClosed)
end

function Socket:setProtocol(protocol, netEndian)
    self.m_endian = netEndian ~= false and ">" or "<" 
    self.m_protocol = protocol

    -- print("setProtocol",self.m_endian)
end


function Socket:_addPacket(packet)

    self.__packetId = self.__packetId + 1

    -- print("_addPacket",self.__packetId,#packet)
    self.__packets[self.__packetId] =  {
        data = packet,
        position = 1
    }


    return self.__packetId
end


function Socket:readBegin(packetId)
    local packet = self.__packets[packetId]
    Packets[self.m_protocol].readBegin(self.m_endian, packet)
    return packet.head.cmd

end

function Socket:readEnd(packetId)
    self.__packets[packetId] = nil
end

function Socket:writeBegin(...)
    local packet = Packets[self.m_protocol].new(nil,self.m_endian)
    packet:writeBegin(...)
    self.__packetId = self.__packetId + 1
    self.__packets[self.__packetId] = packet
    return self.__packetId
end

function Socket:writeEnd(packetId)
    local packet = self.__packets[packetId]
    local buf = packet:writeEnd()

    -- print("Socket:writeEnd" ,#buf)
    local ret = self:send(buf)
    self.__packets[packetId] = nil
    return ret
end


function Socket:readInt(packetId, defaultValue)
    local packet = self.__packets[packetId]
    if #packet.data + 1 < packet.position + 4 then
        return defaultValue
    end
    local n
    n, packet.position = string.unpack(self.m_endian .. 'i4', packet.data, packet.position)
    return n
end

function Socket:readInt64(packetId, defaultValue)
    local packet = self.__packets[packetId]
    if #packet.data + 1 < packet.position + 8 then
        return defaultValue
    end
    local n
    n, packet.position = string.unpack(self.m_endian .. 'i8', packet.data, packet.position)
    return n
end

function Socket:readUInt(packetId, defaultValue)

     local packet = self.__packets[packetId]
    if #packet.data + 1 < packet.position + 4 then
        return defaultValue
    end
    local n
    n, packet.position = string.unpack(self.m_endian .. 'I4', packet.data, packet.position)
    return n

end


function Socket:readByte(packetId, defaultValue)
    local packet = self.__packets[packetId]
    if #packet.data + 1 < packet.position + 1 then
        return defaultValue
    end
    local n
    n, packet.position = string.unpack(self.m_endian .. 'B', packet.data, packet.position)
    return n
end

function Socket:readUByte(packetId, defaultValue)
    local packet = self.__packets[packetId]
    if #packet.data + 1 < packet.position + 1 then
        return defaultValue
    end
    local n
    n, packet.position = string.unpack(self.m_endian .. 'B', packet.data, packet.position)
    return n
end


function Socket:readLong(packetId, defaultValue)
    -- local packet = self.__packets[packetId]
    -- local val = packet:readLong()
    -- if not val then
    --     return defaultValue
    -- end
    -- return val
end

function Socket:readULong(packetId, defaultValue)
    -- local packet = self.__packets[packetId]
    -- local val = packet:readULong()
    -- if not val then
    --     return defaultValue
    -- end
    -- return val
end


function Socket:readLongLong(packetId, defaultValue)
    local packet = self.__packets[packetId]
    if #packet.data + 1 < packet.position + 8 then
        return defaultValue
    end
    local n
    n, packet.position = string.unpack(self.m_endian .. 'i8', packet.data, packet.position)
    return n
end

function Socket:readULongLong(packetId, defaultValue)
    local packet = self.__packets[packetId]
    if #packet.data + 1 < packet.position + 8 then
        return defaultValue
    end
    local n
    n, packet.position = string.unpack(self.m_endian .. 'I8', packet.data, packet.position)
    return n
end



function Socket:readString(packetId)
    local packet = self.__packets[packetId]
    local len = self:readInt(packetId, 0)
    local str
    
    if len == 0 then
        str, packet.position = "",packet.position
    elseif len == 1 then
         str, packet.position = string.unpack(self.m_endian .. 'c' .. tostring(len), packet.data, packet.position)
    else
        str, packet.position = string.unpack(self.m_endian .. 'c' .. tostring(len-1), packet.data, packet.position)
        assert(string.sub(packet.data, packet.position, packet.position) == '\0', 'not zero terminated.')
        packet.position = packet.position + 1
    end

    return str
end

function Socket:readBinary(packetId)
    
    local len = self:readInt(packetId, 0)
    local str
    local packet = self.__packets[packetId]
    if len == 0 then
        str, packet.position = "",packet.position
    else
        str, packet.position = string.unpack(self.m_endian .. 'c' .. tostring(len), packet.data, packet.position)
    end
    
   
    return str
end

function Socket:readShort(packetId, defaultValue)
    local packet = self.__packets[packetId]
    if #packet.data + 1 < packet.position + 2 then
        return defaultValue
    end
    local n
    n, packet.position = string.unpack(self.m_endian .. 'h', packet.data, packet.position)
    return n
end

function Socket:readUShort(packetId, defaultValue)
    local packet = self.__packets[packetId]
    if #packet.data + 1 < packet.position + 2 then
        return defaultValue
    end
    local n
    n, packet.position = string.unpack(self.m_endian .. 'H', packet.data, packet.position)
    return n
end


function Socket:writeInt(packetId,val)
    local packet = self.__packets[packetId]
    packet:write(string.pack(self.m_endian .. 'i4', val))
end

function Socket:writeUInt(packetId,val)
    local packet = self.__packets[packetId]
    packet:write(string.pack(self.m_endian .. 'I4', val))
end

function Socket:writeInt64(packetId,val)
    local packet = self.__packets[packetId]
    packet:write(string.pack(self.m_endian .. 'i8', val))
end

function Socket:writeByte(packetId,val)
    local packet = self.__packets[packetId]
    packet:write(string.pack(self.m_endian .. 'B', val))
end

function Socket:writeUByte(packetId,val)
     local packet = self.__packets[packetId]
    packet:write(string.pack(self.m_endian .. 'B', val))
end

function Socket:writeShort(packetId,val)
    local packet = self.__packets[packetId]
    packet:write(string.pack(self.m_endian .. 'h', val))
end

function Socket:writeUShort(packetId,val)
    local packet = self.__packets[packetId]
    packet:write(string.pack(self.m_endian .. 'H', val))
end

function Socket:writeString(packetId,val)
     local packet = self.__packets[packetId]
    packet:write(string.pack(self.m_endian .. 'I4s', #val + 1, val))

end

function Socket:writeBinary(packetId,val)
    local packet = self.__packets[packetId]
    self:writeInt(packetId,#val)
    packet:write(string.pack(self.m_endian .. 'c' .. (#val), val))

end

function Socket:writeLong(packetId,val)
    -- local packet = self.__packets[packetId]
    -- packet:write(string.pack(self.m_endian .. 'l', val))
end


function Socket:writeULong(packetId,val)
    -- local packet = self.__packets[packetId]
    -- packet:write(string.pack(self.m_endian .. 'L', val))
end


function Socket:onReceivePacket(packet)
    local packetId = self:_addPacket(packet)
    self:onSocketEvent(Socket.SocketRecvPacket,packetId)
end



return Socket

