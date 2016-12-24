function GrowlManager_OnLoad(self)
	self:RegisterEvent("GROUP_ROSTER_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED"); --Remove if Erica doesn't like the alert when entering combat
	self:RegisterEvent("ADDON_LOADED");
	SlashCmdList["GM"] = GM_Command;
    SLASH_GM1 = "/gm";
    SLASH_GM2 = "/growlmanager";
	GrowlManager_Override = false;
end

function GrowlManager_setup()	
	if (GrowlManager_IsGrowlableClass() == 0) then
		print("This class has no Growl like features.");
		GrowlManager_Dungeon = false;
		GrowlManager_Overworld = false;
		GrowlManager_pvp = false;
		print("GrowlManager is now disabled on this character");
	else
		print("You are currently playing on a Hunter or Warlock.");
		print("This character has no GrowlManager config!");
		GrowlManager_Dungeon = true;
		GrowlManager_Overworld = false;
		GrowlManager_pvp = false;
		print("GrowlManager has setup default config.");
	end
	GrowlManager_hasRun = true;
end
	
function GM_Command(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$"); --Clears all whitespace, places usable string into rest
	if (command == "disable") then 
		if (rest == "") then
			GrowlManager_Dungeon = false;
			GrowlManager_Overworld = false;
			GrowlManager_pvp = false;
			print("GrowlManager is now disabled");
		elseif rest == "dungeon" then
			GrowlManager_Dungeon = false;
			print("GrowlManager is now disabled in dungeons");
		elseif rest == "overworld" then
			GrowlManager_Overworld = false;
			print("GrowlManager is now disabled in the overworld");
		elseif rest == "pvp" then
			GrowlManager_pvp = false;
			print("GrowlManager is now disabled in pvp instances");
		else
			GrowlManager_ShowHelp();
		end
	elseif command == "enable" then
		if rest == "" then
			GrowlManager_Dungeon = true;
			GrowlManager_Overworld = true;
			GrowlManager_pvp = true;
			print("GrowlManager is now enabled");
		elseif rest == "dungeon" then
			GrowlManager_Dungeon = true;
			print("GrowlManager is now enabled in dungeons");
		elseif rest == "overworld" then
			GrowlManager_Overworld = true;
			print("GrowlManager is now enabled in the overworld");
		elseif rest == "pvp" then
			GrowlManager_pvp = true;
			print("GrowlManager is now enabled in pvp instances");
		else
			GrowlManager_ShowHelp();
		end
	elseif command == "override" then
		GrowlManager_Override = true;
		print("GrowlManager is now disabled for only this instance or party");
	elseif(command == "default") then
		GrowlManager_setup()
		print("GrowlManager is now set to default operations");
	elseif(command == "setMsg") then
		GrowlManager_Message = rest;
	elseif(command == "debug") then
		print(GrowlManager_Dungeon);
		print(GrowlManager_Overworld);
		print(GrowlManager_pvp);
		print(GrowlManager_IsGrowlEnabled());
	else
		GrowlManager_ShowHelp();
	end
end

function GrowlManager_ShowHelp()
	print("GrowlManager usage:");
	print("'/GrowlManager override'");
	print("Disables GrowlManager functionality for just this instance or party");
	print("'/GrowlManager enable (|dungeon|overworld|pvp)'");
	print("Enables GrowlManager in dungeon, overworld, or pvp.");
	print("If no argument is given, GrowlManager will be enabled in all three");
	print("'/GrowlManager disable (|dungeon|overworld|pvp)'");
	print("The same usage as enable, but will disable functionality in given places");
	print("'/GrowlManager setMsg 'msg'");
	print("Set your own message to be displayed when GrowlManager is notifying you");
end

function GrowlManager_Warn()
	if (GrowlManager_Message == nil) then
		GrowlManager_Message = "Turn Growl Off!";
	end
	RaidNotice_AddMessage( RaidBossEmoteFrame, GrowlManager_Message, ChatTypeInfo["RAID_BOSS_EMOTE"] );
end

--Returns true if class is growlable, false otherwise
function GrowlManager_IsGrowlableClass()
	local classNum = select(3, UnitClass("Player"));
	return (classNum == 3 or classNum == 9);
end

--Returns 1 if growl or taunt is enabled, 0 otherwise
function GrowlManager_IsGrowlEnabled()
	return (GrowlManager_IsGrowlableClass and (select(2, GetSpellAutocast("Growl")) == true or select(2,GetSpellAutocast("Threatening Presence")) == true)) 
end

--Returns true if the player is in a dungeon, false otherwise
function GrowlManager_IsDungeon()
	return ((select(2,IsInInstance()) == "party") or (select(2,IsInInstance()) == "raid")) 
end


function GrowlManager_IsOverworld()
	return not (select(1,IsInInstance())) 
end

function GrowlManager_IsPvP()
	return((select(2,IsInInstance()) == "pvp") or (select(2,IsInInstance()) == "arena")) 
end

function GrowlManager_OnEvent(self, event, arg1, arg2)
	if(event == "ADDON_LOADED" and arg1 == "GrowlManager") then
		--print(arg1);
		--print(GrowlManager_hasRun);
		if(GrowlManager_hasRun == nil) then
			GrowlManager_setup();
		else
			print("GrowlManager and variables loaded!");
		end
	elseif(event ~= "ADDON_LOADED" and (not GrowlManager_Override or event == "GROUP_ROSTER_CHANGED")) then
		GrowlManager_DoManage()
		if(event == "GROUP_ROSTER_CHANGED") then
			GrowlManager_Override = false;
		end
	end
end

--IsInGroup()
function GrowlManager_DoManage()
	if(GrowlManager_IsGrowlEnabled() and IsInGroup()) then
		if((GrowlManager_Dungeon and GrowlManager_IsDungeon()) or (GrowlManager_pvp and GrowlManager_IsPvP()) or (GrowlManager_Overworld and GrowlManager_IsOverworld())) then
			GrowlManager_Warn();
		end
	end
end