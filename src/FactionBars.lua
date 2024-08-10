FB_SLUG, FB = ...
FB_MSG_ADDONNAME = GetAddOnMetadata( FB_SLUG, "Title" )
FB_MSG_AUTHOR    = GetAddOnMetadata( FB_SLUG, "Author" )
FB_MSG_VERSION   = GetAddOnMetadata( FB_SLUG, "Version" )

FB_repSaved = {}
FB_factionmap = {}

-- FB.barData = {}  -- Move this back internal at some point
FB.lastUpdate = 0
FB.updateInterval = 5 -- update every 5 seconds

FB.timeFrames = {
	["1 minute"]  =     60,
	["2 minutes"] =    180,
	["5 minutes"] =    300,
	["15 minutes"] =   900,
	["half hour"] =   1800,
	["1 hour"]   =    3600,
	["2 hours"]  =    7200,
	["3 hours"]  =   10800,
	["6 hours"]  =   21600,
	["half day"] =   43000,
	["1 day"]    =   86000,
	["2 days"]   =  172000,
	["1 week"]   =  604800,
	["2 weeks"]  = 1209600,
	["3 weeks"]  = 1714400,
	["1 month"]  = 2419200,
	["3 months"] = 7257600,
}
FB.maxTrack = 0

FB.bars = {} -- holds the bars
FB.barHeight = 12
FB.barWidth = 390
FB_barData = {}
FB.patterns = {
	["FACTION_STANDING_DECREASED"] = -1,
	["FACTION_STANDING_INCREASED"] = 1,
	["FACTION_STANDING_DECREASED_ACCOUNT_WIDE"] = -1,
	["FACTION_STANDING_INCREASED_ACCOUNT_WIDE"] = 1
}

function FB.Print( msg, showName )
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = FB_MSG_ADDONNAME.."> "..msg
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg )
end
function FB.OnLoad()
	SLASH_FB1 = "/fb"
	SlashCmdList["FB"] = function(msg) FB.Command(msg); end

	ChatFrame_AddMessageEventFilter( "CHAT_MSG_COMBAT_FACTION_CHANGE", FB.FactionGainEvent )
	-- COMBAT_TEXT_UPDATE( messageType, faction, amount )
	FB.sessionStart = time()
	FB_Frame:RegisterEvent( "VARIABLES_LOADED" )
	-- FB_Frame:RegisterEvent( "UPDATE_FACTION" )  -- any faction gets changed.
	-- UPDATE_FACTION
	for _,ts in pairs( FB.timeFrames ) do
		FB.maxTrack = max( FB.maxTrack, ts )
	end
end
function FB.OnUpdate( arg1 )
	now = time()
	if FB.lastUpdate + FB.updateInterval <= now then
		FB.GenerateBarData()
		FB.UpdateBars()
		FB.lastUpdate = now
	end
end
-- Events
-- function FB.UPDATE_FACTION( ... )
-- 	a, b, c = ...
-- 	FB.Print( "Update_Faction( <table>, "..(b or "nil")..", "..(c or "nil")..")" )
-- 	FB.a = a
-- 	-- if a[0] then
-- 		-- for k, v in pairs( a[0] ) do
-- 			-- FB.Print( "a."..k.."="..v )
-- 		-- end
-- 	-- end
-- end
function FB.VARIABLES_LOADED()
	FB_Frame:UnregisterEvent( "VARIABLES_LOADED" )
	FB.Print( "Loaded version: "..FB_MSG_VERSION )

	FB.AssureBars( FB_options.numBars )
	FB.OptionsPanel_Reset()
	FB.XHFrame()
	FB_Frame:Show()  -- Do this just in case it has bars to show.  It will hide itself if it does not.
end
function FB.XHFrame()
	if XHFrame then
		FB.Print( "Found XH. Setting my location relative to the skillBar" )
		FB_Frame:SetPoint( "TOP", "XH_SkillBar", "BOTTOM",0, -1 )
	end
