if os.clock() < 150 then
	local DragonTimer = 150 - math.floor(os.clock())
	local DragonTimerMinutes = 2 - math.floor(DragonTimer / 60)
	local DragonTimerSeconds = 30 - math.floor((DragonTimer - (DragonTimerMinutes * 60))
end

function OnCreateObj(obj)
	if obj.name == "SRU_Dragon_Death.troy" then
		DragonTimer = 360
	end
end

function OnTick()
	if DragonTimer > 0 then
		DragonTimer = DragonTimer - 1
		DragonTimerMinutes = math.floor(DragonTimer / 60000)
		DragonTimerSeconds = math.floor((DragonTimer - (DragonTimerMinutes * 60000)) / 1000)
		if DragonTimerSeconds < 10 then
			DragonTimerSeconds = "0"..DragonTimerSeconds
		end
	end
end

function OnDraw()
	if DragonTimer = 0 then
		DrawText("LIVE !", 15, 100, 100, ARGB(255,191,255,0))
	else
		DrawText("0"..DragonTimerMinutes..":"..DragonTimerSeconds, 15, 100, 100, ARGB(255,191,255,0))
	end
end