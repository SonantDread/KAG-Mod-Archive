#include "Hitters.as"
#include "LimbsCommon.as"
#include "EquipmentCommon.as"
#include "Health.as"
#include "AfterLife.as"
#include "CommonParticles.as"
#include "MaterialCommon.as"

///Make sure Kill being called multiple times per death breaks nothing
void Kill(CBlob @this, CBlob@ hitterBlob, u8 customData)
{
	print("kill!");
	
	if(hitterBlob !is null){
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
	
	LimbInfo@ limbs;
	if(this.get("limbInfo", @limbs)){
	
		if (limbs.Core != CoreType::Missing){
			CBlob@ item = null;

			///Eject core
			if(limbs.Core >= CoreType::WoodSoul && limbs.Core <= CoreType::GoldSpirit){
				if(isServer()){
					int level = 0;
					if(limbs.Core >= CoreType::WoodSoul && limbs.Core <= CoreType::GoldSoul){
						level = limbs.Core-CoreType::WoodSoul;
					} else {
						level = limbs.Core-CoreType::WoodSpirit;
					}
					
					if(level == 0){
						if(limbs.Core >= CoreType::WoodSoul && limbs.Core <= CoreType::GoldSoul){
							@item = server_CreateBlob("wisp", -1, this.getPosition());
						}
					} else {
						@item = server_CreateBlob("core", this.getTeamNum(), this.getPosition());
						if (item !is null)
						{
							if(this.getPlayer() !is null){
								item.set_string("player_name",this.getPlayer().getUsername());
								item.Tag("soul_"+this.getPlayer().getUsername());
							}
							
							
							
							if(limbs.Core >= CoreType::WoodSoul && limbs.Core <= CoreType::GoldSoul){
								item.set_u8("infuse",1);
								item.set_u8("level",level);
								item.set_u16("equip_id",Equipment::LifeCore);
							} else {
								item.set_u8("infuse",2);
								item.set_u8("level",level);
								item.set_u16("equip_id",Equipment::DeathCore);
							}
							
							
							if(level == 1)item.server_SetHealth(item.getInitialHealth()*2.0f);
							if(level == 2)item.server_SetHealth(item.getInitialHealth()*3.0f);
						}
					}
				}
				limbs.Core = CoreType::Missing;
			}

			if (item !is null){
				Vec2f vel(XORRandom(2) == 0 ? -2.0 : 2.0f, -5.0f);
				item.setVelocity(vel);
			}
		}
	
	
		if(limbs.Core == CoreType::Beating){
			limbs.Core = CoreType::Stopped;
		}
	}
	
	createGhost(this); //Will create a ghost for the player if they die

	if(!this.hasTag("destroyed")){

		//Kick the player/bot out
		if(getNet().isServer()){
			this.server_SetPlayer(null);
			this.getBrain().server_SetActive(false);
		}

		//Clean up player stuff
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
}