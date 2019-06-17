local EVENT_TAGS = {}

local E = EVENT_TAGS



local index = 0
local function getIndex()
	index = index + 1
	return index
end


E.HALL_LOGOUT_SUCC_EVENT_TAG = getIndex()
E.ENTER_ROOM_WITH_DATA_EVENT_TAG = getIndex()
E.CHENGE_TABLEBG_WITH_ID_EVENT_TAG = getIndex()
E.CHENGE_CARD_FONT_EVENT_TAG = getIndex()


return EVENT_TAGS

