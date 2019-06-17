IS_RELEASE = false


print("rquire config")
if IS_RELEASE then
    DEBUG = 0
    CF_DEBUG = 0
    CC_SHOW_FPS = false
else
    DEBUG =2
    CF_DEBUG = 5
    CC_SHOW_FPS = false
end