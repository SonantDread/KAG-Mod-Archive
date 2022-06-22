
#include "Hitters.as";
#include "LimbsCommon.as";

namespace Recipe
{
	enum type
	{
		Pick,
		Axe,
		Hammer,
		Knife,
		Sword,
		Blade,
		Shield,
		Armour,
		Spear,
		Hat,
		Golem,
		Bar
	};
}

void onInit(CBlob @ this)
{
	this.addCommandID("open_menu");
	this.addCommandID("set_smith");
	this.addCommandID("place_item");

	AddIconToken("$pick_icon$", "Pick_Icon.png", Vec2f(24, 24), 0);
	AddIconToken("$axe_icon$", "Axe_Icon.png", Vec2f(24, 24), 1);
	AddIconToken("$hammer_icon$", "Hammer_Icon.png", Vec2f(24, 24), 1);
	
	AddIconToken("$knife_icon$", "Knife_Icon.png", Vec2f(24, 24), 1);
	AddIconToken("$sword_icon$", "Sword_Icon.png", Vec2f(24, 24), 0);
	AddIconToken("$blade_icon$", "GreatSword_Icon.png", Vec2f(24, 24), 0);
	
	AddIconToken("$shield_icon$", "Shield_Icon.png", Vec2f(24, 24), 0);
	AddIconToken("$armour_icon$", "Metal_Armour_Icon.png", Vec2f(24, 24), 0);
	AddIconToken("$helm_icon$", "Hat_Icon.png", Vec2f(24, 24), 5);
	
	AddIconToken("$spear_icon$", "Pole_Icon.png", Vec2f(24, 24), 3);
	AddIconToken("$forge_bar_icon$", "ForgeBar.png", Vec2f(24, 24), 0);
	AddIconToken("$metal_golem_icon$", "MetalGolemIcons.png", Vec2f(16, 16), 1);
	
	this.set_s8("smith",-1);
	
	this.set_u8("progress",0);
	
	this.Tag("save");
	
	if(getNet().isServer())this.server_setTeamNum(-1);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		if(this.isAttachedToPoint("SMITH")){caller.CreateGenericButton(15, Vec2f(0,0), this, this.getCommandID("open_menu"), "Smith", params);}
		
		if(this.isAttachedToPoint("SMITH")){
			caller.CreateGenericButton(16, Vec2f(0,-8), this, this.getCommandID("place_item"), "Remove Item", params);
		} else {
			caller.CreateGenericButton(19, Vec2f(0,0), this, this.getCommandID("place_item"), "Place Item", params);
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
			CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(3, 4), "Smithing\n-\nNot all items can be turned into equipment.\n-\nOnce you have selected an item, hit the anvil\nwith a hammer to finish the product.");
			if (menu !is null)
			{
				CAttachment@ attach = this.getAttachments();
				CBlob @attachedBlob = attach.getAttachedBlob("SMITH");
				if(attachedBlob !is null){
					{
						CBitStream params;
						params.write_u8(Recipe::Pick);
						CGridButton @but = menu.AddButton("$pick_icon$", "Pick", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == Recipe::Pick)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "gold_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(Recipe::Axe);
						CGridButton @but = menu.AddButton("$axe_icon$", "Axe", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == Recipe::Axe)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "gold_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(Recipe::Hammer);
						CGridButton @but = menu.AddButton("$hammer_icon$", "Hammer", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == Recipe::Hammer)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "gold_bar")but.SetEnabled(true);
					}
					////////////////////
					{
						CBitStream params;
						params.write_u8(Recipe::Knife);
						CGridButton @but = menu.AddButton("$knife_icon$", "Knife", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == Recipe::Knife)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "metal_drop_dirty")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(Recipe::Sword);
						CGridButton @but = menu.AddButton("$sword_icon$", "Sword", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == Recipe::Sword)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "gold_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(Recipe::Blade);
						CGridButton @but = menu.AddButton("$blade_icon$", "Blade", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == Recipe::Blade)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "gold_bar")but.SetEnabled(true);
					}
					////////////////////////
					{
						CBitStream params;
						params.write_u8(Recipe::Shield);
						CGridButton @but = menu.AddButton("$shield_icon$", "Shield", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == Recipe::Shield)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(Recipe::Armour);
						CGridButton @but = menu.AddButton("$armour_icon$", "Armour", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == Recipe::Armour)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "gold_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(Recipe::Hat);
						CGridButton @but = menu.AddButton("$helm_icon$", "Helmet", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == Recipe::Hat)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "metal_drop")but.SetEnabled(true);
					}
					////////////////////////
					{
						CBitStream params;
						params.write_u8(Recipe::Spear);
						CGridButton @but = menu.AddButton("$spear_icon$", "Polearm", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == Recipe::Spear)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "metal_bar_large")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(Recipe::Golem);
						CGridButton @but = menu.AddButton("$metal_golem_icon$", "Torso", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == Recipe::Golem)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar")but.SetEnabled(true);
						if(attachedBlob.getName() == "gold_bar")but.SetEnabled(true);
					}
					{
						CBitStream params;
						params.write_u8(Recipe::Bar);
						CGridButton @but = menu.AddButton("$forge_bar_icon$", "Split", this.getCommandID("set_smith"),params);
						if(this.get_s8("smith") == Recipe::Bar)but.SetSelected(1);
						but.SetEnabled(false);
						if(attachedBlob.getName() == "metal_bar_large")but.SetEnabled(true);
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("set_smith")){
		int ID = params.read_u8();
		this.set_s8("smith",ID);
		this.set_u8("progress",0);
		if(getNet().isServer()){
			this.Sync("smith",true);
			this.Sync("progress",true);
		}
	}
	
	if (cmd == this.getCommandID("place_item"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer()){
				
				if(this.isAttachedToPoint("SMITH")){
					CAttachment@ attach = this.getAttachments();
					if(attach.getAttachedBlob("SMITH") !is null){
						CBlob @attachedBlob = attach.getAttachedBlob("SMITH");
						this.server_DetachFrom(attachedBlob);
						this.set_s8("smith",-1);
						this.set_u8("progress",0);
						if(getNet().isServer()){
							this.Sync("smith",true);
							this.Sync("progress",true);
						}
					}
				} else {
				
					CBlob@ hold = caller.getCarriedBlob();
					if(hold !is null){
						caller.DropCarried();
						this.server_AttachTo(hold, "SMITH");
						this.set_s8("smith",-1);
						this.set_u8("progress",0);
						if(getNet().isServer()){
							this.Sync("smith",true);
							this.Sync("progress",true);
						}
					}
				
				}
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(damage >= 1.0f)
	if(customData == Hitters::shield){
		if(this.get_s8("smith") > -1){
			this.set_u8("progress",this.get_u8("progress")+damage*5.0f);
			if(this.get_u8("progress") > 100){
				this.set_u8("progress",0);
				if(getNet().isServer()){
					CAttachment@ attach = this.getAttachments();
					CBlob @attachedBlob = attach.getAttachedBlob("SMITH");
					if(attachedBlob !is null){
						string name = attachedBlob.getName();
						
						int ID = this.get_s8("smith");
						
						if(ID == Recipe::Pick){
							if(name == "metal_bar")server_CreateBlob("metal_pick",-1,this.getPosition());
							if(name == "gold_bar")server_CreateBlob("gold_pick",-1,this.getPosition());
						}
						if(ID == Recipe::Axe){
							if(name == "metal_bar")server_CreateBlob("metal_axe",-1,this.getPosition());
							if(name == "gold_bar")server_CreateBlob("gold_axe",-1,this.getPosition());
						}
						if(ID == Recipe::Hammer){
							if(name == "metal_bar")server_CreateBlob("metal_hammer",-1,this.getPosition());
							if(name == "gold_bar")server_CreateBlob("gold_hammer",-1,this.getPosition());
						}
						///
						if(ID == Recipe::Knife){
							if(name == "metal_bar")server_CreateBlob("metal_knife",-1,this.getPosition());
							if(name == "metal_drop_dirty")server_CreateBlob("dirty_knife",-1,this.getPosition());
						}
						if(ID == Recipe::Sword){
							if(name == "metal_bar")server_CreateBlob("metal_sword",-1,this.getPosition());
							if(name == "gold_bar")server_CreateBlob("gold_sword",-1,this.getPosition());
						}
						if(ID == Recipe::Blade){
							if(name == "metal_bar")server_CreateBlob("metal_blade",-1,this.getPosition());
							if(name == "gold_bar")server_CreateBlob("gold_blade",-1,this.getPosition());
						}
						///
						if(ID == Recipe::Shield)server_CreateBlob("metal_shield",-1,this.getPosition());
						if(ID == Recipe::Armour){
							if(name == "metal_bar")server_CreateBlob("metal_armour",-1,this.getPosition());
							if(name == "gold_bar")server_CreateBlob("gold_armour",-1,this.getPosition());
						}
						if(ID == Recipe::Hat){
							if(name == "metal_bar")server_CreateBlob("metal_hat",-1,this.getPosition());
							if(name == "metal_drop")server_CreateBlob("russian_hat",-1,this.getPosition());
						}
						if(ID == Recipe::Spear){
							if(name == "metal_bar")server_CreateBlob("pike",-1,this.getPosition());
							if(name == "metal_bar_large")server_CreateBlob("halberd",-1,this.getPosition());
						}
						if(ID == Recipe::Golem){
							CBlob @frame = server_CreateBlob("humanoid",-1,this.getPosition());
							
							int body = BodyType::None;
							
							if(name == "metal_bar")body = BodyType::Metal;
							if(name == "gold_bar")body = BodyType::Gold;

							LimbInfo@ limbs;
							if(frame.get("limbInfo", @limbs)){
								setUpLimbs(limbs,BodyType::None,body,CoreType::Missing,BodyType::None,BodyType::None,BodyType::None,BodyType::None);
							}
							
							frame.Untag("alive");
						}
						if(ID == Recipe::Bar){
							if(name == "metal_bar_large"){
								server_CreateBlob("metal_bar",-1,this.getPosition());
								server_CreateBlob("metal_bar",-1,this.getPosition());
							}
						}
						
						attachedBlob.server_Die();
					}
				}
				this.set_s8("smith",-1);
			}
			if(getNet().isServer()){
				this.Sync("progress",true);
				this.Sync("smith",true);
			}
		}
		for(int i = 0; i < 10;i++){
			if (XORRandom(100) < 50) ParticlePixel(worldPoint, getRandomVelocity(90, 4, 45), SColor(255, 255, 50 + XORRandom(100), 0), true, 10 + XORRandom(20));
			else  makeFireParticle(worldPoint, "SmallFire" + (XORRandom(2) + 1));
		}
		this.getSprite().PlaySound("dig_stone2.ogg");
	}
	return 0.0f;
}

void makeFireParticle(Vec2f worldPoint, const string filename = "SmallSmoke")
{
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * 4;
	ParticleAnimated(CFileMatcher(filename).getFirst(), worldPoint + random, getRandomVelocity(90, 0.50f, 45), 0, 1.0f, 2 + XORRandom(3), ((XORRandom(200) - 100) / 800.00f), true);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.isAttachedToPoint("SMITH");
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;
		
	CBlob @ blob = this.getBlob();

	if(blob is null)return;
	
	CCamera @ cam= getCamera();
	
	Vec2f pos2d = blob.getScreenPos();
	f32 width = 1.0f;
	if(cam.targetDistance < 1.0f)width = (cam.targetDistance-0.5f)*2.0f;
	Vec2f dim = Vec2f(24.0f*cam.targetDistance*width, 8);
	const f32 y = 24.0f*cam.targetDistance;
	if(width > 0.0f)
	if (blob.get_u8("progress") > 0.0f)
	{
		const f32 perc = blob.get_u8("progress")*1.0f / 100.0f;
		if (perc >= 0.0f)
		{
			GUI::DrawRectangle(Vec2f(pos2d.x - dim.x - 2, pos2d.y + y), Vec2f(pos2d.x + dim.x + 2, pos2d.y + y + dim.y + 4));
			GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 2, pos2d.y + y + 4), Vec2f(pos2d.x - dim.x + perc * 2.0f * dim.x - 2, pos2d.y + y + dim.y), SColor(0xffac1512));
		}
	}
}