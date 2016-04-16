if myHero.charName ~= "MasterYi" then return end
local SmiteRange = 560
local AaRange = 189
local QRange = 600
local DragonTimer = 1200000
local Timer = 0
local timeToSpawn = 0
local DragonSprite = GetSprite("\\DoctorYi\\Dragon.gif") 
local BaronSprite = GetSprite("\\DoctorYi\\Baron.png")

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
  DragonTimerFunction()
end

function DragonTimerFunction()
  if (GetInGameTimer() - Timer) < 360 and (GetInGameTimer() - Timer) >= 0 then 
    if GetInGameTimer() < 360 then
      timeToSpawn = 150 - (GetInGameTimer() - Timer)
    else
      timeToSpawn = 360 - (GetInGameTimer() - Timer)
    end
  end
  if timeToSpawn <= 0 then 
      timeToSpawn = 0
  end
  
  nMins = string.format("%02.f", math.floor(timeToSpawn/60))
  nSecs = string.format("%02.f", math.floor(timeToSpawn - nMins *60))
  
  DragonTimer = nMins..":" ..nSecs
  
  if DragonTimer == "00:00" then
    DragonTimer = "Live !"
  end
end

function OnDraw()
  if Config.DrawSettings.TimerType == 1 then
    DragonSprite:Draw(Config.DrawSettings.TimerX,Config.DrawSettings.TimerY, 255)
    DragonSprite:SetScale(0.4, 0.4)
    DrawText(DragonTimer, 15, Config.DrawSettings.TimerX + 68, Config.DrawSettings.TimerY + 23, ARGB(255,187,255,0))
    
    BaronSprite:Draw(Config.DrawSettings.TimerX, Config.DrawSettings.TimerY + 60, 255)
    BaronSprite:SetScale(0.4, 0.4)
  elseif Config.DrawSettings.TimerType == 2 then
    DragonSprite:Draw(Config.DrawSettings.TimerX, Config.DrawSettings.TimerY, 255)
    DragonSprite:SetScale(0.4, 0.4)
    DrawText(DragonTimer, 15, Config.DrawSettings.TimerX + 68, Config.DrawSettings.TimerY + 23, ARGB(255,187,255,0))
    
    BaronSprite:Draw(Config.DrawSettings.TimerX + 128, Config.DrawSettings.TimerY, 255)
    BaronSprite:SetScale(0.4, 0.4)
  end
end

function OnCreateObj(obj)
  if obj.name == "SRU_Dragon_Death.troy" then
    timeToSpawn = 360
  end
end