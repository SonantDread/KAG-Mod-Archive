// Research

//do wards
//core
//tek: increase team cap by one
//tek: conscription, make people start with swords

#include "GetPlayerData.as";

void onInit( CBlob@ this )
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.inventoryButtonPos = Vec2f(12, 0);
	
	this.addCommandID("research");
	this.addCommandID("theory");
	this.addCommandID("test_theory");
	this.addCommandID("remove_theory");
	
	this.Tag("bookshelf");
	
	this.set_u8("pages",0);
	
	//if(this.getName() == "study")
	//	this.set_u8("theory_max",3);
	//else 
		this.set_u8("theory_max",2);
	
	AddIconToken("$theory_icon$", "Theory.png", Vec2f(24, 24), 0);
	AddIconToken("$clear_icon$", "Theory.png", Vec2f(24, 24), 1);
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return forBlob.isOverlapping(this);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		if(caller.getCarriedBlob() !is null){
			if(caller.getCarriedBlob().hasTag("theory"))caller.CreateGenericButton(23, Vec2f(-6,0), this, this.getCommandID("theory"), "Add this research to the current theory.", params);
			else caller.CreateGenericButton(11, Vec2f(-6,0), this, this.getCommandID("research"), "Disassemble item to research it.", params);
		} else {
			if(this.get_u8("pages") > 0)caller.CreateGenericButton(27, Vec2f(-6,0), this, this.getCommandID("theory"), "Check current theory.", params);
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("research"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		{
			if(isServer()){
				if(caller.getCarriedBlob() !is null){
					if(getResults(caller,caller.getCarriedBlob())){
						caller.getCarriedBlob().server_Die();
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("theory"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(caller.getCarriedBlob() !is null){
				if(this.get_u8("pages") < this.get_u8("theory_max")){
					this.set_string("theory_page_"+this.get_u8("pages"),caller.getCarriedBlob().getName());
					this.set_string("theory_name_"+this.get_u8("pages"),caller.getCarriedBlob().getInventoryName());
					this.set_string("theory_icon_"+this.get_u8("pages"),caller.getCarriedBlob().inventoryIconName);
					this.set_u8("theory_frame_"+this.get_u8("pages"),caller.getCarriedBlob().inventoryIconFrame);
					this.add_u8("pages",1);
				}
			} else {
				if(caller is getLocalPlayerBlob()){
					CGridMenu @menu = CreateGridMenu(Vec2f(getDriver().getScreenWidth()/2,getDriver().getScreenHeight()/2), this, Vec2f(this.get_u8("pages")+2,1), "Theory ("+this.get_u8("pages")+"/"+this.get_u8("theory_max")+")");
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					for(int i = 0;i < this.get_u8("pages");i++){
						CGridButton @ but = menu.AddButton(this.get_string("theory_icon_"+i), this.get_u8("theory_frame_"+i), Vec2f(16,16), this.get_string("theory_name_"+i), this.getCommandID("theory"), Vec2f(1,1),params);
						but.clickable = false;
					}
					menu.AddButton("$clear_icon$", "Clear Theory", this.getCommandID("remove_theory"), Vec2f(1,1));
					menu.AddButton("$theory_icon$", "Test Theory", this.getCommandID("test_theory"), Vec2f(1,1),params);
				}
			}
		}
	}
	if (cmd == this.getCommandID("remove_theory"))
	{
		this.set_u8("pages",0);
	}
	if (cmd == this.getCommandID("test_theory"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			testTheory(this,caller);
		}
		this.set_u8("pages",0);
	}
}

enum Tech{
	Water= 1,
	Air  = 2,
	Stone= 4,
	Blood= 8,
	Flora= 16,
	Gold = 32,
	Wood = 64,
	Fire = 128,
	Food = 256,
	Cloth= 512,
	Volatile=1024,
	Metal=2048,
}

void testTheory(CBlob@ this, CBlob@ caller){
	string result = "";
	Random@ rand = Random(this.getNetworkID());
	u64 TekMask = 0;
	string[] ingrediants;
	
	for(int i = 0;i < this.get_u8("pages");i++){
		string text = this.get_string("theory_page_"+i);
		if(!caller.hasBlob(text,1)){
			
			if(getLocalPlayerBlob() is caller){
				client_AddToChat("You don't have the correct notes to complete this theory.");
			}
			
			return;
		} else {
			if(text == "tek_water")TekMask |= Tech::Water;
			if(text == "tek_air")TekMask |= Tech::Air;
			if(text == "tek_stone")TekMask |= Tech::Stone;
			if(text == "tek_blood")TekMask |= Tech::Blood;
			if(text == "tek_flora")TekMask |= Tech::Flora;
			if(text == "tek_gold")TekMask |= Tech::Gold;
			if(text == "tek_wood")TekMask |= Tech::Wood;
			if(text == "tek_fire")TekMask |= Tech::Fire;
			if(text == "tek_food")TekMask |= Tech::Food;
			if(text == "tek_cloth")TekMask |= Tech::Cloth;
			if(text == "tek_volatiles")TekMask |= Tech::Volatile;
			if(text == "tek_metal")TekMask |= Tech::Metal;
			
			ingrediants.push_back(text);
		}
	}
	
	
	
	if(TekMask == Tech::Flora | Tech::Blood)result = "tek_food";
	if(TekMask == Tech::Flora | Tech::Stone)result = "tek_wood";
	if(TekMask == Tech::Blood | Tech::Water)result = "tek_cloth";
	if(TekMask == Tech::Flora | Tech::Gold)result = "tek_volatiles";
	if(TekMask == Tech::Flora | Tech::Air)result = "tek_fire";
	if(TekMask == Tech::Gold | Tech::Stone)result = "tek_metal";
	
	if(TekMask == (((rand.NextRanged(100) < 50)?Tech::Stone : Tech::Metal) | Tech::Wood))result = "tek_mechanics";
	if(TekMask == (((rand.NextRanged(100) < 50)?Tech::Cloth : Tech::Food) | Tech::Gold))result = "tek_economy";
	if(TekMask == (((rand.NextRanged(100) < 50)?Tech::Fire : Tech::Wood) | Tech::Gold))result = "tek_minting";
	if(TekMask == (Tech::Metal | Tech::Cloth))result = "tek_armour";
	if(TekMask == (Tech::Metal | Tech::Blood))result = "tek_surgery";
	if(TekMask == (((rand.NextRanged(100) < 50)?Tech::Stone : Tech::Metal) | Tech::Fire))result = "tek_smithing";
	if(TekMask == (Tech::Metal | ((rand.NextRanged(100) < 50)?Tech::Fire : Tech::Wood) | Tech::Gold))result = "tek_lecit";
	if(TekMask == (Tech::Metal | ((rand.NextRanged(100) < 50)?Tech::Fire : Tech::Wood) | Tech::Volatile))result = "tek_duram";
	
	
	if(result != ""){
		if(isServer()){
			for(int i = 0;i < this.get_u8("pages");i++){
				caller.TakeBlob(this.get_string("theory_page_"+i),1);
			}
			CBlob @r = server_CreateBlob(result,-1,caller.getPosition());
			caller.server_PutInInventory(r);
			
		}
	} else
	if(getLocalPlayerBlob() is caller)client_AddToChat("Your theory failed.");
}

bool getResults(CBlob@ this, CBlob@ item){

	string name = item.getName();
	
	CBlob @data = getPlayerRoundData(this.getPlayer());
	if(data !is null){
		if(data.hasTag("researched_"+name)){
			if(getLocalPlayerBlob() is this)client_AddToChat("You've already researched this item.");
			return false;
		} else {
			data.Tag("researched_"+name);
		}
	}
	
	///Flesh
	if(name == "chicken"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_blood",-1,this.getPosition()));
			this.server_PutInInventory(server_CreateBlob("tek_air",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "fishy"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_blood",-1,this.getPosition()));
			this.server_PutInInventory(server_CreateBlob("tek_water",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "humanoid"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_blood",-1,this.getPosition()));
			this.server_PutInInventory(server_CreateBlob("tek_blood",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "heart"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_blood",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "steak"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_blood",-1,this.getPosition()));
		}
		return true;
	} else
	
	
	///Materials
	if(name == "mat_stone" || name == "boulder"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_stone",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "mat_wood" || name == "crate"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_wood",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "mat_gold"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_gold",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "mat_metal"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_metal",-1,this.getPosition()));
		}
		return true;
	} else
	
	
	if(name == "mat_bombs"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_metal",-1,this.getPosition()));
			this.server_PutInInventory(server_CreateBlob("tek_volatiles",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "mine"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_metal",-1,this.getPosition()));
			this.server_PutInInventory(server_CreateBlob("tek_volatiles",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "keg"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_wood",-1,this.getPosition()));
			this.server_PutInInventory(server_CreateBlob("tek_volatiles",-1,this.getPosition()));
		}
		return true;
	} else
	
	if(name == "mat_arrows"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_wood",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "mat_bombarrows"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_wood",-1,this.getPosition()));
			this.server_PutInInventory(server_CreateBlob("tek_volatiles",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "mat_firearrows"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_fire",-1,this.getPosition()));
		}
		return true;
	} else
	
	
	
	if(name == "mat_waterbombs"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_water",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "mat_waterarrows"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_water",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "bucket"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_water",-1,this.getPosition()));
			this.server_PutInInventory(server_CreateBlob("tek_wood",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "sponge"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_water",-1,this.getPosition()));
			this.server_PutInInventory(server_CreateBlob("tek_cloth",-1,this.getPosition()));
		}
		return true;
	} else
	
	
	
	
	if(name == "log"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_flora",-1,this.getPosition()));
			this.server_PutInInventory(server_CreateBlob("tek_wood",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "seed"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_flora",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "drill"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_stone",-1,this.getPosition()));
			this.server_PutInInventory(server_CreateBlob("tek_wood",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "saw"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_metal",-1,this.getPosition()));
			this.server_PutInInventory(server_CreateBlob("tek_wood",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "lantern"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_fire",-1,this.getPosition()));
		}
		return true;
	} else
	if(name == "coin"){
		if(isServer()){
			this.server_PutInInventory(server_CreateBlob("tek_gold",-1,this.getPosition()));
		}
		return true;
	} else
	
	return false;
}


//sprite - foreground layer :)

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background
	
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ lantern = this.addSpriteLayer( "lantern", "Lantern.png" , 8, 8, blob.getTeamNum(), blob.getSkinNum() );
	
	if (lantern !is null)
    {
		lantern.SetOffset(Vec2f(9,-5));
		
        Animation@ anim = lantern.addAnimation( "default", 3, true );
        anim.AddFrame(0);
        anim.AddFrame(1);
        anim.AddFrame(2);
        
        blob.SetLight(true);
		blob.SetLightRadius( 32.0f );
    }
	
	/*
	CSpriteLayer@ front = this.addSpriteLayer( "front layer", this.getFilename() , this.getFrameWidth(), this.getFrameHeight(), blob.getTeamNum(), blob.getSkinNum() );

    if (front !is null)
    {
        Animation@ anim = front.addAnimation( "default", 0, false );
        anim.AddFrame(0);
        anim.AddFrame(1);
        anim.AddFrame(2);
        front.SetRelativeZ( 1000 );
    }*/
}
