
#include "GetPlayerData.as";
#include "ClanCommon.as";

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-60); //-60 instead of -50 so sprite layers are behind ladders
}

void onTick(CSprite @this){
	CBlob @blob = this.getBlob();
	if(blob.hasTag("locked")){
		this.SetFrame(1);
	} else {
		this.SetFrame(0);
	}
}

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
	this.inventoryButtonPos = Vec2f(9, 0);
	this.addCommandID("store inventory");
	this.getCurrentScript().tickFrequency = 60;
	
	this.Tag("save");
	
	this.addCommandID("metal_lock");
	this.addCommandID("gold_lock");
	
	if(isServer())if(this.hasTag("locked"))this.server_SetHealth(this.getInitialHealth()*2);
}

void onTick(CBlob@ this)
{
	if(isServer()){
		if(!this.hasTag("locked") || getGameTime() < 10*30)PickupOverlap(this);
	}
	
	if(isServer()){
		if(getGameTime() % 300 == 0){
			if(this.hasTag("locked")){
				if(this.getHealth()<this.getInitialHealth()*2)this.server_SetHealth(this.getHealth() + 1);
			} else {
				if(this.getHealth()<this.getInitialHealth())this.server_SetHealth(this.getHealth() + 1);
			}
			if(this.hasTag("locked")){
				if(this.exists("player_locked")){
					this.Sync("player_locked",true);
				}
				if(this.exists("ClanID")){
					this.Sync("ClanID",true);
				}
			}
		}
	}
	
	if(this.getHealth()<=this.getInitialHealth())
	if(this.hasTag("locked")){
		this.Untag("locked");
		if(isClient())this.getSprite().PlaySound("destroy_ladder.ogg",1.0f);
		if(isServer()){
			if(this.get_string("player_locked") != ""){
				server_CreateBlob("metal_drop",-1,this.getPosition());
			}
			if(getBlobClan(this) > 0){
				server_CreateBlob("gold_drop",-1,this.getPosition());
			}
			this.Sync("locked",true);
		}
		this.set_string("player_locked","");
		this.set_u16("ClanID",0);
	}
}

void PickupOverlap(CBlob@ this)
{
	if (getNet().isServer())
	{
		Vec2f tl, br;
		this.getShape().getBoundingRect(tl, br);
		CBlob@[] blobs;
		this.getMap().getBlobsInBox(tl, br, @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (!blob.isAttached() && blob.isOnGround() && (blob.hasTag("save") || blob.hasTag("material")) && blob.getName() != "mat_arrows")
			{
				this.server_PutInInventory(blob);
			}
		}
	}
}

bool canAccess(CBlob@ this, CBlob@ blob){
	
	if(this.hasTag("locked")){
		
		if(this.get_string("player_locked") != ""){
			if(blob.getPlayer() !is null)if(blob.getPlayer().getUsername() == this.get_string("player_locked"))return true;
		} else {
			if(getBlobClan(this) != 0)
			if(getBlobClan(blob) == getBlobClan(this))return true;
		}
		return false;
	}
	
	return true;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	
	if(canAccess(this,caller)){
		if(caller.isOverlapping(this))
		{
			CInventory @inv = caller.getInventory();
			if(inv is null) return;

			if(inv.getItemsCount() > 0)
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());
				caller.CreateGenericButton("$store_inventory$", Vec2f(-3, 0), this, this.getCommandID("store inventory"), getTranslatedString("Store"), params);
			}
			
			
			if(!this.hasTag("locked")){
				if(caller.getCarriedBlob() !is null){
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					if(caller.getCarriedBlob().getName() == "metal_bar"){
						CButton@ button = caller.CreateGenericButton(2, Vec2f(0,-8), this, this.getCommandID("metal_lock"), "Attach Personal Lock", params);
						if(button !is null)button.enableRadius = 24;
					}
					if(caller.getCarriedBlob().getName() == "gold_bar" && getBlobClan(caller) != 0){
						CButton@ button = caller.CreateGenericButton(2, Vec2f(0,-8), this, this.getCommandID("gold_lock"), "Attach Clan Lock", params);
						if(button !is null)button.enableRadius = 24;
					}
				}
			}
		}
	} else {
		string name = " by "+getClanName(getBlobClan(this));
		if(name == " by Nameless")name = "";
		if(this.get_string("player_locked") != "")name = " by "+this.get_string("player_locked");
		CButton@ button = caller.CreateGenericButton(2, Vec2f(0,0), this, this.getCommandID("metal_lock"), "Locked"+name+"\nDamage enough to unlock");
		if(button !is null)button.SetEnabled(false);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer())
	{
		if (cmd == this.getCommandID("store inventory"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{
				CBlob@ carried = caller.getCarriedBlob();
				if (carried !is null)
				{
					// TODO: find a better way to check and clear blocks + blob blocks || fix the fundamental problem, blob blocks not double checking requirement prior to placement.
					if (carried.hasTag("temp blob"))
					{
						carried.server_Die();
					}
				}
				CInventory @inv = caller.getInventory();
				if (inv !is null)
				{
					while (inv.getItemsCount() > 0)
					{
						CBlob @item = inv.getItem(0);
						if(item.getName() != "humanoid")item.Tag("save");
						caller.server_PutOutInventory(item);
						this.server_PutInInventory(item);
					}
				}
				/*
				CBlob @bag = getEquippedBlob(caller,"back");
				if(bag !is null)
				if(bag.hasTag("inventory")){
					CInventory @inv = bag.getInventory();
					if (inv !is null)
					{
						while (inv.getItemsCount() > 0)
						{
							CBlob @item = inv.getItem(0);
							bag.server_PutOutInventory(item);
							this.server_PutInInventory(item);
						}
					}
				}*/
				
			}
		}
	}
	
	if (cmd == this.getCommandID("metal_lock"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer() && !this.hasTag("locked")){
				CBlob@ hold = caller.getCarriedBlob();
				if(hold !is null)if(caller.getPlayer() !is null){
					hold.server_Die();
					this.set_string("player_locked",caller.getPlayer().getUsername());
					this.Sync("player_locked",true);
					this.Tag("locked");
					this.Sync("locked",true);
					this.server_SetHealth(this.getInitialHealth()*2);
				}
			}
		}
	}
	if (cmd == this.getCommandID("gold_lock"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer() && !this.hasTag("locked")){
				CBlob@ hold = caller.getCarriedBlob();
				if(hold !is null)if(caller.getPlayer() !is null){
					hold.server_Die();
					this.set_u16("ClanID",getBlobClan(caller));
					this.Sync("ClanID",true);
					this.Tag("locked");
					this.Sync("locked",true);
					this.server_SetHealth(this.getInitialHealth()*2);
				}
			}
		}
	}
}


bool checkName(string blobName)
{
	return (blobName == "mat_stone" || blobName == "mat_wood" || blobName == "mat_gold" || blobName == "mat_bombs");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob){
	return (forBlob.isOverlapping(this) && canAccess(this,forBlob));
}