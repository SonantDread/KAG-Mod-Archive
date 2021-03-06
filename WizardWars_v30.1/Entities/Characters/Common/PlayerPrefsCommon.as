//Wizard Include
#include "WizardCommon.as";
#include "NecromancerCommon.as";
#include "MagicCommon.as";

const u8 MAX_SPELLS = 20;

const u8 WIZARD_TOTAL_HOTKEYS = 18;
const u8 NECROMANCER_TOTAL_HOTKEYS = 18;

shared class PlayerPrefsInfo
{
	bool infoLoaded;
	
	string classConfig;

	u8 primarySpellID;
	u8 primaryHotkeyID;
	u8 customSpellID;
	u8[] hotbarAssignments_Wizard;
	u8[] hotbarAssignments_Necromancer;
	
	s8[] spell_cooldowns;

	PlayerPrefsInfo()
	{
		infoLoaded = false;
		
		classConfig = "wizard";
	
		primarySpellID = 0;
		primaryHotkeyID = 0;
		
		for (uint i = 0; i < MAX_SPELLS; ++i)
		{
			spell_cooldowns.push_back(0);
		}
	}
};

void SetCustomSpell( CPlayer@ this, const u8 id )
{
	PlayerPrefsInfo@ playerPrefsInfo;
	if (!this.get( "playerPrefsInfo", @playerPrefsInfo ))
	{
		return;
	}
	playerPrefsInfo.customSpellID = id;
}

void assignHotkey( CPlayer@ this, const u8 hotkeyID, const u8 spellID, string playerClass )
{
	PlayerPrefsInfo@ playerPrefsInfo;
	if (!this.get( "playerPrefsInfo", @playerPrefsInfo ))
	{
		return;
	}
	
	print("hotkey " + hotkeyID + " assigned to spell " + spellID);
	if ( playerClass == "wizard" )
	{
		int hotbarLength = playerPrefsInfo.hotbarAssignments_Wizard.length;
		playerPrefsInfo.hotbarAssignments_Wizard[Maths::Min(hotkeyID,hotbarLength-1)] = spellID;
		playerPrefsInfo.primarySpellID = playerPrefsInfo.hotbarAssignments_Wizard[Maths::Min(playerPrefsInfo.primaryHotkeyID,hotbarLength-1)];
	}
	else if ( playerClass == "necromancer" )
	{
		int hotbarLength = playerPrefsInfo.hotbarAssignments_Necromancer.length;
		playerPrefsInfo.hotbarAssignments_Necromancer[Maths::Min(hotkeyID,hotbarLength-1)] = spellID;
		playerPrefsInfo.primarySpellID = playerPrefsInfo.hotbarAssignments_Necromancer[Maths::Min(playerPrefsInfo.primaryHotkeyID,hotbarLength-1)];
	}
	
	saveHotbarAssignments( this );
}

void defaultHotbarAssignments( CPlayer@ this, string playerClass )
{
	PlayerPrefsInfo@ playerPrefsInfo;
	if (!this.get( "playerPrefsInfo", @playerPrefsInfo ))
	{
		return;
	}
	
	if ( playerClass == "wizard" )
	{
		playerPrefsInfo.hotbarAssignments_Wizard.clear();
		
		int spellsLength = WizardParams::spells.length;
		for (uint i = 0; i < WIZARD_TOTAL_HOTKEYS; i++)
		{
			if ( i > spellsLength )
			{
				playerPrefsInfo.hotbarAssignments_Wizard.push_back(0);
				continue;
			}
				
			if ( i < 15 )
				playerPrefsInfo.hotbarAssignments_Wizard.push_back(i);
			else if ( i == 15 )
				playerPrefsInfo.hotbarAssignments_Wizard.push_back(1);	//assign secondary to teleport
			else if ( i == 16 )
				playerPrefsInfo.hotbarAssignments_Wizard.push_back(2);	//assign aux1 to counter spell
			else if ( i == 17 )
				playerPrefsInfo.hotbarAssignments_Wizard.push_back(3);	//assign aux2 to something
		}	
	}
	else if ( playerClass == "necromancer" )
	{
		playerPrefsInfo.hotbarAssignments_Necromancer.clear();
		
		int spellsLength = NecromancerParams::spells.length;
		for (uint i = 0; i < WIZARD_TOTAL_HOTKEYS; i++)
		{
			if ( i > spellsLength )
			{
				playerPrefsInfo.hotbarAssignments_Necromancer.push_back(0);
				continue;
			}
		
			if ( i < 15 )
				playerPrefsInfo.hotbarAssignments_Necromancer.push_back(i);
			else if ( i == 15 )
				playerPrefsInfo.hotbarAssignments_Necromancer.push_back(1);	//assign secondary to teleport
			else if ( i == 16 )
				playerPrefsInfo.hotbarAssignments_Necromancer.push_back(2);	//assign aux1 to counter spell
			else if ( i == 17 )
				playerPrefsInfo.hotbarAssignments_Necromancer.push_back(3);	//assign aux2 to something
		}	
	}
}

