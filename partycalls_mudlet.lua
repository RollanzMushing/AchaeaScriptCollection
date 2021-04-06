--Courtesy of Nyesta and PhoenixCodes(Lynara)
--Add new patterns for target calls to this table

--Security update and subgroup functionality by Rollanz

local CallingPatterns = {
[[Target changed to:? ([\w\d\'\- ]+)]],
[[Target:? ([\w\d\'\- ]+)]],
[[Changed target to:? ([\w\d\'\- ]+)]],
[[Targetting:? ([\w\d\'\- ]+)]],
}

--No need to edit below

warbandLeaders = warbandLeaders or {}

function getraidleader()
  local Text = gmcp.Comm.Channel.Text 
  if Text.channel == "party" and string.find(Text.text, [[I am calling targets, focus your fire on my command.]]) then 
    -- if ndb.iseleusian(Text.talker) then
    if not multileader then
      raidleader = Text.talker
    else
      if type(raidleader) ~= "table" then
        raidleader = {}
      end
      raidleader[Text.talker] = true
    end
    tempTimer(0, function()
      cecho("\n<ansiRed>Raidleader: "..Text.talker)
    end)
  elseif Text.channel == "party" and string.find(Text.text, [[Warband (%d), follow my calls.]]) then
    local _, _, warband = string.find(Text.text, [[Warband (%d), follow my calls.]])
    warband = tonumber(warband)
    if type(warband) == "number" then
      warbandLeaders[warband] = Text.talker
      tempTimer(0, function()
        cecho(string.format("\n<ansiRed>Leader for warband %d is: %s", warband, Text.talker))
      end)
    end
  elseif Text.channel == "party" and string.find(Text.text, [[I am no longer call in targets.]]) then
    if type(raidleader) == "string" and raidleader == Text.talker then
      raidleader = nil
    elseif type(raidleader) == "table" then
      raidleader[Text.talker] = false
    end
    for k,v in pairs(warbandLeaders) do
      if v == Text.talker then
        warbandLeaders[k] = nil
      end
    end
  end
end
 
function changetarget()
  local Text = gmcp.Comm.Channel.Text
  --display(Text)
  if not (Text and Text.channel == "party") then
    return
  end
  if string.find(Text.text:lower(), "target") then
     
    local match = false
    local matchTable = {rex.match(gmcp.Comm.Channel.Text.text,[["(?:]] .. table.concat(CallingPatterns,"|") ..[[)\."]])}
    for k,v in pairs(matchTable) do if v then match = v end end
    
    if match then  
      --print("text.Talker is "..Text.talker)
      --print("match is "..match)
      if Text.talker == "You" and match:title() ~= target then
        send(string.format("pt target changed to %s", target))
      elseif ndb and ndb.iseleusian(match:title()) and not IFF_override then
        cecho("\n<black:red>!!---FRIENDLY TARGET CALLED--!!")
      else
        if not myWarband or myWarband == 0 or not warbandLeaders[myWarband] then
          if not (type(raidleader) == "string" and Text.talker == raidleader) or (type(raidleader) == "table" and raidleader[Text.talker]) then
            return 
          end
        else
          if Text.talker ~= warbandLeaders[myWarband] then
            return
          end
        end
        target = match:title()
        tempTimer(0, [[cecho("\n<ansiRed>Changed target to "..target)]])
      end
    end
  elseif Text.channel == "party" and string.find(Text.text, [[says, "Cat."]]) and (not ndb or ndb.iseleusian(Text.talker)) then
    allyTarget = Text.talker
    tempTimer(0, function() cecho("\n<ansiLightGreen>Ally target: "..allyTarget) end)
  end 
end
 
if not raidLeaderHandler then 
  raidLeaderHandler = registerAnonymousEventHandler("gmcp.Comm.Channel.Text", "getraidleader")
end
if not raidTargetHandler then
  raidTargetHandler = registerAnonymousEventHandler("gmcp.Comm.Channel.Text", "changetarget")
end
if not RaidTargetLoginTrigger then
  RaidTargetLoginTrigger = tempExactMatchTrigger("Password correct. Welcome to Achaea.",
    [=[ sendGMCP([[Core.Supports.Add ["Comm.Channel 1"] ]]) ]=])
end
