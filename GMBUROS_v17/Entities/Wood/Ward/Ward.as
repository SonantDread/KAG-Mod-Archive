#include "EquipmentCommon.as";
#include "LimbsCommon.as";

void onInit(CBlob@ this)
{

	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 160.0f;

	this.Tag("builder always hit");
	
	AddIconToken("$flow_icon$", "Runes.png", Vec2f(8, 8), 0);
	AddIconToken("$heat_icon$", "Runes.png", Vec2f(8, 8), 1);
	AddIconToken("$nature_icon$", "Runes.png", Vec2f(8, 8), 2);
	AddIconToken("$blood_icon$", "Runes.png", Vec2f(8, 8), 3);
	AddIconToken("$soul_icon$", "Runes.png", Vec2f(8, 8), 4);
	AddIconToken("$spirit_icon$", "Runes.png", Vec2f(8, 8), 5);
	AddIconToken("$light_icon$", "Runes.png", Vec2f(8, 8), 6);
	AddIconToken("$dark_icon$", "Runes.png", Vec2f(8, 8), 7);
	
	this.set_s8("factor",0);
	this.set_u8("mat",0);
	this.set_u8("gem",0);
	this.set_f32("power",0);
	
	this.addCommandID("open_menu");
	this.addCommandID("upgrade");
	this.addCommandID("infuse");
	
	this.Tag("equippable");
	this.set_u8("equip_slot", EquipSlot::Back);
	
	this.getShape().SetRotationsAllowed(false);
	
	this.Untag("activatable");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	if(caller.getCarriedBlob() is this)
	if(this.get_s8("factor") == 0)
	caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("open_menu"), "Infuse", params);
	
	if(!this.isAttached()){
		if(caller.getCarriedBlob() !is null){
			if(this.get_u8("mat") == 0 && caller.getCarriedBlob().getName() == "mat_stone")caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("upgrade"), "Upgrade with 25 stone", params);
			if((this.get_u8("mat") == 1 || this.get_u8("mat") == 3) && caller.getCarriedBlob().getName() == "metal_drop")caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("upgrade"), "Upgrade with metal", params);
			if((this.get_u8("mat") == 1 || this.get_u8("mat") == 2) && caller.getCarriedBlob().getName() == "gold_drop")caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("upgrade"), "Upgrade with gold", params);
			if(this.get_u8("mat") == 1 && caller.getCarriedBlob().getName() == "lecit_drop")caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("upgrade"), "Upgrade with lecit", params);
			
			string text = "Insert Gem";
			if(this.get_u8("gem") != 0)text = "Replace Gem";
			if(caller.getCarriedBlob().getName().find("gem") >= 0)caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("upgrade"), text, params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	if (cmd == this.getCommandID("open_menu")){
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		if(caller.getPlayer() is getLocalPlayer())
		{
			CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos(), this, Vec2f(2, 4), "Infuse");
			if (menu !is null){
				{
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					params.write_u8(1);
					CGridButton @but = menu.AddButton("$flow_icon$", "Flow Rune", this.getCommandID("infuse"),params);
					but.SetHoverText("Infuse with flow.\nRequires being in water.         \n");
				}
				{
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					params.write_u8(2);
					CGridButton @but = menu.AddButton("$heat_icon$", "Heat Rune", this.getCommandID("infuse"),params);
					but.SetHoverText("Infuse with heat.\nRequires a nearby flame.         \n");
				}
				{
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					params.write_u8(3);
					CGridButton @but = menu.AddButton("$nature_icon$", "Nature Rune", this.getCommandID("infuse"),params);
					but.SetHoverText("Infuse with nature.\nRequires being near nature.         \n");
				}
				{
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					params.write_u8(4);
					CGridButton @but = menu.AddButton("$blood_icon$", "Blood Rune", this.getCommandID("infuse"),params);
					but.SetHoverText("Infuse with blood.\nRequires a heart.         \n");
				}
				{
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					params.write_u8(5);
					CGridButton @but = menu.AddButton("$soul_icon$", "Soul Rune", this.getCommandID("infuse"),params);
					but.SetHoverText("Infuse with soul.\nRequires a wisp nearby.         \n");
				}
				{
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					params.write_u8(6);
					CGridButton @but = menu.AddButton("$spirit_icon$", "Spirit Rune", this.getCommandID("infuse"),params);
					but.SetHoverText("Infuse with spirit.\nRequires a ghost shard.         \n");
				}
				{
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					params.write_u8(7);
					CGridButton @but = menu.AddButton("$light_icon$", "Light Rune", this.getCommandID("infuse"),params);
					but.SetHoverText("Infuse with light.\nRequires gold.         \n");
				}
				{
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					params.write_u8(8);
					CGridButton @but = menu.AddButton("$dark_icon$", "??? Rune", this.getCommandID("infuse"),params);
					but.SetEnabled(false);
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("upgrade"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(isServer()){
				int mat = this.get_u8("mat");
				
				CBlob @carry = caller.getCarriedBlob();
				if(carry !is null){
					if(mat == 0)
					if(caller.hasBlob("mat_stone", 25)){
						caller.TakeBlob("mat_stone", 25);
						this.set_u8("mat",1);
						this.Sync("mat",true);
						this.server_SetHealth(this.getInitialHealth()*2.0f);
					}
					if(carry.getName() == "metal_drop"){
						if(mat == 1){
							this.set_u8("mat",2);
							this.Sync("mat",true);
							this.server_SetHealth(this.getInitialHealth()*4.0f);
							carry.server_Die();
						} else
						if(mat == 3){
							this.set_u8("mat",4);
							this.Sync("mat",true);
							this.server_SetHealth(this.getInitialHealth()*3.0f);
							carry.server_Die();
						}
					}
					if(carry.getName() == "gold_drop"){
						if(mat == 1){
							this.set_u8("mat",3);
							this.Sync("mat",true);
							this.server_SetHealth(this.getInitialHealth()*3.0f);
							carry.server_Die();
						} else
						if(mat == 2){
							this.set_u8("mat",4);
							this.Sync("mat",true);
							this.server_SetHealth(this.getInitialHealth()*3.0f);
							carry.server_Die();
						}
					}
					if(carry.getName() == "lecit_drop"){
						if(mat == 1){
							this.set_u8("mat",4);
							this.Sync("mat",true);
							this.server_SetHealth(this.getInitialHealth()*3.0f);
							carry.server_Die();
						}
					}
					if(carry.getName().find("gem") >= 0){
						int Gem = this.get_u8("gem");
						if(Gem != 0){
							if(this.hasTag("unstable")){
								if(Gem == 1)server_CreateBlob("unstable_gem",-1,this.getPosition()); //Gotta get around to making the others eventually
								if(Gem == 2)server_CreateBlob("unstable_gem",-1,this.getPosition());
								if(Gem == 3)server_CreateBlob("unstable_gem",-1,this.getPosition());
								this.Untag("unstable");
							} else {
								if(Gem == 1)server_CreateBlob("weak_gem",-1,this.getPosition());
								if(Gem == 2)server_CreateBlob("gem",-1,this.getPosition());
								if(Gem == 3)server_CreateBlob("strong_gem",-1,this.getPosition());
							}
						}
						if(carry.getName() == "weak_gem")this.set_u8("gem",1);
						if(carry.getName() == "gem")this.set_u8("gem",2);
						if(carry.getName() == "strong_gem")this.set_u8("gem",3);
						if(carry.getName() == "unstable_gem"){
							this.set_u8("gem",3);
							this.Tag("unstable");
						}
						this.Sync("gem",true);
						this.Sync("unstable",true);
						carry.server_Die();
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("infuse"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		int factor = params.read_u8();
		if(caller !is null)
		{
			if(isServer()){
				if(this.get_s8("factor") == 0){
					if(factor == 1){ //Set Flow
						if(caller.isInWater()){
							this.set_s8("factor",factor);
							this.Sync("factor",true);
						}
					}
					
					if(factor == 2){ //Set Heat
						bool found = false;
						
						if(caller.hasBlob("lantern",1))found = true;
						
						if(!found){
							CBlob@[] blobsInRadius;
							if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) {
								for (uint i = 0; i < blobsInRadius.length; i++){
									CBlob@ b = blobsInRadius[i];
									if(b.getName() == "lantern" || b.getName() == "stickfire" || b.getName() == "altar" || b.hasTag("flame")){
										found = true;
										break;
									}
									if(b.getName() == "ward")
									if(b.get_s8("factor") == factor){
										found = true;
										break;
									}
								}
							}
						}
						
						if(found){
							this.set_s8("factor",factor);
							this.Sync("factor",true);
						}
					}
					
					if(factor == 3){ //Set Nature
						bool found = false;
						
						if(caller.hasBlob("seed",1) || caller.hasBlob("fibre",1))found = true;
						
						if(!found){
							CBlob@[] blobsInRadius;
							if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) {
								for (uint i = 0; i < blobsInRadius.length; i++){
									CBlob@ b = blobsInRadius[i];
									if(b.getName() == "bush" || b.getName() == "tree_pine" || b.getName() == "tree_bushy" || b.getName() == "grain_plant" || b.getName() == "flowers" || b.hasTag("nature") || b.hasTag("plant")){
										found = true;
										break;
									}
									if(b.getName() == "ward")
									if(b.get_s8("factor") == factor){
										found = true;
										break;
									}
								}
							}
						}
						
						if(found){
							this.set_s8("factor",factor);
							this.Sync("factor",true);
						}
					}
					
					if(factor == 4){ //Set Blood
						if(caller.hasBlob("heart",1)){
							caller.TakeBlob("heart",1);
							this.set_s8("factor",factor);
							this.Sync("factor",true);
						}
					}
					
					if(factor == 5){ //Set Soul
						bool found = false;
						
						CBlob@[] blobsInRadius;
						if (this.getMap().getBlobsInRadius(this.getPosition(), 64.0f, @blobsInRadius)) {
							for (uint i = 0; i < blobsInRadius.length; i++){
								CBlob@ b = blobsInRadius[i];
								if(b.getName() == "wisp"){
									found = true;
									b.server_Die();
									break;
								}
							}
						}
						
						if(found){
							this.set_s8("factor",factor);
							this.Sync("factor",true);
						}
					}
					
					if(factor == 6){ //Set Spirit
						CInventory@ inv = caller.getInventory();
						for(int i = 0;i < inv.getItemsCount();i++){
							CBlob @b = inv.getItem(i);
							if(b !is null)
							if(b.getName() == "ghost_shard"){
								if(b.exists("player_name")){
									string name = b.get_string("player_name");
									this.Tag("soul_"+name);
									this.Sync("soul_"+name,true);
									this.set_string("player_name",name);
									this.Sync("player_name",true);
								}
								
								b.server_Die();
								this.set_s8("factor",factor);
								this.Sync("factor",true);
								break;
							}
						}
					}
					
					if(factor == 7){ //Set Light
						if(caller.hasBlob("gold_drop",1)){
							caller.TakeBlob("gold_drop",1);
							this.set_s8("factor",factor);
							this.Sync("factor",true);
						}
					}
				}
			}
		}
	}
	
	UpdateFrame(this.getSprite());
}

void onTick(CBlob@ this){
	if((getGameTime()+this.getNetworkID()) % 50 == 0){
		int mat = this.get_u8("mat");///Screw you I know this is bad, I'm modding, not working
		if(mat == 0)if(this.getHealth() < this.getInitialHealth())this.server_SetHealth(this.getHealth() + 0.25f);
		if(mat == 1)if(this.getHealth() < this.getInitialHealth()*2)this.server_SetHealth(this.getHealth() + 0.25f);
		if(mat == 2)if(this.getHealth() < this.getInitialHealth()*4)this.server_SetHealth(this.getHealth() + 0.25f);
		if(mat == 3)if(this.getHealth() < this.getInitialHealth()*3)this.server_SetHealth(this.getHealth() + 0.25f);
		if(mat == 4)if(this.getHealth() < this.getInitialHealth()*3)this.server_SetHealth(this.getHealth() + 0.25f);
		
		//print("power: "+this.get_f32("power"));
		if(CanRecharge(this) || this.hasTag("unstable"))Recharge(this,37);
		
		if(this.get_s8("factor") == 2 && this.get_u8("gem") > 0){
			if(this.hasTag("lit"))this.Tag("flame");
			else this.Untag("flame");
			if(!this.hasTag("activatable")){
				this.Tag("activatable");
				this.SetLight(true);
				this.Tag("lit");
			}
		}
		
		UpdateFrame(this.getSprite());
		
		if(isServer()){
			this.Sync("factor",true);
			this.Sync("mat",true);
			this.Sync("gem",true);
		}
	}
}

int getWardRadius(CBlob @this){
	f32 size = this.get_u8("gem");
	int mat = this.get_u8("mat");
	
	if(mat == 0)size += 1; //Wood
	if(mat == 3)size += 4; //Gold
	if(mat == 4)size += 2; //Lecit
	
	if(size >= 2)if(this.isAttached())size -= 1;
	
	return size*16.0f;
}

bool CanRecharge(CBlob @this){
	int factor = this.get_s8("factor");
	
	if(!this.isAttached())return true;
	
	CBlob @carry = null;
	if(this.getAttachments().getAttachmentPointByName("PICKUP") !is null)@carry = this.getAttachments().getAttachmentPointByName("PICKUP").getOccupied();
	if(carry is null)if(this.getAttachments().getAttachmentPointByName("BACK") !is null)@carry = this.getAttachments().getAttachmentPointByName("BACK").getOccupied();
	if(carry is null)return true;

	switch(factor){
		case 1:
			return (!carry.isInWater() && carry.isOnGround());
		break;
		
		case 2:
			return carry.hasBlob("lantern",1);
		break;
		
		case 3:
			return carry.isInWater();
		break;
		
		case 4:
			if(carry.getName() == "humanoid"){
				LimbInfo@ limbs;
				if(carry.get("limbInfo", @limbs)){
					for(int j = 0;j < LimbSlot::length;j++){
						if(isFlesh(getLimb(limbs,j))){
							if(getLimbHealth(limbs,j) <= getLimbMaxHealth(j,getLimb(limbs,j))/2.0f){
								return true;
							}
						}
					}
				}
			}
			return false;
		break;
		
		case 5:{
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius(this.getPosition(), getWardRadius(this), @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					if(b !is null)
					if(b.getName() == "wisp"){
						return true;
					}
				}
			}
			return false;
		break;}
		
		case 6:{
			CBlob@[] ghosts;		
			getBlobsByTag("ghost", ghosts);
			
			for (uint i = 0; i < ghosts.length; i++){
				CBlob@ b = ghosts[i];
				
				if(b !is null && b.getPlayer() !is null)
				if(this.get_string("player_name") == b.getPlayer().getUsername()){
					return true;
				}
			}
			
			return false;
		break;}
		
		case 7:
			return !carry.hasTag("in_dark");
		break;
		
		case 8:
			return false;
		break;
		
	}
	
	return false;
}

void Recharge(CBlob @this, f32 power){
	f32 strength = f32(this.get_u8("gem"));
	
	int mat = this.get_u8("mat");
	if(mat == 1)strength += 1; //Stone
	if(mat == 2)strength += 2; //Metal
	if(mat == 4)strength += 1; //Lecit
	
	power *= strength/2.0f;
	
	f32 wards = 1;
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), getWardRadius(this), @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.getName() == "ward" && b !is this){
				wards += 1.0f;
			}
		}
	}
	
	power = power/wards;
	
	power += this.get_f32("power");
	if(power > 30*10){ //No more than 10 seconds of power
		power = 30*10;
	}
	this.set_f32("power",power);
	if(isServer())this.Sync("power",true);
}

