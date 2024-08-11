FB.defaultOptions = {
	["trackPeriod"] = "1 hour",
	["numBars"] = 5,
	["formatString"] = "(%s %p): %l (%t) -> %n (%a) %c",
}

FB_options = {}
function FB.UpdateOptions()
	for k,v in pairs( FB.defaultOptions ) do
		FB_options[k] = ( FB_options[k] == nil and v or FB_options[k] )
	end
end
function FB.OptionsPanel_Reset() -- Called from the ADDON_LOADED event function
	FB.OptionsPanel_Refresh()
end
function FB.OptionsPanel_OKAY()
	-- Data was recorded, clear the temp
	FB.oldValues = nil
end
function FB.OptionsPanel_Cancel()
	-- reset to temp and update the UI
	if FB.oldValues then
		for key,val in pairs(FB.oldValues) do
			--FB.Print(key..":"..val)
			FB_options[key] = val
		end
	end
	FB.oldValues = nil
end
function FB.OptionsPanel_Default()
	FB_options = {}
	for k,v in pairs( FB.defaultOptions ) do
		FB_options[k] = v
	end
end
function FB.OptionsPanel_Refresh()
	-- This gets called, it seems, when the options panel is opened.
	-- FB.Print("OptionsPanel_Refresh")
	FB.OptionsPanel_NumBarSlider_Init(FactionBarsOptionsFrame_NumBars)
	FB.OptionsPanel_TrackPeriodSlider_Init(FactionBarsOptionsFrame_TrackPeriodSlider)
	FactionBarsOptionsFrame_AutoChangeWatchedBox:SetChecked( FB_options["autoChangeWatched"] )
	-- FactionBarsOptionsFrame_FormatStringEditBox:SetText( FB_options["formatString"]
	FB.OptionsPanel_EditBox_OnShow( FactionBarsOptionsFrame_FormatStringEditBox, "formatString" )

	FactionBarsOptionsFrame_ShowStandingBox:SetChecked( FB_options["showStanding"] )
	FactionBarsOptionsFrame_ShowPercentBox:SetChecked( FB_options["showPercent"] )
	FactionBarsOptionsFrame_ShowLastGainBox:SetChecked( FB_options["showLastGain"] )
	FactionBarsOptionsFrame_ShowRangeGainBox:SetChecked( FB_options["showRangeGain"] )
	FactionBarsOptionsFrame_ShowRepTillNextBox:SetChecked( FB_options["showRepTillNext"] )
	FactionBarsOptionsFrame_ShowRepAgeBox:SetChecked( FB_options["showRepAge"] )
	FactionBarsOptionsFrame_ShowTimeTillNextBox:SetChecked( FB_options["showTimeTillNext"] )
	FactionBarsOptionsFrame_ShowRepsTillNextBox:SetChecked( FB_options["autoChangeWatched"] )
end
function FB.OptionsPanel_OnLoad(panel)
	--FB.Print("OptionsPanel_OnLoad")
	panel.name = "FactionBars"
	FactionBarsOptionsFrame_Title:SetText(FB_MSG_ADDONNAME.." v"..FB_MSG_VERSION)
	--panel.parent="";
	panel.cancel = FB.OptionsPanel_Cancel
	panel.OnCommit = FB.OptionsPanel_OKAY
	panel.OnDefault = FB.OptionsPanel_Default
	panel.OnRefresh = FB.OptionsPanel_Refresh

	-- Register Options frame
	local category, layout = Settings.RegisterCanvasLayoutCategory( panel, panel.name )
	panel.category = category
	Settings.RegisterAddOnCategory(category)
	FB.UpdateOptions()
end
-------
function FB.OptionsPanel_TrackPeriodSlider_OnLoad(self)
	FB.sortedPeriodValues = {}
	for name, val in pairs(FB.timeFrames) do
		table.insert(FB.sortedPeriodValues, {["name"]=name, ["val"]=val})
	end
	table.sort(FB.sortedPeriodValues, function(a,b) return a.val<b.val; end )
	self:SetMinMaxValues(1, #FB.sortedPeriodValues)
	getglobal(self:GetName().."Low"):SetText(FB.sortedPeriodValues[1].name)
	getglobal(self:GetName().."High"):SetText(FB.sortedPeriodValues[#FB.sortedPeriodValues].name)
	getglobal(self:GetName().."Text"):SetText("Show bars for ()")
end
function FB.OptionsPanel_TrackPeriodSlider_Init(self)
	for i=1, #FB.sortedPeriodValues do
		if FB.sortedPeriodValues[i].name == FB_options.trackPeriod then
			--FB.Print("Setting to "..i.." for "..FB_options.trackPeriod);
			self:SetValue(i)
		end
	end
	getglobal(self:GetName().."Text"):SetText("Show bars for ("..FB_options.trackPeriod..")")
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
function FB.OptionsPanel_CheckButton_OnShow( self, option, text )
	-- FB.Print("CheckButton_OnShow( "..option..", "..text.." ) -> "..(FB_options[option] and "checked" or "nil"));
	getglobal(self:GetName().."Text"):SetText(text)
end
function FB.OptionsPanel_CheckButton_PostClick( self, option )
	if FB.oldValues then
		FB.oldValues[option] = FB.oldValues[option] or FB_options[option]
	else
		FB.oldValues={[option]=FB_options[option]}
	end
	FB_options[option] = self:GetChecked()
end
function FB.OptionsPanel_EditBox_OnShow( self, option )
	self:SetText( tostring( FB_options[option] ) )
	self:SetCursorPosition(0)
	if self:IsNumeric() then
		self:SetValue(FB_options[option])
	end
end
function FB.OptionsPanel_EditBox_TextChanged( self, option )
	FB_options[option] = (self:IsNumeric() and self:GetNumber() or self:GetText())
	if self:IsNumeric() then
		self:SetValue(FB_options[option])
	end
end
