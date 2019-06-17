--[[
    解包
]]

local Packets = import(".PacketsNew")
local PacketParser = class("PacketParserNew")
function PacketParser:ctor(socket,socketName)
    self.__socket = socket
    self.__logger = core.Logger.new(socketName .. ".PacketParser"):enabled(true)
    self.__buf = ""
end

function PacketParser:reset()
    self.__buf = ""
end

function PacketParser:setProtocol(protocol,endian)
    self.__protocol = protocol
    self.__endian = endian
    self.__headSize = Packets[self.__protocol].HEAD_SIZE
end

--[[
    校验包头，并返回包体长度与命令字, 校验不通过则都返回-1
]]
function PacketParser:verifyHeadAndGetBodyLenAndCmd(buf)
    local packet = Packets[self.__protocol]
    local cmd = -1
    local len = -1
    cmd,len = packet.verifyHeadAndGetBodyLenAndCmd(buf,self.__endian)

    print("PacketParser:verifyHeadAndGetBodyLenAndCmd",cmd,len)
    return cmd, len
end

function PacketParser:read(buf)


    self.__buf = self.__buf .. buf

    local ret = {}
    local success = true
    while true do
        local available = #self.__buf
        local buffLen = #self.__buf
        if available <= 0 then
            break
        else
            local headCompleted = (buffLen >= self.__headSize)
            --先收包头
            if not headCompleted then
                    break
            end
            if headCompleted then
                --包头已经完整，取包体长度并校验包头
                local command, bodyLen = self:verifyHeadAndGetBodyLenAndCmd(self.__buf)
                self.__logger:debugf("command %x bodylen %d", command, bodyLen)

                if bodyLen == 0 then
                    --无包体，直接返回一个只有cmd字段的table，并重置缓冲区
                    -- ret[#ret + 1] = { cmd = command }
                    local packet = string.sub(self.__buf,1,self.__headSize)
                    self.__buf = string.sub(self.__buf,self.__headSize+1)

                    -- self.__logger:debugf("packet buf,%s  %s",self:toString(16,nil,packet))

                    self.__socket:onReceivePacket(packet)
                    -- self:reset()
                elseif bodyLen > 0 then
                    --有包体
                    if available <= 0 then
                        break
                    elseif available >= self.__headSize + bodyLen then
                        -- 收到完整包，向缓冲区补齐当前包剩余字节
                        local packet = string.sub(self.__buf,1,self.__headSize + bodyLen)
                        self.__buf = string.sub(self.__buf,self.__headSize + bodyLen+1)
                        -- 开始解析

                        -- self.__logger:debugf("packet buf,%s  %s",self:toString(16,nil,packet))

                        self.__socket:onReceivePacket(packet)
                        --重置缓冲区
                        -- self:reset()
                    else
                        --不够包体长度，继续等待
                        break
                    end
                else
                    -- 包头校验失败
                    self:reset()
                    return false, "PKG HEAD VERIFY ERROR" --.. self:toString(16,nil,self.__buf)
                end
            end
        end
    end
    return true, ret
end




function PacketParser:toString(__radix, __separator,buffer)
    buffer = buffer or self.__buf
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
        __bytes[i] = __format(self.__buf[i])
    end
    return table.concat(__bytes) ,#__bytes
end


return PacketParser