void UpdateFrame(CSprite@ this){
	int f = this.getBlob().get_s8("factor");
	int gem  = this.getBlob().get_u8("gem");
	this.getBlob().inventoryIconFrame = this.getBlob().get_u8("mat")*9+f;
	this.SetFrame(this.getBlob().inventoryIconFrame);
	
	CSpriteLayer @highlight = this.getSpriteLayer("highlight");
	if(highlight !is null){
		highlight.SetFrame(f);
	} else {
		@highlight = this.addSpriteLayer("highlight", "WardPower.png" , 8, 17, 0, 0);
		if (highlight !is null){
			highlight.SetRelativeZ(0.01f);
			highlight.SetFrame(f);
			highlight.SetLighting(false);
		}
	}
	
	if(gem > 0){
		int gemframe = 8+gem;
		if(this.getBlob().hasTag("unstable"))gemframe += 3;
		CSpriteLayer @gemhighlight = this.getSpriteLayer("gemhighlight");
		if(gemhighlight !is null){
			gemhighlight.SetFrame(gemframe);
		} else {
			@gemhighlight = this.addSpriteLayer("gemhighlight", "WardPower.png" , 8, 17, 0, 0);
			if (gemhighlight !is null){
				gemhighlight.SetRelativeZ(0.02f);
				gemhighlight.SetFrame(gemframe);
				gemhighlight.SetLighting(false);
			}
		}
	} else {
		this.RemoveSpriteLayer("gemhighlight");
	}
	
	if(f == 2){
		CSpriteLayer @flame = this.getSpriteLayer("flame");
		if(flame !is null){
			flame.SetVisible(gem > 0 && this.getBlob().hasTag("lit"));
		} else {
			@flame = this.addSpriteLayer("flame", "LargeFire.png" , 16, 16, 0, 0);
			if (flame !is null){
				flame.SetRelativeZ(-0.01f);
				Animation@ anim = flame.addAnimation("default", 4, true);
				anim.AddFrame(4);
				anim.AddFrame(5);
				anim.AddFrame(6);
				flame.SetOffset(Vec2f(0,-5));
				flame.SetFacingLeft(true);
				flame.SetLighting(false);
				flame.SetVisible(gem > 0 && this.getBlob().hasTag("lit"));
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getShape().isStatic() || (blob.isInWater() && blob.hasTag("vehicle"))); // boat
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	
	inv.doTickScripts = true;
}