local pb = require "pb" -- 载入 pb.dll

assert(pb.loadfile "testluaprotobuf.pb") -- 载入刚才编译的pb文件

local person = { -- 我们定义一个addressbook里的 Person 消息
   name = "Alice",
   id = 12345,
   phone = {
      { number = "1301234567" },
      { number = "87654321", type = "WORK" },
   }
}

-- 序列化成二进制数据
local data = assert(pb.encode("testluaprotobuf.Person", person))

-- 从二进制数据解析出实际消息
local msg = assert(pb.decode("testluaprotobuf.Person", data))

-- 打印消息内容（使用了serpent开源库）
print(require "serpent.serpent".block(msg))