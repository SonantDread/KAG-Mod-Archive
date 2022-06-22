//Ghost logic

#include "AbilityCommon.as";
#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "DrawOverlay.as"

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -3.0f);
	
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("player");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, -24.0f));
	
	this.Tag("ghost");
	this.Tag("ignore_flags");
	this.Tag("invincible");
	this.Tag("spirit_view");
	
	this.set_u16("soul_link",0);
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;
		
	
	
	if(this.getPosition().y > getMap().tilemapheight*8-32)this.AddForce(Vec2f(0,-200));
	
	if(!this.hasTag("free")){
		CBlob @link = getBlobByNetworkID(this.get_u16("soul_link"));
		if(link !is null){
			if(this.getDistanceTo(link) > 32){
				Vec2f force = link.getPosition()-this.getPosition();
				force.Normalize();
				this.AddForce(force*(this.getDistanceTo(link)-32));
			}
			if(link.getPlayer() !is null){
				addAbility(this,Ability::GuardianSwitch);
			}
			if(isServer())this.server_SetTimeToDie(0);
		} else {
			
			CBlob@[] links;
			if(this.getPlayer() !is null)getBlobsByTag("soul_"+this.getPlayer().getUsername(), @links);
			if(links.length > 0){
				this.set_u16("soul_link",links[0].getNetworkID());
			} else {
				this.Tag("free");
				
			}
		}
	} else {
		addAbility(this,Ability::ShardSelf);
		
		if(this.getPlayer() !is null && this.getPlayer().isBot() && !this.hasTag("test_ghost") && false){
			CBlob @newBlob = server_CreateBlob("ghost_shard", this.getTeamNum(), this.getPosition());
			if (newBlob !is null)
			{
				this.Untag("free");
				this.set_u16("soul_link",newBlob.getNetworkID());
				newBlob.Tag("soul_"+this.getPlayer().getUsername());
				newBlob.set_string("player_name",this.getPlayer().getUsername());
				this.Sync("soul_link",true);
				this.server_SetTimeToDie(0);
			}
			this.Tag("test_ghost");
		}
	}
	
	if(isServer())
	if(getGameTime() % 35 == 0){
		this.Sync("soul_link",true);
		this.Sync("free",true);
		if(!this.hasTag("free"))this.server_SetTimeToDie(0);
		else if(this.getTimeToDie() <= 0)this.server_SetTimeToDie(15);
	}
}

void onRender(CSprite@ this)
{

	CBlob@ blob = this.getBlob();

	if(getLocalPlayer() !is blob.getPlayer())return;

	bool drawScreen = true;
	
	CBlob @link = getBlobByNetworkID(this.getBlob().get_u16("soul_link"));
	if(link !is null)if(link.getName() == "humanoid")drawScreen = false;
	
	if(drawScreen)DrawOverlay("GhostBlur.png");
	
}


void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("GhostIcon.png", 0, Vec2f(16, 16));
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("ghost");
}