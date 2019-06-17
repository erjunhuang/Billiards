pcall(require,"pack")
local utils = nb.load("utils")

local Packet = class("Packet")

function Packet:ctor(headformat, index_of_size, endian)
    self.headformat = ""
    for i=1,#headformat do
        self.headformat = self.headformat .. (endian .. string.sub(headformat,i,i))
    end
    -- self.headformat = endian .. headformat
    self.headsize = self.HEAD_SIZE
    self.index_of_size = index_of_size
    self.endian = endian
    self.buffer = {}
    self.headvalue = {}


end

function Packet.verifyHeadAndGetBodyLenAndCmd(buf)
    error('verifyHeadAndGetBodyLenAndCmd not implementated')
end

function Packet:readBegin()
    error('readBegin not implementated')
    -- return position, {cmd=, subcmd=,}
end

function Packet:writeBegin(...)
    self.headvalue = {...}

    print("headvalue",table.unpack(self.headvalue))
end

-- update body size
function Packet:preWrite()
    local len = 0
    for _, buf in ipairs(self.buffer) do
        len = len + #buf
    end
    self.headvalue[self.index_of_size] = len
end

function Packet:writeEnd()
    self:preWrite()
    local head = string.pack(self.headformat, table.unpack(self.headvalue))
    local buf = self.buffer
    self.buffer = {}
    table.insert(buf, 1, head)

    local tStr = table.concat(buf)

    -- print("Packet:writeEnd",self:toString(16,nil,tStr))

    return tStr
end


function Packet:write(buf)
     table.insert(self.buffer, buf)
end

function Packet:toString(__radix, __separator,buffer)
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







function Packet:getPack()
    -- print("getPack===")
    -- print(self.__buffer:getPack(),"getPack===")
    -- return self.__buffer:getPack()

end



local Packet_HS = class("Packet_HS",Packet)
Packet_HS.headformat = 'IbbIH'
Packet_HS.HEAD_SIZE = 12

function Packet_HS:ctor(oldVar,netEndian)
    local endian = ">"
    if not netEndian then
        endian = "<"
    end

    Packet_HS.super.ctor(self, Packet_HS.headformat, 1, endian)
end


function Packet_HS.readBegin(endian, packet)

    -- print("Packet_HS.readBegin",endian, #packet.data)
    packet.position = Packet_HS.HEAD_SIZE+1
    packet.data = packet.data

    local pos1,code1 = string.unpack(packet.data,endian .. 'b', 5)
    local pos2,code2 = string.unpack(packet.data, endian .. 'b', 6)
    local pos3,size = string.unpack(packet.data,endian .. 'I', 1)
    local pos4,cmd = string.unpack( packet.data, endian .. 'I',7)
    local pos5,gameid = string.unpack( packet.data, endian .. 'b',12)
    packet.head = {
        size = size,
        flag = (string.char(code1) .. string.char(code2)),
        cmd = cmd,
        gameid = gameid,
    }

    -- print("Packet_HS:readBegin==",len,flag,cmd,gameid)
    return cmd
end

function Packet_HS:preWrite()

    Packet_HS.super.preWrite(self)
    self.headvalue[1] = self.headvalue[1] + self.headsize - 4
    -- encrypt
    -- local buffer, check = encrypt_buffer(self.buffer)
    local buffer = table.concat(self.buffer)
    -- self.headvalue[7] = check
    self.buffer = {buffer}

end



function Packet_HS:writeBegin(cmd)
    Packet_HS.super.writeBegin(self, 0, string.byte('H'), string.byte('S'),cmd, 0)
end


function Packet_HS.verifyHeadAndGetBodyLenAndCmd(buf,endian)
    -- print("verifyHeadAndGetBodyLenAndCmd-buf",#buf)
    -- print("Packet_HS.verifyHeadAndGetBodyLenAndCmd 999",buf:toString(16))
    endian = endian or ">"
    local cmd = -1
    local len = -1
    local _
    local pos1,flag1 = string.unpack(buf,endian .. "b",5)
    local pos2,flag2 = string.unpack(buf,endian .. "b",6)
    if flag1 == string.byte("H") and flag2 == string.byte("S") then
        _,cmd = string.unpack(buf,endian .. "I",7)
        _,len = string.unpack(buf,endian .. "I",1)
        -- print("Packet_HS.verifyHeadAndGetBodyLenAndCmd00",cmd,len)
    end
    len = len - Packet_HS.HEAD_SIZE + 4


    -- print("Packet_HS.verifyHeadAndGetBodyLenAndCmd",cmd,len)

    return cmd,len

end



return {
    HS = Packet_HS
}
