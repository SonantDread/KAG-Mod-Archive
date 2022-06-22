
#include "GetPlayerData.as";

void onInit(CBlob@ this)
{
	this.addCommandID("colour_swap");
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if(this.getPlayer() !is getLocalPlayer())return;
	
	CGridMenu@ menu = CreateGridMenu(Vec2f(0, 0), this, Vec2f(4, 2), "Clothing Colour Swap");
	if (menu !is null)
	{
		CBitStream params;

		for(int i = 0; i < 8;i++){
			
			params.write_u8(i);
			menu.AddButton("ChangeColourIcons.png", i, "Swap clothes to "+ColourName(i), this.getCommandID("colour_swap"),params);
			params.Clear();
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("colour_swap"))
	{
		u8 colour = params.read_u8();
		
		CBlob @data = getPlayerRoundData(this.getPlayer());
		if(data !is null){
			u8 oldColour = 7;
			if(data.exists("clothing_colour"))oldColour = data.get_u8("clothing_colour");
			
			data.set_u8("clothing_colour",colour);
			//if(isServer())data.Sync("clothing_colour",true);
			
			if(isClient()){
				CTeam @ team = getRules().getTeam(colour);
				if(this.getPlayer() !is null){
					if(team !is null)client_AddToChat(this.getPlayer().getUsername() + " changed clothing from "+ColourName(oldColour)+" to "+ColourName(colour)+"!", team.color);
					else client_AddToChat(this.getPlayer().getUsername() + " changed clothing from "+ColourName(oldColour)+" to "+ColourName(colour)+"!");
				}
				
				this.Tag("reload_clothes");
				this.Tag("reload_equipment");
			}
		}
	}
	
}

string ColourName(int i){
	
	if(i == 1)return "red";
	if(i == 2)return "green";
	if(i == 3)return "purple";
	if(i == 4)return "orange";
	if(i == 5)return "teal";
	if(i == 6)return "blue";
	if(i == 7)return "grey";
	
	return "aqua";
}