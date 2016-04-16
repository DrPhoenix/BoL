if myHero.charName ~= "MasterYi" then return end
local SmiteRange = 560
local SmitePos = nil
local SmiteDamage = 0
local AaRange = 189
local QRange = 600
local abilityLevel = 0
local jungleMinions = minionManager(MINION_JUNGLE, SmiteRange, myHero, MINION_SORT_MINHEALTH_DEC)
local DragonTimer = 1200000
local Timer = 0
local timeToSpawn = 0
local BaronTimer = 1200000 
local DragonSprite = GetSprite("\\DoctorYi\\Dragon.png") 
local BaronSprite = GetSprite("\\DoctorYi\\Baron.png") 

if myHero:GetSpellData(SUMMONER_1).name:lower("summonersmite") then
  SmitePos = SUMMONER_1
elseif myHero:GetSpellData(SUMMONER_2).name:lower("summonersmite") then
  SmitePos = SUMMONER_2
else
  SmitePos = nil
end

function OnLoad()
  AddMenu()
  PrintChat("<font color=\"#6eed00\"><b>[</b></font><font color=\"#a2ed00\"><b>Doctor Yi</b></font><font color=\"#6eed00\"><b>]</b></font> <font color=\"#fce700\">Loaded !</font>")
end

function AddMenu()
  Config = scriptConfig("Doctor Yi", "MasterYi")

  Config:addSubMenu("General Settings", "GeneralSettings")
    Config.GeneralSettings:addParam("comboON", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte(" ")) 
    Config.GeneralSettings:addParam("harassON", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
    Config.GeneralSettings:addParam("laneclearON", "Lane Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
    Config.GeneralSettings:addParam("UseSmite", "Use smite at Dragon, Rift Herald and Baron", SCRIPT_PARAM_ONOFF, true)
  
  Config:addSubMenu("Humanizer", "HumanizerSettings")
    Config.HumanizerSettings:addParam("HumanizerON", "Humanizer", SCRIPT_PARAM_ONOFF, true)
    Config.HumanizerSettings:addParam("HumanizerMinValue", "Min Value", SCRIPT_PARAM_SLICE, 150, 0, 1000, 0)
    Config.HumanizerSettings:addParam("HumanizerMaxValue", "Max Value", SCRIPT_PARAM_SLICE, 300, 0, 1000, 0)
  
  Config:addSubMenu("Combo", "ComboSettings")
    
  Config:addSubMenu("Items", "ItemsSettings")
    Config.ItemsSettings:addParam("SmiteChampON", "Use smite on champion", SCRIPT_PARAM_ONOFF, true)
    Config.ItemsSettings:addParam("YoumuuON", "Use Youmuu", SCRIPT_PARAM_ONOFF, true)
    Config.ItemsSettings:addParam("BotkrON", "Use BOTRK", SCRIPT_PARAM_ONOFF, true)
    Config.ItemsSettings:addParam("TitanicON", "Use Titanic Hydra", SCRIPT_PARAM_ONOFF, true)
  
  Config:addSubMenu("Evade", "EvadeSettings")
    Config.EvadeSettings:addParam("EvadeON", "Dodge dangerous spells with Q or W", SCRIPT_PARAM_ONOFF, true)
  
  Config:addSubMenu("Draw", "DrawSettings")
    Config.DrawSettings:addParam("DrawAaON", "Draw AA range", SCRIPT_PARAM_ONOFF, false)
    Config.DrawSettings:addParam("DrawSmiteON", "Draw Smite range", SCRIPT_PARAM_ONOFF, false)
    Config.DrawSettings:addParam("DrawQON", "Draw Alpha Strike range", SCRIPT_PARAM_ONOFF, false)
  Config.DrawSettings:addParam("SpaceDraw11","____________________________________________", 5, "")
  Config.DrawSettings:addParam("SpaceDraw12","", 5, "")
    Config.DrawSettings:addParam("TimerY", "Vertical Position of the Timer", SCRIPT_PARAM_SLICE, 50, 0, WINDOW_H - 120, 0)
    Config.DrawSettings:addParam("TimerX", "Horizontal Position of the Timer", SCRIPT_PARAM_SLICE, 50, 0, WINDOW_W - 128, 0)
    Config.DrawSettings:addParam("TimerType", "Display in ", SCRIPT_PARAM_LIST, 1, {"column", "row"})
  Config.DrawSettings:addParam("SpaceDraw21","____________________________________________", 5, "")
  Config.DrawSettings:addParam("SpaceDraw22","", 5, "")
    Config.DrawSettings:addParam("DrawQuality", "Quality of the circle", SCRIPT_PARAM_SLICE, 30, 10, 50, 0)
  
  Config:addSubMenu("Miscellaneous", "MiscSettings")
  Config.MiscSettings:addParam("SetSkin", "Select Skin", SCRIPT_PARAM_LIST, 7, {"Assassin", "Chosen", "Ionia", "Samurai Yi", "Headhunter", "Chroma Pack: Gold", "Chroma Pack: Aqua", "Chroma Pack: Crimson", "PROJECT","Classic"})
    Config.MiscSettings:addParam("AutoLevelON", "Auto level spells (Q>E>W)", SCRIPT_PARAM_ONOFF, true)
    Config.MiscSettings:addParam("DanceON", "Dance on kill or assist", SCRIPT_PARAM_ONOFF, true)

  Config:addParam("space2", "", 5, "")
  Config:addParam("signature1", "Let the Doctor carry", 5, "")
  Config:addParam("signature2", "    by DrPhoenix    ", 5, "")
end

function OnTick()
  HumanizerMs()
  AutoLevel()
  BuyStartingItems()
  SetSkin(myHero, Config.MiscSettings.SetSkin)
  DragonTimerFunction()
  
  if Config.GeneralSettings.comboON then
    DelayAction(Combo, 5) 
  end

  jungleMinions:update()
  CheckJungle()
  
  qReady = (myHero:CanUseSpell(_Q) == READY)
end

function BuyStartingItems()
  if GetGameTimer() < 90 then
    if SmitePos == SUMMONER_1 or SmitePos == SUMMONER_2 then
      BuyItem(1041) --Buy Hunter's Machete
      BuyItem(2003) --Buy Health Potion
      BuyItem(2003) --Buy Health Potion
      BuyItem(2003) --Buy Health Potion
      BuyItem(3340) --Buy Ward
    end
  end
end

function HumanizerMs()
  if Config.HumanizerSettings.HumanizerON == true then
    humanizer = math.random(Config.HumanizerSettings.HumanizerMinValue, Config.HumanizerSettings.HumanizerMaxValue)
  else
    humanizer = 0
  end
end

function DragonTimerFunction()
  if((GetInGameTimer() - Timer) < 360 and (GetInGameTimer() - Timer) >= 0) then 
    if(GetInGameTimer() < 360)then
      timeToSpawn = 150 - (GetInGameTimer() - Timer)
    else
      timeToSpawn = 360 - (GetInGameTimer() - Timer)
    end
  end
  if(timeToSpawn <= 0) then 
      timeToSpawn = 0
  end
  
  nMins = string.format("%02.f", math.floor(timeToSpawn/60))
  nSecs = string.format("%02.f", math.floor(timeToSpawn - nMins *60))
  DragonTimer = nMins..":" ..nSecs
  
  PrintChat(DragonTimer)
end

function getSpellSlot(value)
  if value == 1 then
    return SPELL_1
  elseif value == 2 then
    return SPELL_2
  elseif value == 3 then
    return SPELL_3
  elseif value == 4 then
    return SPELL_4
  end
end

function AutoLevel()
  if Config.MiscSettings.AutoLevelON then
    abilitySequence={1,2,3,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2}
    if myHero.level > abilityLevel then
      abilityLevel=abilityLevel+1
      LevelSpell(getSpellSlot(abilitySequence[abilityLevel]))
    end
  end
end

function GetSmiteDamage()
  if myHero.level <= 4 then
    SmiteDamage = 370 + (myHero.level*20)
  end
  if myHero.level > 4 and myHero.level <= 9 then
    SmiteDamage = 330 + (myHero.level*30)
  end
  if myHero.level > 9 and myHero.level <= 14 then
    SmiteDamage = 240 + (myHero.level*40)
  end
  if myHero.level > 14 then
    SmiteDamage = 100 + (myHero.level*50)
  end
  return SmiteDamage
end

function CheckJungle()
  if Config.GeneralSettings.UseSmite then
    for i, jungle in pairs(jungleMinions.objects) do
      if jungle ~= nil then
        SmiteMonster(jungle)
      end
    end
  end   
end

function SmiteMonster(obj)
  local DistanceMonster = GetDistance(obj)
  if myHero:CanUseSpell(SmitePos) == READY and DistanceMonster <= SmiteRange and obj.health <= GetSmiteDamage() then
    if obj.charName == "SRU_Baron" or obj.charName == "SRU_Dragon" or obj.charName == "SRU_RiftHerald" then
      CastSpell(SmitePos, obj)
    end
  end
end

function Combo()
  
end

function OnDraw()
  if Config.DrawSettings.DrawSmiteON and myHero:CanUseSpell(SmitePos) == READY then
    DrawCircle3D(myHero.x, myHero.y, myHero.z, SmiteRange, 1, RGB(255,130,0), Config.DrawSettings.DrawQuality)
  end
  if Config.DrawSettings.DrawQON and myHero:CanUseSpell(_Q) == READY then
    DrawCircle3D(myHero.x, myHero.y, myHero.z, QRange, 1, RGB(178,255,0), Config.DrawSettings.DrawQuality)
  end
  if Config.DrawSettings.DrawAaON and not myHero.dead then
    DrawCircle3D(myHero.x, myHero.y, myHero.z, AaRange, 1, RGB(255,100,100), Config.DrawSettings.DrawQuality)
  end
  if Config.DrawSettings.TimerType == 1 then
    DragonSprite:Draw(Config.DrawSettings.TimerX,Config.DrawSettings.TimerY, 255)
    DragonSprite:SetScale(0.4, 0.4)
    DrawText(DragonTimer, 15, Config.DrawSettings.TimerX + 198, Config.DrawSettings.TimerY + 23, ARGB(255,255,255,255))
    
    BaronSprite:Draw(Config.DrawSettings.TimerX, Config.DrawSettings.TimerY + 60, 255)
    BaronSprite:SetScale(0.4, 0.4)
  elseif Config.DrawSettings.TimerType == 2 then
    DragonSprite:Draw(Config.DrawSettings.TimerX,Config.DrawSettings.TimerY, 255)
    DragonSprite:SetScale(0.4, 0.4)
    
    BaronSprite:Draw(Config.DrawSettings.TimerX + 128, Config.DrawSettings.TimerY, 255)
    BaronSprite:SetScale(0.4, 0.4)
  end
end

function OnCreateObj(obj)
  if obj.name == "SRU_Dragon_Death.troy" then
    DragonTimer = 360
  end
end

function OnAnimation(unit, animation)
    if unit == enemy and animation:lower():find("death") and MiscSettings.DanceON then
      SendChat("/dance")
    end
end

function OnWndMsg(msg,key)
end

function OnSendChat(txt)
end

function OnProcessSpell(unit,spell)
  if unit == target and qReady and Config.Keys.comboON and GetDistance(myHero, spell.endPos) > GetDistance(myHero, spell.startPos) and GetDistance(myHero, spell.endPos) > myTrueRange then
    if spell.name == "EzrealArcaneShift" or spell.name == "KatarinaE" then
      Cast(_Q, target, QRange)
    end
  elseif unit == myHero and spell.name == "WujuStyle" then
    Eactive = true
    DelayAction(function() Eactive = false end, 5)
  elseif Config.EvadeSettings.EvadeON then
    
  end
end

function Evade(delay1, delay2, usew)
  DelayAction(function() 
    minions:update()
    jungleminions:update()
    if qReady then
      if target ~= nil and GetDistance(myHero, target) <= QRange then
        if Config.Keys.autocarryON then
          Cast(_Q, target, QRange)
        elseif #minions.objects > 0 then
          Cast(_Q, minions.objects[1], QRange)
        else
          Cast(_Q, target, QRange)
        end
      elseif #minions.objects > 0 then
        Cast(_Q, minions.objects[1], QRange)
      elseif #jungleminions.objects > 0 then
        Cast(_Q, jungleminions.objects[1], QRange)      
      elseif wReady and usew then
        DelayAction(function() CastSpell(_W) end, delay2)
      end
    elseif wReady and usew then
      DelayAction(function() CastSpell(_W) end, delay2)
    end
  end, delay1)
end