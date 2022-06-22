
#include "EquipmentCommon.as"
#include "Health.as"
#include "DrawFactorBars.as";
#include "LimbsCommon.as";

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getBlob().set_string("default_hp_sprite","NormalHeartHUD.png");
}

const f32 Scale = 1.0f;

Vec2f HUD = Vec2f(9*2,getScreenHeight()-(42.5f*2.0f));

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();

	
	DrawDarkBar(blob, Vec2f(56,getDriver().getScreenHeight()-90*2));
	
	if(blob.getInventory() !is null)DrawInventoryBar(blob, Vec2f(0,getDriver().getScreenHeight()-96*2));
	//DrawHealthBar(blob, Vec2f(0,getDriver().getScreenHeight()-96*2));
	
	GUI::DrawIcon("MainGUI.png", 0, Vec2f(96,96), Vec2f(0,getDriver().getScreenHeight()-96*2));
	GUI::DrawIcon("MainGUI.png", 7+blob.get_u8("bag_sprite"), Vec2f(96,96), Vec2f(0,getDriver().getScreenHeight()-96*2));
	
	//EquipmentInfo@ equip;
	//if (!blob.get("equipInfo", @equip))return;

	//if(equip.SubHand > Equipment::None)GUI::DrawIcon(getEquipmentName(equip.SubHand)+"_Icon.png", equip.SubHandType, Vec2f(24,24), Vec2f(20*2,getDriver().getScreenHeight()-37*2),  1.0f, 1.0f, SColor(255, 255, 255, 255));
	//if(equip.MainHand > Equipment::None)GUI::DrawIcon(getEquipmentName(equip.MainHand)+"_Icon.png", equip.MainHandType, Vec2f(24,24), Vec2f(31*2,getDriver().getScreenHeight()-39*2), -1.0f, 1.0f, SColor(255, 255, 255, 255));
	
	LimbInfo@ Limbs;
	if(blob.get("limbInfo", @Limbs)){
		
		f32 HeadMaxHealth = getLimbMaxHealth(LimbSlot::Head,Limbs.Head);
		f32 TorsoMaxHealth = getLimbMaxHealth(LimbSlot::Torso,Limbs.Torso);
		f32 FrontLegMaxHealth = getLimbMaxHealth(LimbSlot::FrontLeg,Limbs.FrontLeg);
		f32 BackLegMaxHealth = getLimbMaxHealth(LimbSlot::BackLeg,Limbs.BackLeg);
		f32 MainArmMaxHealth = getLimbMaxHealth(LimbSlot::MainArm,Limbs.MainArm);
		f32 SubArmMaxHealth = getLimbMaxHealth(LimbSlot::SubArm,Limbs.SubArm);
		
		f32 headHurt = blob.get_f32("head_hit");
		f32 torsoHurt = blob.get_f32("torso_hit");
		f32 mainArmHurt = blob.get_f32("main_arm_hit");
		f32 subArmHurt = blob.get_f32("sub_arm_hit");
		f32 frontLegHurt = blob.get_f32("front_leg_hit");
		f32 backLegHurt = blob.get_f32("back_leg_hit");
		Vec2f HurtShake = Vec2f(0,0);
		
		if(Limbs.Torso > 0){
			int frame = (1-(Limbs.TorsoHealth/TorsoMaxHealth))*5.0f;
			if(Limbs.TorsoHealth <= 0)frame = 5;
			SColor torso_colour(0xffff0000);
			frame += 14;
			HurtShake = Vec2f(XORRandom(3)-1,XORRandom(3)-1)*torsoHurt;
			GUI::DrawIcon("BodyHealth.png", frame, Vec2f(31, 34), HUD+HurtShake, Scale);
			torso_colour.setAlpha(255*torsoHurt);
			GUI::DrawIcon("BodyHealth.png", 16, Vec2f(31, 34), HUD+HurtShake, Scale, torso_colour);
		} else {
			int frame = 6;
			frame += 14;
			GUI::DrawIcon("BodyHealth.png", frame, Vec2f(31, 34), HUD, Scale);
		}
		
		if(Limbs.Head > 0){
			int frame = (1-(Limbs.HeadHealth/HeadMaxHealth))*5.0f;
			if(Limbs.HeadHealth <= 0)frame = 5;
			SColor head_colour(0xffff0000);
			frame += 7;
			HurtShake = Vec2f(XORRandom(3)-1,XORRandom(3)-1)*headHurt;
			GUI::DrawIcon("BodyHealth.png", frame, Vec2f(31, 34), HUD+HurtShake, Scale);
			head_colour.setAlpha(255*headHurt);
			GUI::DrawIcon("BodyHealth.png", 9, Vec2f(31, 34), HUD+HurtShake, Scale, head_colour);
		} else {
			int frame = 6;
			frame += 7;
			GUI::DrawIcon("BodyHealth.png", frame, Vec2f(31, 34), HUD, Scale);
		}
		
		if(Limbs.MainArm > 0){
			int frame = (1-(Limbs.MainArmHealth/MainArmMaxHealth))*5.0f;
			if(Limbs.MainArmHealth <= 0)frame = 5;
			frame += 21;
			HurtShake = Vec2f(XORRandom(3)-1,XORRandom(3)-1)*mainArmHurt;
			GUI::DrawIcon("BodyHealth.png", frame, Vec2f(31, 34), HUD+HurtShake, Scale);
			SColor MArm_colour(0xffff0000);
			MArm_colour.setAlpha(255*mainArmHurt);
			GUI::DrawIcon("BodyHealth.png", 23, Vec2f(31, 34), HUD+HurtShake, Scale, MArm_colour);
		} else {
			int frame = 6;
			frame += 21;
			GUI::DrawIcon("BodyHealth.png", frame, Vec2f(31, 34), HUD, Scale);
		}
		
		if(Limbs.SubArm > 0){
			int frame = (1-(Limbs.SubArmHealth/SubArmMaxHealth))*5.0f;
			if(Limbs.SubArmHealth <= 0)frame = 5;
			frame += 28;
			HurtShake = Vec2f(XORRandom(3)-1,XORRandom(3)-1)*subArmHurt;
			GUI::DrawIcon("BodyHealth.png", frame, Vec2f(31, 34), HUD+HurtShake, Scale);
			SColor SArm_colour(0xffff0000);
			SArm_colour.setAlpha(255*subArmHurt);
			GUI::DrawIcon("BodyHealth.png", 30, Vec2f(31, 34), HUD+HurtShake, Scale, SArm_colour);
		} else {
			int frame = 6;
			frame += 28;
			GUI::DrawIcon("BodyHealth.png", frame, Vec2f(31, 34), HUD, Scale);
		}
		
		if(Limbs.FrontLeg > 0){
			int frame = (1-(Limbs.FrontLegHealth/FrontLegMaxHealth))*5.0f;
			if(Limbs.FrontLegHealth <= 0)frame = 5;
			frame += 35;
			HurtShake = Vec2f(XORRandom(3)-1,XORRandom(3)-1)*frontLegHurt;
			GUI::DrawIcon("BodyHealth.png", frame, Vec2f(31, 34), HUD+HurtShake, Scale);
			SColor FLeg_colour(0xffff0000);
			FLeg_colour.setAlpha(255*frontLegHurt);
			GUI::DrawIcon("BodyHealth.png", 37, Vec2f(31, 34), HUD+HurtShake, Scale, FLeg_colour);
		} else {
			int frame = 6;
			frame += 35;
			GUI::DrawIcon("BodyHealth.png", frame, Vec2f(31, 34), HUD, Scale);
		}
		
		if(Limbs.BackLeg > 0){
			int frame = (1-(Limbs.BackLegHealth/BackLegMaxHealth))*5.0f;
			if(Limbs.BackLegHealth <= 0)frame = 5;
			frame += 42;
			HurtShake = Vec2f(XORRandom(3)-1,XORRandom(3)-1)*backLegHurt;
			GUI::DrawIcon("BodyHealth.png", frame, Vec2f(31, 34), HUD+HurtShake, Scale);
			SColor BLeg_colour(0xffff0000);
			BLeg_colour.setAlpha(255*backLegHurt);
			GUI::DrawIcon("BodyHealth.png", 44, Vec2f(31, 34), HUD+HurtShake, Scale, BLeg_colour);
		} else {
			int frame = 6;
			frame += 42;
			GUI::DrawIcon("BodyHealth.png", frame, Vec2f(31, 34), HUD, Scale);
		}
	}
	
	/*
	SColor col = SColor(255, 255, 255, 255);
	GUI::SetFont("menu");
	Vec2f dimensions(0,0);
	string disp = "" + (Maths::Ceil(getHealth(blob)*4.0f)/4.0f);
	if(getHealth(blob) >= 10.0f)disp = "" + Maths::Floor(getHealth(blob));
	GUI::GetTextDimensions(disp, dimensions);
	GUI::DrawText(disp, Vec2f(0,getDriver().getScreenHeight()-96*2) + Vec2f(12*2,34*2) + Vec2f(- dimensions.x/2 , 0), col);*/
}