end
function FB.AssureBars( barsNeeded )
	-- make sure that there are enough bars to handle the need
	local count = #FB.bars
	if ( not InCombatLockdown() and ( barsNeeded > count ) ) then
		FB.Print("I need "..barsNeeded.." bars. I have "..count.." bars.")
		FB.Print( "I need to make "..(barsNeeded-count).." bars." )
		for i = count+1, barsNeeded do
			-- Create a bar
			FB.Print("Creating bar# "..i);
			local newBar = CreateFrame( "StatusBar", "FB_Bar"..i, FB_Frame, "FB_FactionBarTemplate" )
			newBar:SetWidth( FB.barWidth )
			newBar:SetHeight( FB.barHeight )
			newBar:SetFrameStrata( "LOW" )
			newBar:Hide()
			--newBar:SetTexture("Interface\TargetingFrame\UI-StatusBar");
			if (i == 1) then
				newBar:SetPoint( "TOPLEFT", "FB_Frame", "TOPLEFT" )
			else
				newBar:SetPoint( "TOPLEFT", FB.bars[i-1], "BOTTOMLEFT" )
			end
			local text = newBar:CreateFontString( "FB_BarText"..i, "OVERLAY", "FB_FactionBarTextTemplate" )
			newBar.text = text;
			text:SetPoint( "TOPLEFT", newBar, "TOPLEFT", 5, 0 )

			FB.bars[i] = newBar
		end
	end
	return max( count, barsNeeded )