void saveHotbarAssignments( CPlayer@ this )
{
	PlayerPrefsInfo@ playerPrefsInfo;
	if (!this.get( "playerPrefsInfo", @playerPrefsInfo ))
	{
		return;
	}
	
	if (getNet().isClient())
	{
		ConfigFile cfg;
		
		for (uint i = 0; i < playerPrefsInfo.hotbarAssignments_Wizard.length; i++)
		{	
			cfg.add_u32("wizard hotkey" + i, playerPrefsInfo.hotbarAssignments_Wizard[i]);
		}
		
		for (uint i = 0; i < playerPrefsInfo.hotbarAssignments_Necromancer.length; i++)
		{		
			cfg.add_u32("necromancer hotkey" + i, playerPrefsInfo.hotbarAssignments_Necromancer[i]);
		}
		
		cfg.saveFile( "WW_PlayerPrefs.cfg" );
	}	
}

void loadHotbarAssignments( CPlayer@ this, string playerClass )
{
	PlayerPrefsInfo@ playerPrefsInfo;
	if (!this.get( "playerPrefsInfo", @playerPrefsInfo ))
	{
		return;
	}
	
	if ( playerClass == "wizard" )
	{
		playerPrefsInfo.hotbarAssignments_Wizard.clear();
		
		int spellsLength = WizardParams::spells.length;
		for (uint i = 0; i < WIZARD_TOTAL_HOTKEYS; i++)
		{
			if ( i == 15 )
				playerPrefsInfo.hotbarAssignments_Wizard.push_back(1);	//assign secondary to teleport
			else if ( i == 16 )
				playerPrefsInfo.hotbarAssignments_Wizard.push_back(2);	//assign aux1 to counter spell
			else if ( i == 17 )
				playerPrefsInfo.hotbarAssignments_Wizard.push_back(3);	//assign aux2 to something
			else if ( i >= spellsLength )
			{
				playerPrefsInfo.hotbarAssignments_Wizard.push_back(0);
				continue;
			}	
			else if ( i < 15 )
				playerPrefsInfo.hotbarAssignments_Wizard.push_back(i);
		}
		
		int hotbarLength = playerPrefsInfo.hotbarAssignments_Wizard.length;
		if (getNet().isClient()) 
		{	
			u8[] loadedHotkeys;
			ConfigFile cfg;
			if ( cfg.loadFile("../Cache/WW_PlayerPrefs.cfg") )
			{
				for (uint i = 0; i < playerPrefsInfo.hotbarAssignments_Wizard.length; i++)
				{		
					if ( cfg.exists( "wizard hotkey" + i ) )
					{
						u32 iHotkeyAssignment = cfg.read_u32("wizard hotkey" + i);
						loadedHotkeys.push_back( Maths::Min(iHotkeyAssignment, spellsLength-1) );
					}
					else
						loadedHotkeys.push_back(0);
				}
				playerPrefsInfo.hotbarAssignments_Wizard = loadedHotkeys;
				print("Hotkey config file loaded.");
			}
		}
		
		playerPrefsInfo.primarySpellID = playerPrefsInfo.hotbarAssignments_Wizard[Maths::Min(0,hotbarLength-1)];
	}
	else if ( playerClass == "necromancer" )
	{
		playerPrefsInfo.hotbarAssignments_Necromancer.clear();
		
		int spellsLength = NecromancerParams::spells.length;
		for (uint i = 0; i < WIZARD_TOTAL_HOTKEYS; i++)
		{
			if ( i == 15 )
				playerPrefsInfo.hotbarAssignments_Necromancer.push_back(1);	//assign secondary to teleport
			else if ( i == 16 )
				playerPrefsInfo.hotbarAssignments_Necromancer.push_back(2);	//assign aux1 to counter spell
			else if ( i == 17 )
				playerPrefsInfo.hotbarAssignments_Necromancer.push_back(3);	//assign aux2 to something
			else if ( i >= spellsLength )
			{
				playerPrefsInfo.hotbarAssignments_Necromancer.push_back(0);
				continue;
			}
			else if ( i < 15 )
				playerPrefsInfo.hotbarAssignments_Necromancer.push_back(i);
		}
		
		int hotbarLength = playerPrefsInfo.hotbarAssignments_Necromancer.length;
		if (getNet().isClient()) 
		{	
			u8[] loadedHotkeys;
			ConfigFile cfg;
			if ( cfg.loadFile("../Cache/WW_PlayerPrefs.cfg") )
			{
				for (uint i = 0; i < playerPrefsInfo.hotbarAssignments_Necromancer.length; i++)
				{		
					if ( cfg.exists( "necromancer hotkey" + i ) )
					{
						u32 iHotkeyAssignment = cfg.read_u32("necromancer hotkey" + i);
						loadedHotkeys.push_back( Maths::Min(iHotkeyAssignment, spellsLength-1) );
					}
					else
						loadedHotkeys.push_back(0);
				}
				playerPrefsInfo.hotbarAssignments_Necromancer = loadedHotkeys;
				print("Hotkey config file loaded.");
			}
		}
		
		playerPrefsInfo.primarySpellID = playerPrefsInfo.hotbarAssignments_Necromancer[Maths::Min(0,hotbarLength-1)];
	}
}