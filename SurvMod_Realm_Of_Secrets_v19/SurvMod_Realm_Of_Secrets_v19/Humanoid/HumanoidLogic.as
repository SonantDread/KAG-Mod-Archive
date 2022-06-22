
#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "HumanoidAnimCommon.as";
#include "FireCommon.as";
#include "LimbsCommon.as";
#include "Health.as";


void onInit(CBlob@ this)
{
	this.Tag("player");
	this.Tag("flesh");
	this.Tag("alive");
	
	this.push("names to activate", "keg");
	this.push("names to activate", "bomb");
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;
	
	this.set_u8("sex",XORRandom(2));
	
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 48.0f));
	
	this.set_u8("bag_sprite",0);
	
	this.set_f32("PowerLevel",1);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("HumanoidIcon.png", 0, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	bool serverSide = getNet().isServer();
	bool clientSide = getNet().isClient();

	if(this.isInInventory())return;
	const bool ismyplayer = this.isMyPlayer();

	CPlayer @player = this.getPlayer();
	
	if(player !is null){
		this.set_string("player_name",player.getUsername());

		if(getGameTime() % 180 == 59){
			
			if(serverSide){
				this.set_u8("sex",player.getSex());
				this.Sync("sex",true);
			}
			this.setSexNum(this.get_u8("sex"));
			
			int icon = 0;
			int limbType = this.get_u8("tors_type");
			if(limbType == BodyType::Wraith)icon = 1;
			else if(limbType == BodyType::Golem)icon = 2;
			else if(limbType == BodyType::Wood)icon = 3;
			else if(limbType == BodyType::Zombie)icon = 4;
			else if(limbType == BodyType::Cannibal)icon = 5;
			else if(limbType == BodyType::Ghoul)icon = 6;
			player.SetScoreboardVars("HumanoidIcon.png", icon, Vec2f(16, 16));
		}
	}

	
	//////////////////////////////////Clientstuff
	
	if(clientSide){
		if(ismyplayer){
		
			if(this.isKeyPressed(key_inventory)){
				if(this.get_u8("bag_sprite") < 2)this.add_u8("bag_sprite",1);
			} else {
				if(this.get_u8("bag_sprite") > 0)this.sub_u8("bag_sprite",1);
			}
		}
	}

}