end
function FB.UpdateBars()
	if not InCombatLockdown() then
		-- Create a sorted index table of data from barData, count the table too
		local count = 0
		local sortedKeys = {}
		for fac, val in pairs( FB_barData ) do
			count = count + 1
			sortedKeys[count] = {["fac"]=fac, ["maxTS"]=val.maxTS}
		end
		if( count == 0 ) then
			FB_Frame:Hide()
			-- FB.Print( "Hide Frame" )
			return
		end
		local barCount = FB.AssureBars( count )  -- assure enough bars to show data
		-- sort by maxTS
		table.sort( sortedKeys, function(a,b) return (a.maxTS>b.maxTS or (a.maxTS==b.maxTS and a.fac<b.fac)) end )
		local showBars = min( #sortedKeys, FB_options.numBars )  -- how many bars to show
		FB_Frame:SetHeight( FB.barHeight*showBars )
		for i = 1, showBars do
			local fac = sortedKeys[i].fac
			local val = FB_barData[fac]
			FB.bars[i]:SetMinMaxValues( val.currentReactionThreshold, val.nextReactionThreshold )
			FB.bars[i]:SetValue( val.currentStanding )
			FB.bars[i].text:SetText( val.outStr )
			FB.bars[i]:SetStatusBarColor( val.barColor:GetRGBA() )
			FB.bars[i]:Show()
		end
		for barsHide = showBars+1, barCount do
			if FB.bars[barsHide]:IsShown() then
				FB.Print( "Hiding: "..barsHide )
				FB.bars[barsHide]:Hide()
			end
		end
	end
end
function FB.FactionGainEvent( frame, event, message, ...)
	-- FB.Print( event..":"..message )
	local factionName = nil
	for factionType, valueModifier in pairs( FB.patterns ) do
		if not FB[factionType.."_PATTERN"] then
			FB[factionType.."_PATTERN"] = FB.FormatToPattern(_G[factionType])
		end
		if not factionName then
			_, _, factionName, amount = string.find( message, FB[factionType.."_PATTERN"] )
			if factionName then
				amount = amount * valueModifier
			end
		end
	end
	factionName = (factionName == "Guild" and GetGuildInfo("player") or factionName)
	-- FB.Print( "FactionName: "..(factionName or "nil").." amount:"..(amount or "nil") )
	if factionName then
		FB.FactionGain( factionName, amount )
	else
		FB.Print( "Not able to decode: "..message )
	end
end
-- -- -------------
function FB.GetFactionIDByName( factionNameIn )
	if not FB_factionmap[ factionNameIn ] then
		for factionID = 1, 5000 do
			factionData = C_Reputation.GetFactionDataByID( factionID )
			if factionData and factionData.name == factionNameIn then
				FB_factionmap[factionData.name] = factionID
				FB.Print( "Adding "..factionData.name.." ("..factionID..")" )
			end
		end
	end
	return FB_factionmap[ factionNameIn ]
end
function FB.FactionGain( factionNameIn, repGainIn )
	-- FB.Print( factionNameIn..":"..(repGainIn or 'nil') )
	factionID = FB.GetFactionIDByName( factionNameIn )
	-- print( factionNameIn..":"..factionID  )
	if factionID then
		factionData = C_Reputation.GetFactionDataByID( factionID )

		if factionData then
			local now = time()
			if not FB_repSaved[factionNameIn] then
				FB_repSaved[factionNameIn] = {}
			end
			FB_repSaved[factionNameIn][now] =
					(FB_repSaved[factionNameIn][now] and FB_repSaved[factionNameIn][now] + repGainIn) -- entry exists
					or repGainIn -- entry does not exist
			if FB_options.autoChangeWatched and not factionData.isWatched then
				C_Reputation.SetWatchedFactionByID( factionID )
			end
		end
	end
	FB_Frame:Show()
	FB.lastUpdate = 0
end
-- Converts string.format to a string.find pattern: "%s hits %s for %d." to "(.+) hits (.+) for (%d+)"
-- based on Recap by Gello
function FB.FormatToPattern(formatString)
	local patternString = formatString
	patternString = string.gsub(patternString, "%%%d+%$([diouXxfgbcsq])", "%%%1") -- reordering specifiers (e.g. %2$s) stripped
	patternString = string.gsub(patternString, "([%$%(%)%.%[%]%*%+%-%?%^])", "%%%1") -- convert regex special characters

	patternString = string.gsub(patternString, "%%c", "(.)") -- %c to (.)
	patternString = string.gsub(patternString, "%%s", "(.+)") -- %s to (.+)
	patternString = string.gsub(patternString, "%%[du]", "(%%d+)") -- %d to (%d+)
	patternString = string.gsub(patternString, "%%([gf])", "(%%d+%%.*%%d*)");-- %g or %f to (%d+%.*%d*)

	return patternString
end
-- Output
-- processed data into FB.barData
-- makes sure it is sorted
-- @TODO Make session work better
function FB.GenerateBarData()
	-- print("GenerateBarData")
	local now,allMaxTS = time(),0
	for factionName, history in pairs(FB_repSaved) do
		local session, ratetrack, track, maxTS, minTS = 0, 0, 0, 0, now
		for ts, gain in pairs(history) do
			maxTS = max(maxTS, ts)
			allMaxTS = max(allMaxTS, maxTS)
			if ts ~= 0 and (ts > (now - FB.timeFrames[FB_options.trackPeriod])) then
				minTS = min(minTS, ts)
			end
			session = session + (ts > FB.sessionStart and gain or 0)
			track = track + (ts > (now - FB.timeFrames[FB_options.trackPeriod]) and gain or 0)
			ratetrack = ratetrack + (ts > (now - 1800) and gain or 0)
			if (ts > 0 and (ts < (now - FB.maxTrack))) then
				history[0] =
					(history[0] and history[0] + gain)
					or gain
				history[ts]=nil
			end
		end
		factionID = FB.GetFactionIDByName( factionName )
		if factionID then factionData = C_Reputation.GetFactionDataByID( factionID ) end
		if factionData then
			if track ~= 0 then
				local rate = ratetrack / 1800
				local timeTillNext = (factionData.nextReactionThreshold - factionData.currentStanding) /
									 (( rate > 0) and rate or (track / FB.timeFrames[FB_options.trackPeriod]))
				-- calculate timeTillNext based on 30 minutes, or the range if no data in the last 30 min.
				local reps = math.ceil((factionData.nextReactionThreshold - factionData.currentStanding) / history[maxTS])
				paragonData = C_Reputation.GetFactionParagonInfo( FB.GetFactionIDByName( factionName ) )
				FB_barData[factionName] = {
					["maxTS"] = maxTS,
					["minTS"] = minTS,
					["outStr"] = factionName..
						((FB_options.showStanding or FB_options.showPercent) and " (" or "")..
						(FB_options.showStanding and _G["FACTION_STANDING_LABEL"..factionData.reaction] or "")..
						(FB_options.showPercent and string.format(" %0.2f%%", (factionData.currentStanding / factionData.nextReactionThreshold) * 100) or "")..
						((FB_options.showStanding or FB_options.showPercent) and (")") or "")..
						": "..
						(FB_options.showLastGain and history[maxTS] or "")..
						(FB_options.showRangeGain and (" ("..track..")") or "")..
						(FB_options.showRepTillNext and (" -> "..(factionData.nextReactionThreshold - factionData.currentStanding)) or "")..
						(FB_options.showRepAge and
							(" ("..SecondsToTime(now-maxTS,false,false,1)..")") or "")..
						(FB_options.showTimeTillNext and
							(" in "..SecondsToTime(timeTillNext)) or "")..
						(FB_options.showRepsTillNext and
							(" "..reps.." rep"..(reps~=1 and "s" or "")) or "")..
							"",
					["nextReactionThreshold"] = factionData.nextReactionThreshold,
					["currentReactionThreshold"] = factionData.currentReactionThreshold,
					["currentStanding"] = factionData.currentStanding,
					["reaction"] = factionData.reaction,
					["barColor"] = _G["FACTION_BAR_COLORS"][factionData.reaction],
					["paragonCurrentValue"] = (paragonData and paragonData.currentValue),
					["paragonThreshold"] = (paragonData and paragonData.threshold),
					["paragonRewardQuestID"] = (paragonData and paragonData.rewardQuestID),
					["paragonHasRewardPending"] = (paragonData and paragonData.hasRewardPending),
					["paragonTooLowLevelForParagon"] = (paragonData and paragonData.tooLowLevelForParagon),
				}
			else
				FB_barData[factionName] = nil
			end
		else
			print( "Pruning faction: "..factionName )
			FB_repSaved[factionName] = nil
		end
	end
    --[[
	if FB_options.flexibleTimeWindow then
		FB.Print(allMaxTS..":"..now-FB.timeFrames[FB_options.trackPeriod]);
	end
	]]--
end
function FB.UIReset()
	FB_Frame:ClearAllPoints()
	FB_Frame:SetPoint("TOP")
	FB.XHFrame()
end
function FB.OnDragStart()
	if FB.uiUnlocked then
		FB_Frame:StartMoving()
	end
end
function FB.OnDragStop()
	FB_Frame:StopMovingOrSizing()
end
function FB.PrintStatus()
	FB.GenerateBarData()
	for _, val in pairs(FB_barData) do
		FB.Print(val["outStr"])
	end
end
function FB.PrintHelp()
	FB.Print(FB_MSG_ADDONNAME.." by "..FB_MSG_AUTHOR)
	for cmd, info in pairs(FB.CommandList) do
		FB.Print(string.format("%s %s %s -> %s",
			SLASH_FB1, cmd, info.help[1], info.help[2]))
	end
end
-- Commands
FB.CommandList = {
	["help"] = {
		["func"] = FB.PrintHelp,
		["help"] = {"","Print this help."},
	},
	["rep"] = {
		["func"] = FB.PrintStatus,
		["help"] = {"","Prints Status"},
	},
	["lock"] = {
		["func"] = function() FB.uiUnlocked = not FB.uiUnlocked
				FB.Print( FB.uiUnlocked and "UI unlocked" or "UI locked" )
				FB_Frame:SetMovable(FB.uiUnlocked and true or false)
			end,
		["help"] = {"","Toggle display lock."},
	},
	["uireset"] = {
		["func"] = FB.UIReset,
		["help"] = {"","Reset the position of the UI"}
	},
}
function FB.ParseCmd(msg)
	if msg then
		local a,b,c = strfind(msg, "(%S+)");  --contiguous string of non-space characters
		if a then
			return c, strsub(msg, b+2)
		else
			return ""
		end
	end
end
function FB.Command(msg)
	local cmd, param = FB.ParseCmd(msg)
	cmd = string.lower(cmd)
	local cmdFunc = FB.CommandList[cmd]
	if cmdFunc then
		cmdFunc.func(param)
	else
		Settings.OpenToCategory( FactionBarsOptionsFrame.category:GetID() )
	end
end
