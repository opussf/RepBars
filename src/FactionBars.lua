FB_MSG_VERSION = GetAddOnMetadata("FactionBars","Version");
FB_MSG_ADDONNAME	= "FactionBars";
FB_MSG_AUTHOR 		= "Opussf";

--[[
FACTION_BAR_COLORS = {
	[1] = {r = 1.0, g = 0, b = 0},                  -- 36000 Hated - Red
	[2] = {r = 1.0, g = 0.5019608, b = 0},          -- 3000 Hostile - Orange
	[3] = {r = 1.0, g = 0.8196079, b = 0},          -- 3000 Unfriendly - Yellow
	[4] = {r = 0.8, g = 0.9, b = 0.8},              -- 3000 Neutral - Grey
	[5] = {r = 1.0, g = 1.0, b = 1.0},              -- 6000 Friendly - White
	[6] = {r = 0, g = 0.6, b = 0.1},                -- 12000 Honored - Green
	[7] = {r = 0, g = 0, b = 1.0},                  -- 21000 Revered - Blue
	[8] = {r = 0.5803922, g = 0, b = 0.827451},     -- 1000 Exalted - Purple
};
]]--

FACTION_BAR_COLORS[7] = {r = 0, g = 0, b = 1.0};                -- 21000 Revered - Blue
FACTION_BAR_COLORS[8] = {r = 0.5803922, g = 0, b = 0.827451};   -- 1000 Exalted - Purple

FB_repSaved = {};

FB = {};
FB.barData = {};
FB.lastUpdate = 0;
FB.updateInterval = 5;

FB.timeFrames = {
	["session"]  =       0,
	["5 minutes"] =    300,
	["15 minutes"] =   900,
	["half hour"] =   1800,
	["1 hour"]   =    3600,
	["2 hours"]  =    7200,
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
FB.maxTrack = 0;

FB.bars = {};
FB.barHeight = 12;
FB.barWidth = 390;

function FB.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = FB_MSG_ADDONNAME.."> "..msg;
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg );
end
function FB.OnLoad()
	SLASH_FB1 = "/fb";
	SlashCmdList["FB"] = function(msg) FB.Command(msg); end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", FB.FactionGainEvent);
	FB.sessionStart = time();
	FB_Frame:RegisterEvent("ADDON_LOADED");
end
function FB.ADDON_LOADED()
	local genderStrings = {"","","_FEMALE"};
	FB.genderString = genderStrings[(UnitSex("player") or 0)];
	FB_Frame:UnregisterEvent("ADDON_LOADED");
	if XHFrame then
		FB.Print("Found XH.  Setting my location relative to the skillBar");
		FB_Frame:SetPoint("TOP", "XH_SkillBar", "BOTTOM",0, -1);
	end
	for _,ts in pairs(FB.timeFrames) do
		FB.maxTrack = max( FB.maxTrack, ts );
	end
	FB.OptionsPanel_Reset();
	FB.Print("Loaded version: "..FB_MSG_VERSION)
	FB_Frame:Show();  -- Do this just in case it has bars to show.  It will hide itself if it does not.
