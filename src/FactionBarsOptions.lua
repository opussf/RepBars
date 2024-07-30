FB.defaultOptions = {
	["trackPeriod"] = "1 hour",
	["numBars"] = 5,
	["showStanding"] = true,
}

FB_options = {
	["trackPeriod"] = "1 hour",
	["numBars"] = 5,
	["showStanding"] = true,
}

function FB.OptionsPanel_OnLoad(panel)
	--FB.Print("OptionsPanel_OnLoad")
	panel.name = "FactionBars"
	FactionBarsOptionsFrame_Title:SetText(FB_MSG_ADDONNAME.." "..FB_MSG_VERSION)
	--panel.parent="";
	panel.OnCommit = FB.OptionsPanel_OKAY
--	panel.cancel = FB.OptionsPanel_Cancel
	panel.OnDefault = FB.OptionsPanel_Default
	panel.OnRefresh = FB.OptionsPanel_Refresh

	-- Register Options frame
	local category, layout = Settings.RegisterCanvasLayoutCategory( panel, panel.name )
	panel.category = category
	Settings.RegisterAddOnCategory(category)
end

function FB.OptionsPanel_OKAY()
	-- Data was recorded, clear the temp
	FB.oldValues = nil;
end
function FB.OptionsPanel_Cancel()
	-- reset to temp and update the UI
	if FB.oldValues then
		for key,val in pairs(FB.oldValues) do
			--FB.Print(key..":"..val);
			FB_options[key] = val;
		end
	end
	FB.oldValues = nil;
	FB.OptionsPanel_Reset();	-- Call this once the values are restored to reset the UI
end
function FB.OptionsPanel_Default()
	FB_options = {
		["trackPeriod"] = "1 hour",
		["numBars"] = 5,
		["showStanding"] = true,
	}
end
function FB.OptionsPanel_Refresh()
	-- This gets called, it seems, when the options panel is opened.
	FB.Print("OptionsPanel_Refresh");
end
function FB.OptionsPanel_Reset() -- Called from the ADDON_LOADED event function
	FB.OptionsPanel_NumBarSlider_Init(FactionBarsOptionsFrame_NumBars);
	FB.OptionsPanel_TrackPeriodSlider_Init(FactionBarsOptionsFrame_TrackPeriodSlider);
end
-------
function FB.OptionsPanel_TrackPeriodSlider_OnLoad(self)
	FB.sortedPeriodValues = {};
	for name, val in pairs(FB.timeFrames) do
		table.insert(FB.sortedPeriodValues, {["name"]=name, ["val"]=val});
	end
	table.sort(FB.sortedPeriodValues, function(a,b) return a.val<b.val; end );
	self:SetMinMaxValues(1, #FB.sortedPeriodValues);
	getglobal(self:GetName().."Low"):SetText(FB.sortedPeriodValues[1].name);
	getglobal(self:GetName().."High"):SetText(FB.sortedPeriodValues[#FB.sortedPeriodValues].name);
	getglobal(self:GetName().."Text"):SetText("Show bars for ()");
end
function FB.OptionsPanel_TrackPeriodSlider_Init(self)
	for i=1, #FB.sortedPeriodValues do
		if FB.sortedPeriodValues[i].name == FB_options.trackPeriod then
			--FB.Print("Setting to "..i.." for "..FB_options.trackPeriod);
			self:SetValue(i);
		end
	end
	getglobal(self:GetName().."Text"):SetText("Show bars for ("..FB_options.trackPeriod..")");
end
function FB.OptionsPanel_TrackPeriodSlider_OnValueChanged(self)
	if FB.oldValues then
		FB.oldValues.trackPeriod = FB.oldValues.trackPeriod or FB_options.trackPeriod;
	else
		FB.oldValues={["trackPeriod"]=FB_options.trackPeriod};
	end

	--FB.Print(FB.sortedPeriodValues[self:GetValue()].name or "none");
	FB_options.trackPeriod = FB.sortedPeriodValues[math.floor(self:GetValue())].name or FB_options.trackPeriod;
	getglobal(self:GetName().."Text"):SetText("Show bars for ("..FB_options.trackPeriod..")");
	FB.lastUpdate=0; -- force update
	FB_Frame:Show();
end

------
function FB.OptionsPanel_NumBarSlider_Init(self)
	local maxVal = max(FB_options.numBars+1, 6);
	getglobal(self:GetName().."Text"):SetText("Number of Faction Bars to Show ("..FB_options.numBars..")");
	getglobal(self:GetName().."High"):SetText(maxVal);
	getglobal(self:GetName().."Low"):SetText("1");
	self:SetMinMaxValues(1, maxVal);
	self:SetValue(FB_options.numBars);
end
function FB.OptionsPanel_NumBarSlider_OnValueChanged(self)
	if FB.oldValues then
		FB.oldValues.numBars = FB.oldValues.numBars or FB_options.numBars;
	else
		FB.oldValues={["numBars"]=FB_options.numBars};
	end
	FB_options.numBars = math.floor(self:GetValue());
	getglobal(self:GetName().."Text"):SetText("Number of Faction Bars to Show ("..FB_options.numBars..")");
	local _, maxVal = self:GetMinMaxValues();
	if maxVal == FB_options.numBars then
		self:SetMinMaxValues(1, maxVal+1);
		getglobal(self:GetName().."High"):SetText(maxVal+1);
	end
	FB.lastUpdate=0;
	FB_Frame:Show();
end
------
function FB.OptionsPanel_CheckButton_OnLoad( self, option, text )
	--FB.Print("CheckButton_OnLoad( "..option..", "..text.." ) -> "..(FB_options[option] and "checked" or "nil"));
	getglobal(self:GetName().."Text"):SetText(text);
	self:SetChecked(FB_options[option]);
end
function FB.OptionsPanel_CheckButton_PostClick( self, option )
	if FB.oldValues then
		FB.oldValues[option] = FB.oldValues[option] or FB_options[option];
	else
		FB.oldValues={[option]=FB_options[option]};
	end
	FB_options[option] = self:GetChecked();
	FB.lastUpdate=0;
end
