
#include "EquipmentCommon.as"
#include "Health.as"
#include "DrawFactorBars.as";

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getBlob().set_string("default_hp_sprite","NormalHeartHUD.png");
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();

	
	DrawDarkBar(blob, Vec2f(56,getDriver().getScreenHeight()-90*2));
	
	if(blob.getInventory() !is null)DrawInventoryBar(blob, Vec2f(0,getDriver().getScreenHeight()-96*2));
	DrawHealthBar(blob, Vec2f(0,getDriver().getScreenHeight()-96*2));
	
	GUI::DrawIcon("MainGUI.png", 0, Vec2f(96,96), Vec2f(0,getDriver().getScreenHeight()-96*2));
	GUI::DrawIcon("MainGUI.png", 7+blob.get_u8("bag_sprite"), Vec2f(96,96), Vec2f(0,getDriver().getScreenHeight()-96*2));

	GUI::DrawIcon(getEquipmentName(blob.get_u16("sarm_equip"))+"_Icon.png", blob.get_u16("sarm_equip_type"), Vec2f(24,24), Vec2f(20*2,getDriver().getScreenHeight()-37*2),  1.0f, 1.0f, SColor(255, 255, 255, 255));
	GUI::DrawIcon(getEquipmentName(blob.get_u16("marm_equip"))+"_Icon.png", blob.get_u16("marm_equip_type"), Vec2f(24,24), Vec2f(31*2,getDriver().getScreenHeight()-39*2), -1.0f, 1.0f, SColor(255, 255, 255, 255));
	
	SColor col = SColor(255, 255, 255, 255);
	GUI::SetFont("menu");
	Vec2f dimensions(0,0);
	string disp = "" + (Maths::Ceil(getHealth(blob)*4.0f)/4.0f);
	if(getHealth(blob) >= 10.0f)disp = "" + Maths::Floor(getHealth(blob));
	GUI::GetTextDimensions(disp, dimensions);
	GUI::DrawText(disp, Vec2f(0,getDriver().getScreenHeight()-96*2) + Vec2f(12*2,34*2) + Vec2f(- dimensions.x/2 , 0), col);
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
		GUI::DrawIcon(getHealthContainer(this,Container+1), icon, Vec2f(24,22), Vec2f(4,getDriver().getScreenHeight()-96*2-Container*23*2+6),1.0f,Maths::Min(this.getTeamNum(),7));
		Container += 1;
	}
}