end
--[[
function FB.OnUpdate(arg1)
	local now = time();
	if FB.lastUpdate + FB.updateInterval <= now then
		FB.GenerateBarData();
		FB.UpdateBars();
		--FB.Print("arg1: "..(arg1 or "nil").."::"..now.." tracking "..count.." factions. "..FB_Frame:GetHeight());
		FB.lastUpdate = now;
	end
end

function FB.AssureBars( barsNeeded )
	-- make sure that there are enough bars to handle the need
	local count = 0;
	for b in pairs(FB.bars) do
		count = count + 1;
	end
	--FB.Print("I need "..barsNeeded.." bars. I have "..count.." bars.");
	if (barsNeeded ~= count ) then
		for i = count+1, barsNeeded do
			-- Create a bar
			--FB.Print("Creating bar# "..i);
			local newBar = CreateFrame("StatusBar", "FB_Bar"..i, FB_Frame, "FB_FactionBarTemplate");
			newBar:SetWidth(FB.barWidth);
			newBar:SetHeight(FB.barHeight);
			--newBar:SetTexture("Interface\TargetingFrame\UI-StatusBar");
			if (i == 1) then
				newBar:SetPoint("TOPLEFT","FB_Frame","TOPLEFT");
			else
				newBar:SetPoint("TOPLEFT",FB.bars[i-1], "BOTTOMLEFT");
			end
			local text = newBar:CreateFontString("FB_BarText"..i, "OVERLAY", "FB_FactionBarTextTemplate");
			newBar.text = text;
			text:SetPoint("TOPLEFT", newBar, "TOPLEFT", 5, 0);

			FB.bars[i] = newBar;
		end
	end
	return max(count, barsNeeded);
end

function FB.UpdateBars()
	-- Create a sorted index table of data from barData, count the table too
	local count = 0;
	local sortedKeys = {};
	for fac, val in pairs(FB.barData) do
		table.insert(sortedKeys, {["fac"]=fac, ["maxTS"]=val.maxTS});
		count = count + 1;
	end
	if (count == 0) then
		FB_Frame:Hide();
		--FB.Print("Hide Frame");
		return;
	end
	local barCount = FB.AssureBars( count );
	-- the key to sort on is the maxTS
	table.sort(sortedKeys, function(a,b) return (a.maxTS>b.maxTS or (a.maxTS==b.maxTS and a.fac<b.fac)); end);
	local showBars = min(#sortedKeys, FB_options.numBars);
	FB_Frame:SetHeight(FB.barHeight*showBars);

	for i = 1, showBars do
		local fac = sortedKeys[i].fac;

		local val = FB.barData[fac];
		FB.bars[i]:SetMinMaxValues(0, val["barTopValue"]);
		FB.bars[i]:SetValue(val["barEarnedValue"]);
		FB.bars[i].text:SetText(val["outStr"]);
		FB.bars[i]:SetStatusBarColor(val["barColor"]["r"],
				val["barColor"]["g"], val["barColor"]["b"]);
		FB.bars[i]:SetFrameStrata("LOW");
		FB.bars[i]:Show();
	end
	for barsHide = showBars+1, barCount do
		--FB.Print("Hiding: "..barsHide);
		FB.bars[barsHide]:Hide();
	end

end

function FB.FactionGainEvent( frame, event, message, ...)
	--FB.Print( event..":"..message )
	if (not FB.FACTION_STANDING_DECREASED_PATTERN) then
		FB.FACTION_STANDING_DECREASED_PATTERN = FB.FormatToPattern(FACTION_STANDING_DECREASED);
	end
	local _, _, factionName, amount = string.find(message, FB.FACTION_STANDING_DECREASED_PATTERN);
	if (factionName) then
		amount = -amount;
	else
		if (not FB.FACTION_STANDING_INCREASED_PATTERN) then
			FB.FACTION_STANDING_INCREASED_PATTERN = FB.FormatToPattern(FACTION_STANDING_INCREASED);
		end
		_, _, factionName, amount = string.find(message, FB.FACTION_STANDING_INCREASED_PATTERN);
		amount = tonumber(amount);
	end
	factionName = (factionName == "Guild" and GetGuildInfo("player") or factionName);
	FB.FactionGain( factionName, amount );
end
-- return a list of faction info
function FB.GetFactionInfo( factionNameIn )
	for factionIndex = 1, GetNumFactions() do
		local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
				canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex);
		if isCollapsed then
			ExpandFactionHeader(factionIndex);
			return nil;
		end
		local barBottomValue = 0;
		local barTopValue = topValue - bottomValue;
		local barEarnedValue = earnedValue - bottomValue;
		local standingStr = _G["FACTION_STANDING_LABEL"..standingId..FB.genderString];
		if name == factionNameIn then
			--FB.Print(name..":"..bottomValue.."<"..earnedValue.."<"..topValue);
			return name, description, standingStr, barBottomValue, barTopValue, barEarnedValue, atWarWith,
					canToggleAtWar, isHeader, isCollapsed, isWatched, factionIndex, FACTION_BAR_COLORS[standingId] ;
		end
	end
	if not name then
		FB.Print("No faction found that matches: "..factionNameIn..". Pruning.");
		FB_repSaved[factionNameIn]=nil;
	end
end
function FB.FactionGain( factionNameIn, repGainIn )
	--XH.GetFactionInfo( factionNameIn );
	local name, description, standingStr, barBottomValue, barTopValue, barEarnedValue, atWarWith,
			canToggleAtWar, isHeader, isCollapsed, isWatched, factionIndex = FB.GetFactionInfo( factionNameIn );
	if name then
		local now = time();
		if (not FB_repSaved[factionNameIn]) then
			FB_repSaved[factionNameIn] = {};
		end
		FB_repSaved[factionNameIn][now] =
				(FB_repSaved[factionNameIn][now] and FB_repSaved[factionNameIn][now] + repGainIn) -- entry exists
				or repGainIn; -- entry does not exist
		if FB_options.autoChangeWatched and not isWatched then
			SetWatchedFactionIndex(factionIndex);
		end
	end
	FB.lastUpdate=0; -- force update
	FB_Frame:Show();
end

-- Converts string.format to a string.find pattern: "%s hits %s for %d." to "(.+) hits (.+) for (%d+)"
-- based on Recap by Gello
function FB.FormatToPattern(formatString)

	local patternString = formatString;

	patternString = string.gsub(patternString, "%%%d+%$([diouXxfgbcsq])", "%%%1"); -- reordering specifiers (e.g. %2$s) stripped
	patternString = string.gsub(patternString, "([%$%(%)%.%[%]%*%+%-%?%^])", "%%%1"); -- convert regex special characters

	patternString = string.gsub(patternString, "%%c", "(.)"); -- %c to (.)
	patternString = string.gsub(patternString, "%%s", "(.+)"); -- %s to (.+)
	patternString = string.gsub(patternString, "%%[du]", "(%%d+)"); -- %d to (%d+)
	patternString = string.gsub(patternString, "%%([gf])", "(%%d+%%.*%%d*)"); -- %g or %f to (%d+%.*%d*)

	return patternString;
end

-- Output
-- processed data into FB.barData
-- makes sure it is sorted
-- @TODO Make session work better
function FB.GenerateBarData()
	local now,allMaxTS = time(),0;
	for faction, history in pairs(FB_repSaved) do
		local session, ratetrack, track, maxTS, minTS = 0, 0, 0, 0, now;
		for ts, gain in pairs(history) do
			maxTS = max(maxTS, ts);
			allMaxTS = max(allMaxTS, maxTS);
			if ts ~= 0 and (ts > (now - FB.timeFrames[FB_options.trackPeriod])) then
				minTS = min(minTS, ts);
			end
			session = session + (ts > FB.sessionStart and gain or 0);
			track = track + (ts > (now - FB.timeFrames[FB_options.trackPeriod]) and gain or 0)
			ratetrack = ratetrack + (ts > (now - 1800) and gain or 0)
			if (ts > 0 and (ts < (now - FB.maxTrack))) then
				history[0] =
					(history[0] and history[0] + gain)
					or gain;
				history[ts]=nil;
			end
		end
		local name, _, standing, _, barTopValue, barEarnedValue, _, _, _, _, _, _, barColor = FB.GetFactionInfo( faction );
		if name then

			if FB_options.trackPeriod == "session" then track=session; end

			if track ~= 0 then
				--local rate = track / FB.timeFrames[FB_options.trackPeriod];
				local rate = ratetrack / 1800; -- hardcode to 30 minutes
				local timeTillNext = (barTopValue - barEarnedValue) / ((rate > 0) and rate or (track / FB.timeFrames[FB_options.trackPeriod]))
				-- calculate timeTillNext based on 30 minutes, or the range if no data in the last 30 min.
				local reps = math.ceil((barTopValue - barEarnedValue) / history[maxTS]);
		--FB.Print(faction..":"..now-minTS..":"..FB.timeFrames[FB_options.trackPeriod]..":"..SecondsToTime(timeTillNext));
				FB.barData[faction] = {
					["maxTS"] = maxTS,
					["minTS"] = minTS,
					["outStr"] = faction..
						((FB_options.showStanding or FB_options.showPercent) and " (" or "")..
						(FB_options.showStanding and standing or "")..
						(FB_options.showPercent and string.format(" %0.2f%%", (barEarnedValue / barTopValue) * 100) or "")..
						((FB_options.showStanding or FB_options.showPercent) and (")") or "")..
						": "..
						(FB_options.showLastGain and history[maxTS] or "")..
						(FB_options.showRangeGain and (" ("..track..")") or "")..
						(FB_options.showRepTillNext and (" -> "..(barTopValue - barEarnedValue)) or "")..
						(FB_options.showRepAge and
							(" ("..SecondsToTime(now-maxTS,false,false,1)..")") or "")..
						(FB_options.showTimeTillNext and
							(" in "..SecondsToTime(timeTillNext)) or "")..
						(FB_options.showRepsTillNext and
							(" "..reps.." rep"..(reps~=1 and "s" or "")) or "")..
							"",
					["barTopValue"] = barTopValue,
					["barEarnedValue"] = barEarnedValue,
					["barColor"] = barColor,
				};
			else
				FB.barData[faction] = nil;
			end
		end
	end
end

function FB.PrintStatus()
	FB.GenerateBarData();
	for _, val in pairs(FB.barData) do
		FB.Print(val["outStr"]);
	end
end
]]
function FB.PrintHelp()
	FB.Print(FB_MSG_ADDONNAME.." by "..FB_MSG_AUTHOR);
	for cmd, info in pairs(FB.CommandList) do
		FB.Print(string.format("%s %s %s -> %s",
			SLASH_FB1, cmd, info.help[1], info.help[2]));
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
}
function FB.ParseCmd(msg)
	if msg then
		local a,b,c = strfind(msg, "(%S+)");  --contiguous string of non-space characters
		if a then
			return c, strsub(msg, b+2);
		else
			return "";
		end
	end
end
function FB.Command(msg)
	local cmd, param = FB.ParseCmd(msg);
	cmd = string.lower(cmd);
	local cmdFunc = FB.CommandList[cmd];
	if cmdFunc then
		cmdFunc.func(param);
	else
		InterfaceOptionsFrame_OpenToCategory(FB_MSG_ADDONNAME);
	end
end
