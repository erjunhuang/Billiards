local AnimManager = class("AnimManager")

function AnimManager:ctor()
	-- body
end


function AnimManager:hideTableTips( ... )
	local scene = self.scene
	local tableTipView = scene.tableTipView
	tableTipView:GetComponent("Image").enabled = false
	local tipTxt = tableTipView.transform:Find("tipTxt")
	tipTxt:GetComponent("Text").text = ""

end


function AnimManager:createNodes( ... )
	-- body
end

function AnimManager:showTableTips(str)
	str = str or ""
	local scene = self.scene
	local tableTipView = scene.tableTipView
	tableTipView:GetComponent("Image").enabled = true
	local tipTxt = tableTipView.transform:Find("tipTxt")
	tipTxt:GetComponent("Text").text = str
	local rt = tableTipView:GetComponent("RectTransform");
    local originPos = rt.localPosition;
    local originColor = tableTipView:GetComponent("Image").color;
    originColor.a = 1
    tableTipView:GetComponent("Image").color = originColor
	local mySequence = _DG.DOTween.Sequence()

	local move1 = rt:DOLocalMoveY(originPos.y + 170, 0.5);
	local move2 = rt:DOLocalMoveY(originPos.y , 0.5);
	mySequence:Append(move1);
	-- print("showTableTips555",str)
	-- mySequence:Join(alpha1);
	-- print("showTableTips666",str)
	mySequence:AppendInterval(2);
	-- print("showTableTips777",str)
	mySequence:Append(move2);
	-- print("showTableTips888",str)
	-- mySequence:Join(alpha2);
	-- print("showTableTips999",str)

	mySequence:OnComplete(function( ... )
		print("mySequence finish")
		-- rt.localPosition = originPos
		-- local originColor = tableTipView:GetComponent("Image").color;
	 --    originColor.a = 0
	    -- tableTipView:GetComponent("Image").color = originColor

	    self:hideTableTips()
	end);
end


function AnimManager:showHitBallTipEffect(hit_color,allLogicBallTb)
	
end


function AnimManager:reset()

end


function AnimManager:dispose( ... )
	-- body
end



return AnimManager