void DrawInventoryBar(CBlob@ this, Vec2f tl)
{
	SColor col;
	CInventory@ inv = this.getInventory();

	string[] type_count;
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		const string name = item.getName();
		if (type_count.find(name) == -1)
		{
			type_count.push_back(name);
		}
	}
	
	int dis = (type_count.length-1)*32;
	//if(dis < -8)dis = -8;
	GUI::DrawIcon("MainGUI.png", 2, Vec2f(96,96), Vec2f(dis,getDriver().getScreenHeight()-96*2));
	GUI::DrawIcon("MainGUI.png", 3, Vec2f(96,96), Vec2f(dis-96*2,getDriver().getScreenHeight()-96*2));
	
	
	string[] drawn;
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		const string name = item.getName();
		if (drawn.find(name) == -1)
		{
			const int quantity = this.getBlobCount(name);
			drawn.push_back(name);
			
			Vec2f iconsize = item.inventoryFrameDimension;
			
			GUI::DrawIcon("MainGUI.png", 6, Vec2f(96,96), Vec2f((drawn.length - 1) * 32,getDriver().getScreenHeight()-96*2));
			
			GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, iconsize, tl + Vec2f((drawn.length - 1) * 32+80*2, 81*2) -iconsize, 1.0f);

			f32 ratio = float(quantity) / float(item.maxQuantity);
			col = ratio > 0.4f ? SColor(255, 255, 255, 255) :
			      ratio > 0.2f ? SColor(255, 255, 255, 128) :
			      ratio > 0.1f ? SColor(255, 255, 128, 0) : SColor(255, 255, 0, 0);

			GUI::SetFont("menu");
			Vec2f dimensions(0,0);
			string disp = "" + quantity;
			GUI::GetTextDimensions(disp, dimensions);
			GUI::DrawText(disp, tl + Vec2f((drawn.length - 1) * 32+72*2+14, 72*2+30) + Vec2f(- dimensions.x/2 , 0), col);
		}
	}
}

