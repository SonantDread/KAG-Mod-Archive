#include "ArcherCommon.as"
#include "KnightCommon.as"
#include "EquipmentCommon.as";
#include "ThrowCommon.as"
#include "Hitters.as"
#include "Requirements.as"

void onInit(CBlob@ this)
{
	this.addCommandID("pick_normal");
	this.addCommandID("pick_bomb");
	this.addCommandID("pick_water");
	this.addCommandID("pick_flaming");
	
	this.addCommandID("get bomb");
	
	this.set_u8("ammo_type",0);
	//0 - normal
	//1 - bomb
	//2 - water
	//3 - fire
}


void onTick(CBlob@ this)
{
	ArcherInfo@ archer;
	if (!this.get("archerInfo", @archer))
	{
		return;
	}
	
	int ammo = this.get_u8("ammo_type");
	
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return;
	
	if(equip.MainHand == Equipment::Bow || equip.SubHand == Equipment::Bow){
		if(ammo == 0){
			if(this.hasBlob("mat_arrows", 1))archer.arrow_type = ArrowType::normal;
			else if(this.hasBlob("mat_firearrows", 1))this.set_u8("ammo_type",3);
			else if(this.hasBlob("mat_waterarrows", 1))this.set_u8("ammo_type",2);
			else if(this.hasBlob("mat_bombarrows", 1))this.set_u8("ammo_type",1);
		}
		if(ammo == 1){
			if(this.hasBlob("mat_bombarrows", 1))archer.arrow_type = ArrowType::bomb;
			else if(this.hasBlob("mat_arrows", 1))this.set_u8("ammo_type",0);
		}
		if(ammo == 2){
			if(this.hasBlob("mat_waterarrows", 1))archer.arrow_type = ArrowType::water;
			else if(this.hasBlob("mat_arrows", 1))this.set_u8("ammo_type",0);
		}
		if(ammo == 3){
			if(this.hasBlob("mat_firearrows", 1))archer.arrow_type = ArrowType::fire;
			else if(this.hasBlob("mat_arrows", 1))this.set_u8("ammo_type",0);
		}
	}
	
	if (this.isMyPlayer())
	{
		// space

		if (this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			bool holding = carried !is null;// && (carried.hasTag("exploding") || carried.getName() == "keg");

			CInventory@ inv = this.getInventory();
			bool thrown = false;
			
			SetFirstAvailableBomb(this);
			u8 bombType = this.get_u8("ammo_type")-1;
			if(bombType != 1)bombType = 0;
			if (bombType < bombTypeNames.length)
			{
				for (int i = 0; i < inv.getItemsCount(); i++)
				{
					CBlob@ item = inv.getItem(i);
					const string itemname = item.getName();
					if (!holding && bombTypeNames[bombType] == itemname)
					{
						if (bombType >= 2)
						{
							this.server_Pickup(item);
							client_SendThrowOrActivateCommand(this);
							thrown = true;
						}
						else
						{
							CBitStream params;
							params.write_u8(bombType);
							this.SendCommand(this.getCommandID("get bomb"), params);
							thrown = true;
						}
						break;
					}
				}
			}

			if (!thrown && holding)
			{
				CBlob@ carried = this.getCarriedBlob();
				if(carried is null || !carried.hasTag("temp blob"))
				{
					client_SendThrowOrActivateCommand(this);
				}
			}
			if (thrown)SetFirstAvailableBomb(this);
		}
	}
}

void SetFirstAvailableBomb(CBlob@ this)
{
	u8 type = this.get_u8("ammo_type");

	CInventory@ inv = this.getInventory();

	bool typeReal = type == 1 || type == 2;
	if (typeReal && inv.getItem(bombTypeNames[type-1]) !is null)
		return;

	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		const string itemname = inv.getItem(i).getName();
		for (uint j = 0; j < bombTypeNames.length; j++)
		{
			if (itemname == bombTypeNames[j])
			{
				type = j+1;
				break;
			}
		}
	}

	this.set_u8("ammo_type", type);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("get bomb"))
	{
		const u8 bombType = params.read_u8();
		if (bombType >= bombTypeNames.length)
			return;

		const string bombTypeName = bombTypeNames[bombType];
		this.Tag(bombTypeName + " done activate");
		if (hasItem(this, bombTypeName))
		{
			if (bombType == 0)
			{
				if (getNet().isServer())
				{
					CBlob @blob = server_CreateBlob("bomb", this.getTeamNum(), this.getPosition());
					if (blob !is null)
					{
						TakeItem(this, bombTypeName);
						this.server_Pickup(blob);
					}
				}
			}
			else if (bombType == 1)
			{
				if (getNet().isServer())
				{
					CBlob @blob = server_CreateBlob("waterbomb", this.getTeamNum(), this.getPosition());
					if (blob !is null)
					{
						TakeItem(this, bombTypeName);
						this.server_Pickup(blob);
						blob.set_f32("map_damage_ratio", 0.0f);
						blob.set_f32("explosive_damage", 0.0f);
						blob.set_f32("explosive_radius", 92.0f);
						blob.set_bool("map_damage_raycast", false);
						blob.set_string("custom_explosion_sound", "/GlassBreak");
						blob.set_u8("custom_hitter", Hitters::water);
                        blob.Tag("splash ray cast");

					}
				}
			}
			else
			{
			}

			SetFirstAvailableBomb(this);
		}
	}else
	if (cmd == this.getCommandID("cycle"))  //from standardcontrols
	{
		u8 type = this.get_u8("ammo_type");

		type++;
		if (type >= 4)
		{
			type = 0;
		}
		
		this.set_u8("ammo_type",type);
	}
	else if (cmd == this.getCommandID("pick_normal"))this.set_u8("ammo_type",0);
	else if (cmd == this.getCommandID("pick_bomb"))this.set_u8("ammo_type",1);
	else if (cmd == this.getCommandID("pick_water"))this.set_u8("ammo_type",2);
	else if (cmd == this.getCommandID("pick_flaming"))this.set_u8("ammo_type",3);
}

