
#include "AbilityCommon.as";
#include "EquipmentCommon.as";
#include "HandCasting.as";
#include "Knocked.as";

void onInit(CBlob@ this)
{
	this.addCommandID("cast_marm");
	this.addCommandID("cast_sarm");
	
	this.addCommandID("set_cast_marm");
	this.addCommandID("set_cast_sarm");
}



void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	
	if(getKnocked(this) > 0)return;

	if(this.get_u16("marm_equip") == Equipment::Casting){
		int type = this.get_u16("marm_equip_type");
		Cast(this,type,key_action1);
	}
	
	if(this.get_u16("sarm_equip") == Equipment::Casting){
		int type = this.get_u16("sarm_equip_type");
		Cast(this,type,key_action2);
	}
}


void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if(this.getPlayer() !is getLocalPlayer() || !this.hasTag("has_hand_casting"))return;
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x) - 156.0f,
	          gridmenu.getUpperLeftPosition().y + 24);
	
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(3, 1), "Hand Casting");
	
	if (menu !is null)
	{
		menu.AddButton("EquipmentGUI.png", 3, "Add Cast to main hand", this.getCommandID("cast_marm"));
		menu.AddTextButton(" ", Vec2f(1,1));
		menu.AddButton("EquipmentGUI.png", 4, "Add Cast to sub hand", this.getCommandID("cast_sarm"));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();
	if (cmd == this.getCommandID("cast_marm"))createCastingMenu(this,"marm");
	if (cmd == this.getCommandID("cast_sarm"))createCastingMenu(this,"sarm");
	
	if (cmd == this.getCommandID("set_cast_marm")){
		const u16 CastType = params.read_u16();
		
		equipType(this,"marm",Equipment::Casting,CastType);
	}
	if (cmd == this.getCommandID("set_cast_sarm")){
		const u16 CastType = params.read_u16();
		
		equipType(this,"sarm",Equipment::Casting,CastType);
	}
}

void createCastingMenu(CBlob@ this, string arm){
	if(this.getPlayer() !is getLocalPlayer())return;
	
	int[] @AbilitiesKnown;
	this.get("AbilitiesKnown",@AbilitiesKnown);
	this.ClearGridMenus();
	
	int[] HandCasts;
	
	for(int i = 0;i < AbilitiesKnown.length;i++){
		if(Abilities[AbilitiesKnown[i]].hand_cast >= 0){
			HandCasts.push_back(AbilitiesKnown[i]);
		}
	}
	
	if(HandCasts.length > 0){
		int height = 1;
		int length = HandCasts.length;
		while(length > 5){
			length -= 5;
			height += 1;
		}
		
		CGridMenu@ menu = CreateGridMenu(getDriver().getScreenDimensions()/2.0f, this, Vec2f(5, height), "Add Cast to hand");
		
		if(menu !is null)
		for(int i = 0;i < HandCasts.length;i++){
			CBitStream params;
			params.write_u16(Abilities[HandCasts[i]].hand_cast);
			menu.AddButton(Abilities[HandCasts[i]].icon, Abilities[HandCasts[i]].name, this.getCommandID("set_cast_"+arm),params);
		}
	}

}