void DrawHealthBar(CBlob@ this, Vec2f tl)
{
	
	
	f32 MaxHp = getHealthMax(this);
	f32 Hp = Maths::Floor(getHealth(this)*4)/4.0f;
	
	LimbInfo@ Limbs;
	if(this.get("limbInfo", @Limbs)){
		MaxHp = 5.0f;
		Hp = 5.0f*f32(Limbs.TorsoHealth)/f32(getLimbMaxHealth(LimbSlot::Torso,Limbs.Torso));
	}

	int dis = Maths::Max(MaxHp,Maths::Ceil(Hp))*23*2;
	GUI::DrawIcon("MainGUI.png", 4, Vec2f(96,96), Vec2f(0,getDriver().getScreenHeight()-77*2-dis));
	GUI::DrawIcon("MainGUI.png", 5, Vec2f(96,96), Vec2f(0,getDriver().getScreenHeight()-77*2-dis+96*2));
	GUI::DrawIcon("MainGUI.png", 5, Vec2f(96,96), Vec2f(0,getDriver().getScreenHeight()-77*2-dis+96*4));
	GUI::DrawIcon("MainGUI.png", 5, Vec2f(96,96), Vec2f(0,getDriver().getScreenHeight()-77*2-dis+96*6));
	
	int Container = 0;
	
	while(Hp > 0 || Container < MaxHp)
	{
		int icon = 0;
		if(Hp >= 1.0f)Hp -= 1.0f;
		else {
			if(Hp >= 0.75f)icon = 1;
			else if(Hp >= 0.5f)icon = 2;
			else if(Hp >= 0.25f)icon = 3;
			else icon = 4;
			Hp = 0.0f;
		}
		GUI::DrawIcon("NormalHeartHUD.png", icon, Vec2f(24,22), Vec2f(4,getDriver().getScreenHeight()-96*2-Container*23*2+6),1.0f,Maths::Min(this.getTeamNum(),7));
		Container += 1;
	}
}