bool hasItem(CBlob@ this, const string &in name)
{
	CBitStream reqs, missing;
	AddRequirement(reqs, "blob", name, "Bombs", 1);
	CInventory@ inv = this.getInventory();

	if (inv !is null)
	{
		return hasRequirements(inv, reqs, missing);
	}
	else
	{
		warn("our inventory was null! KnightLogic.as");
	}

	return false;
}

void TakeItem(CBlob@ this, const string &in name)
{
	CBlob@ carried = this.getCarriedBlob();
	if (carried !is null)
	{
		if (carried.getName() == name)
		{
			carried.server_Die();
			return;
		}
	}

	CBitStream reqs, missing;
	AddRequirement(reqs, "blob", name, "Bombs", 1);
	CInventory@ inv = this.getInventory();

	if (inv !is null)
	{
		if (hasRequirements(inv, reqs, missing))
		{
			server_TakeRequirements(inv, reqs);
		}
		else
		{
			warn("took a bomb even though we dont have one! HumanoidBombsArrows.as");
		}
	}
	else
	{
		warn("our inventory was null! HumanoidBombsArrows.as");
	}
}

// arrow pick menu
void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if(this.getPlayer() !is getLocalPlayer())return;
	
	bool createMenu = false;
	
	EquipmentInfo@ equip;
	if (!this.get("equipInfo", @equip))return;
	
	if(equip.MainHand == Equipment::Bow || equip.SubHand == Equipment::Bow)createMenu = true;
	
	if(this.hasBlob("mat_bombs",1) && this.hasBlob("mat_waterbombs",1))createMenu = true;
	
	if(!createMenu)return;
	
	Vec2f pos(gridmenu.getUpperLeftPosition().x + 0.5f * (gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x)+180,
	          gridmenu.getUpperLeftPosition().y - 3.5f * 24);
	CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(4, 2), "Switch Ammo");

	const u8 ammoSelected = this.get_u8("ammo_type");

	if (menu !is null)
	{
		menu.deleteAfterClick = false;
		{
			AddIconToken("$normal_ammo_icon$", "AmmoIcons.png", Vec2f(16, 32), 0);
			CGridButton @button = menu.AddButton("$normal_ammo_icon$", "Normal Ammo", this.getCommandID("pick_normal"));
			if (button !is null)
			{
				button.SetEnabled(true);
				button.selectOneOnClick = true;
				if (ammoSelected == 0)button.SetSelected(1);
			}
		}
		{
			AddIconToken("$bomb_ammo_icon$", "AmmoIcons.png", Vec2f(16, 32), 3);
			CGridButton @button = menu.AddButton("$bomb_ammo_icon$", "Bomb Ammo", this.getCommandID("pick_bomb"));
			if (button !is null)
			{
				button.SetEnabled(true);
				button.selectOneOnClick = true;
				if (ammoSelected == 1)button.SetSelected(1);
			}
		}
		{
			AddIconToken("$water_ammo_icon$", "AmmoIcons.png", Vec2f(16, 32), 1);
			CGridButton @button = menu.AddButton("$water_ammo_icon$", "Water Ammo", this.getCommandID("pick_water"));
			if (button !is null)
			{
				button.SetEnabled(true);
				button.selectOneOnClick = true;
				if (ammoSelected == 2)button.SetSelected(1);
			}
		}
		{
			AddIconToken("$fire_ammo_icon$", "AmmoIcons.png", Vec2f(16, 32), 2);
			CGridButton @button = menu.AddButton("$fire_ammo_icon$", "Fire Ammo", this.getCommandID("pick_flaming"));
			if (button !is null)
			{
				button.SetEnabled(true);
				button.selectOneOnClick = true;
				if (ammoSelected == 3)button.SetSelected(1);
			}
		}
	}
}