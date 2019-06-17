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

function AnimManager:showTableTips(str)
	str = str or ""
	local scene = self.scene

	-- print("AnimManager:showTableTips0000",scene,str)

	local tableTipView = scene.tableTipView
	-- print(tableTipView.gameObject,"showTableTips666")
	-- print("AnimManager:showTableTips1111",scene,str)

	tableTipView:GetComponent("Image").enabled = true

	-- local graphic = tableTipView.graphic
	-- local c = graphic.color;
	-- c.a = 0;
	-- graphic.color = c;

	-- print("AnimManager:showTableTips3333",scene,str)

	local tipTxt = tableTipView.transform:Find("tipTxt")
	-- print("AnimManager:showTableTips444444",tipTxt,str)
	tipTxt:GetComponent("Text").text = str
	-- print("AnimManager:showTableTips55555",scene,str)

	local rt = tableTipView:GetComponent("RectTransform");
	-- print("AnimManager:showTableTips666666",scene,str,rt)
    local originPos = rt.localPosition;

    -- print("AnimManager:showTableTips777777",scene,str)
    local originColor = tableTipView:GetComponent("Image").color;
    originColor.a = 1
    tableTipView:GetComponent("Image").color = originColor

    -- print("AnimManager:showTableTips777777-originColor",originColor)

    -- print("AnimManager:showTableTips888888",scene,str)

	local mySequence = _DG.DOTween.Sequence()

	-- print("showTableTips-1-1-1",str,mySequence)

	-- print("showTableTips000000",originPos.y)
	local move1 = rt:DOLocalMoveY(originPos.y + 170, 0.5);
	-- print("showTableTips111",str)
	local move2 = rt:DOLocalMoveY(originPos.y , 0.5);
	-- print("showTableTips222",str)
	-- Tweener alpha1 = DOTween.To(() => text.color, x => text.color = x, new Color(text.color.r, text.color.g, text.color.b, 1), 1f);
 --    Tweener alpha2 = DOTween.To(() => text.color, x => text.color = x, new Color(text.color.r, text.color.g, text.color.b, 0), 1f);
 -- print([[tableTipView:GetComponent("Image"):DOColor]],tableTipView:GetComponent("Image").DOColor)
    -- dump(tableTipView:GetComponent("Image"),"showTableTips222-2-2-2-")
	-- local alpha1 = tableTipView:GetComponent("Image").DOColor(1, 0.5);
	-- print("showTableTips333",str)
	-- local alpha2 = tableTipView:GetComponent("Image"):DOFade(0, 0.5);
	-- print("showTableTips444",str,mySequence)
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


function AnimManager:reset()



end


function AnimManager:dispose( ... )
	-- body
end



return AnimManager