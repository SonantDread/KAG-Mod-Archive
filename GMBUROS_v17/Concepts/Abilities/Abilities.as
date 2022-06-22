
#include "AbilityCommon.as";
#include "DeathAbilities.as";
#include "DarkAbilities.as";

void onInit(CBlob@ this)
{
	int[] AbilitiesKnown;
	this.set("AbilitiesKnown", @AbilitiesKnown);
	
	this.addCommandID("use_instant_cast");
}

void onTick(CBlob@ this)
{
	//addAbility(this,Ability::FireWave);
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	int[] @AbilitiesKnown;
	this.get("AbilitiesKnown",@AbilitiesKnown);
	
	if(this.getName() != "humanoid")this.ClearGridMenus();
	
	int[] InstantCasts;
	
	for(int i = 0;i < AbilitiesKnown.length;i++){
		if(Abilities[AbilitiesKnown[i]].hand_cast <= -1){
			InstantCasts.push_back(AbilitiesKnown[i]);
		}
	}
	
	if(InstantCasts.length > 0){
	
		int length = ((InstantCasts.length+1)/2);
		if(length <= 2)length = 2;
	
		Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x)+84+24*length,gridmenu.getUpperLeftPosition().y - 9.5f * 24);
		if(this.getName() != "humanoid"){
			pos = Vec2f(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),gridmenu.getUpperLeftPosition().y-24.0f);
		}
		CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(length, 2), "Instant Cast");

		if (menu !is null)
		{
			menu.deleteAfterClick = false;
			for(int i = 0;i < Abilities.length;i++)
			if(InstantCasts.find(i) >= 0){
				CBitStream params;
				params.write_u16(i);
				CGridButton @button = menu.AddButton(Abilities[i].icon, Abilities[i].name, this.getCommandID("use_instant_cast"),params);
				button.hoverText = Abilities[i].hover_text+"\n";
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("use_instant_cast"))
	{
		const u16 AbilityID = params.read_u16();
		if(hasAbility(this,AbilityID)){
			if(AbilityID == Ability::ShardSelf)ShardSelf(this);
			if(AbilityID == Ability::ImbueCorpse)ImbueCorpse(this);
			if(AbilityID == Ability::GuardianSwitch)GuardianSwitch(this);
			
			if(AbilityID == Ability::SummonDarkBlade)SummonDarkBlade(this);
			if(AbilityID == Ability::SummonDarkGreatBlade)SummonDarkGreatBlade(this);
			if(AbilityID == Ability::SummonGreaterDarkStaff)SummonGreaterDarkStaff(this);
		}
	}
}