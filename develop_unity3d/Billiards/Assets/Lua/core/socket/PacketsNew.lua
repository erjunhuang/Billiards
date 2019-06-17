local utils = nb.load("utils")
local PacketBase = class("PacketBase")

function PacketBase:ctor(headformat, index_of_size, endian)
    self.headformat = endian .. headformat
    self.headsize = string.packsize(self.headformat)
    self.index_of_size = index_of_size
    self.endian = endian
    self.buffer = {}
    self.headvalue = {}


end

function PacketBase.verifyHeadAndGetBodyLenAndCmd(buf)
    error('verifyHeadAndGetBodyLenAndCmd not implementated')
end

function PacketBase:readBegin()
    error('readBegin not implementated')
    -- return position, {cmd=, subcmd=,}
end

function PacketBase:writeBegin(...)
    self.headvalue = {...}

    -- print("headvalue",table.unpack(self.headvalue))
end

-- update body size
function PacketBase:preWrite()
    local len = 0
    for _, buf in ipairs(self.buffer) do
        len = len + #buf
    end
    self.headvalue[self.index_of_size] = len
end

function PacketBase:writeEnd()
    self:preWrite()
    local head = string.pack(self.headformat, table.unpack(self.headvalue))
    local buf = self.buffer
    self.buffer = {}
    table.insert(buf, 1, head)

    local tStr = table.concat(buf)

    print("Packet:writeEnd",self:toString(16,nil,tStr))
    return tStr
end


function PacketBase:write(buf)
     table.insert(self.buffer, buf)
end

function PacketBase:toString(__radix, __separator,buffer)
    buffer = buffer or self.buffer
    __radix = __radix or 16 

    local tRadix = {[10]="%03u",[8]="%03o",[16]="%02X"}

    __radix = tRadix[__radix] or "%02X"
    __separator = __separator or " "
    local __fmt = __radix..__separator
    local __format = function(__s)
        return string.format(__fmt, string.byte(__s))
    end
    if type(buffer) == "string" then
        return string.gsub(buffer, "(.)", __format)
    end
    local __bytes = {}
    for i=1,#self.buffer do
        __bytes[i] = __format(self.buffer[i])
    end
    return table.concat(__bytes) ,#__bytes
end







function PacketBase:getPack()
    -- print("getPack===")
    -- print(self.__buffer:getPack(),"getPack===")
    -- return self.__buffer:getPack()

end



local Packet_HS_NEW = class("Packet_HS_NEW",PacketBase)
Packet_HS_NEW.headformat = 'I4BBI4'

Packet_HS_NEW.HEAD_SIZE = string.packsize(Packet_HS_NEW.headformat)

function Packet_HS_NEW:ctor(oldVar,netEndian)
    local endian = ">"
    if not netEndian then
        endian = "<"
    end

    Packet_HS_NEW.super.ctor(self, Packet_HS_NEW.headformat, 1, endian)
end


function Packet_HS_NEW.readBegin(endian, packet)

    -- print("Packet_HS_NEW.readBegin",endian, #packet.data)
    packet.position = string.packsize(Packet_HS_NEW.headformat)+1
    packet.data = packet.data
    local flag1 = string.char(string.unpack(endian .. 'B', packet.data, 5))
    local flag2 = string.char(string.unpack(endian .. 'B', packet.data, 6))
    packet.head = {
        size = string.unpack(endian .. 'I4', packet.data, 1),
        flag = (flag1 .. flag2),
        cmd = string.unpack(endian .. 'I4', packet.data, 7),
    }

    -- print("Packet_HS_NEW:readBegin==",len,flag,cmd,gameid)
    return cmd
end

function Packet_HS_NEW:preWrite()

    Packet_HS_NEW.super.preWrite(self)
    self.headvalue[1] = self.headvalue[1] + self.headsize - 4
    -- encrypt
    -- local buffer, check = encrypt_buffer(self.buffer)
    local buffer = table.concat(self.buffer)
    -- self.headvalue[7] = check
    self.buffer = {buffer}

end



function Packet_HS_NEW:writeBegin(cmd)
    -- local uid = (type(game) ~="nil" and type(game.userData) ~= "nil" and game.userData["aUser.mid"]) or 0
    Packet_HS_NEW.super.writeBegin(self, 0, string.byte('H'), string.byte('S'),cmd, 0)
end


function Packet_HS_NEW.verifyHeadAndGetBodyLenAndCmd(buf,endian)
    -- print("verifyHeadAndGetBodyLenAndCmd-buf",#buf)
    -- print("Packet_HS_NEW.verifyHeadAndGetBodyLenAndCmd 999",buf:toString(16))
    endian = endian or ">"
    local cmd = -1
    local len = -1
    local flag1 = string.unpack(endian .. "B",buf,5)
    local flag2 = string.unpack(endian .. "B",buf,6)
    if flag1 == string.byte("H") and flag2 == string.byte("S") then
        cmd = string.unpack(endian .. "I4",buf,7)
        len = string.unpack(endian .. "I4",buf,1)
        -- print("Packet_HS_NEW.verifyHeadAndGetBodyLenAndCmd00",cmd,len)
    end
    len = len - Packet_HS_NEW.HEAD_SIZE + 4


    print("Packet_HS_NEW.verifyHeadAndGetBodyLenAndCmd",cmd,len)

    return cmd,len

end



return {
    HS_NEW = Packet_HS_NEW
}
