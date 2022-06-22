#include "Hitters.as"
#include "LimbsCommon.as"
#include "EquipmentCommon.as"
#include "Health.as"
#include "AfterLife.as"
#include "CommonParticles.as"
#include "MaterialCommon.as"

void Kill(CBlob @this, CBlob@ hitterBlob, u8 customData)
{
	if(hitterBlob !is null){
		if(isServer()){
			CInventory@ inv = this.getInventory();
			if(inv !is null){
				int coins = 0;
				for (int j = 0; j < inv.getItemsCount(); j++)
				{
					CBlob@ item = inv.getItem(j);
					if(item !is null){
						if(item.getName() == "coin"){
							coins += item.getQuantity();
						}
					}
				}
				if(this.hasBlob("coin",coins)){
					Material::createFor(hitterBlob, "coin", coins);
					this.TakeBlob("coin", coins);
				}
			}
		}
		if(this.hasTag("alive") && (this.getTeamNum() > 50 || hitterBlob.hasTag("darkness_sworn"))){
			int amount = 20+this.get_s16("darkness");
			
			if(hitterBlob.hasTag("darkness_sworn") && hitterBlob.getName() != "dark_being"){
				CBlob@[] blobsInRadius;
				getBlobsByName("dark_being",@blobsInRadius);
				for(int  i = 0;i < blobsInRadius.length;i++){
					blobsInRadius[i].add_s16("darkness",amount/(blobsInRadius.length+1));
				}
				hitterBlob.add_s16("darkness",amount/(blobsInRadius.length+1));
			} else hitterBlob.add_s16("darkness",amount);
			for(int i = 0;i < 10;i++)cpr(hitterBlob.getPosition()+(Vec2f(XORRandom(8),0).RotateBy(XORRandom(360))),Vec2f(XORRandom(7)-3,XORRandom(7)-3)*0.5f);
		}
	}
	
	this.Untag("alive");
	this.Untag("animated");
	if(this.get_u8("heart") == HeartType::Beating){
		this.set_u8("heart",HeartType::Stopped);
	}
	
	///Eject core
	if(this.get_u16("tors_equip") == Equipment::LifeCore || this.get_u16("tors_equip") == Equipment::DeathCore){
		if(this.get_u16("tors_equip_type") > 0){
			if(isServer()){
				CBlob @newBlob = server_CreateBlob("core", this.getTeamNum(), this.getPosition());
				if (newBlob !is null)
				{
					//newBlob.server_SetPlayer(this.getPlayer());
					
					if(this.getPlayer() !is null){
						newBlob.set_string("player_name",this.getPlayer().getUsername());
						newBlob.Tag("soul_"+this.getPlayer().getUsername());
					}
					
					newBlob.set_u8("level",this.get_u16("tors_equip_type"));
					newBlob.set_u16("equip_type",this.get_u16("tors_equip_type"));
					
					if(this.get_u16("tors_equip") == Equipment::LifeCore)newBlob.set_u8("infuse",1);
					else newBlob.set_u8("infuse",2);
					newBlob.set_u16("equip_id",this.get_u16("tors_equip"));
					newBlob.Tag("equippable");
					
					if(newBlob.get_u8("level") == 1)newBlob.server_SetHealth(newBlob.getInitialHealth()*5.0f);
					if(newBlob.get_u8("level") == 2)newBlob.server_SetHealth(newBlob.getInitialHealth()*25.0f);
				}
			}
		}
		this.set_u16("tors_equip",Equipment::None);
		this.set_u16("tors_default",Equipment::None);
		if(isServer()){
			this.Sync("tors_equip",true);
			this.Sync("tors_default",true);
		}
	}
	
	createGhost(this); //Will create a ghost for the player if they die

	//Kick the player/bot out
	if (getNet().isServer())
		if(this.getPlayer() !is null)
			this.server_SetPlayer(null);
	this.getBrain().server_SetActive(false);

	//Clean up player stuff
	this.Untag("shielding");
	this.Untag("player");
	this.getShape().getVars().isladder = false;
	this.getShape().getVars().onladder = false;
	this.getShape().checkCollisionsAgain = true;
	this.getShape().SetGravityScale(1.0f);

	///Drop carried
	CBlob@ carried = this.getCarriedBlob();
	if(carried !is null)
	{
		this.server_DetachFrom(carried);
		carried.setVelocity(this.getVelocity());
	}
	
	// fall out of attachments/seats
	this.server_DetachAll();
	
	//turn controls off so the body doesn't move around
	this.setKeyPressed(key_action1, false);
	this.setKeyPressed(key_action2, false);
	this.setKeyPressed(key_left, false);
	this.setKeyPressed(key_right, false);
	this.setKeyPressed(key_down, false);
	this.setKeyPressed(key_up, false);
	this.ClearButtons();
}