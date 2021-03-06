//default actor hud
// a bar with hearts in the bottom left, bottom right free for actor specific stuff

#include "Survival_Structs.as";

void renderBackBar( Vec2f origin, f32 width, f32 scale)
{
    for (f32 step = 0.0f; step < width/scale - 64; step += 64.0f * scale)
    {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64,32), origin+Vec2f(step*scale,0), scale);
    }

    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64,32), origin+Vec2f(width - 128*scale,0), scale);
}

void renderFrontStone( Vec2f farside, f32 width, f32 scale)
{
    for (f32 step = 0.0f; step < width/scale - 16.0f*scale*2; step += 16.0f*scale*2)
    {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16,32), farside+Vec2f(-step*scale - 32*scale,0), scale);
    }

    if (width > 16) {
        GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16,32), farside+Vec2f(-width, 0), scale);
    }

    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16,32), farside+Vec2f(-width - 32*scale, 0), scale);
    GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16,32), farside, scale);
}

void renderHPBar( CBlob@ blob, Vec2f origin)
{
    string heartFile = "GUI/HPbar.png"; // "GUI/HeartNBubble.png"
    int segmentWidth = 24; // 32
    GUI::DrawIcon("GUI/jends2.png", 0, Vec2f(8,16), origin+Vec2f(-8,0)); // ("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16,32), origin+Vec2f(-segmentWidth,0));
    int HPs = 0;
    for (f32 step = 0.0f; step < blob.getInitialHealth(); step += 0.5f)
    {
        GUI::DrawIcon("GUI/HPback.png", 0, Vec2f(12,16), origin+Vec2f(segmentWidth*HPs,0)); // ("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(16,32), origin+Vec2f(segmentWidth*HPs,0));
        f32 thisHP = blob.getHealth() - step;
        if (thisHP > 0)
        {
            // Vec2f heartoffset = (Vec2f(2,10) * 2);
            Vec2f heartpos = origin+Vec2f(segmentWidth*HPs-1,0); // origin+Vec2f(segmentWidth*HPs,0)+heartoffset;
			if (thisHP <= 0.125f) { GUI::DrawIcon(heartFile, 4, Vec2f(16,16), heartpos); } // Vec2f(12,12)
            else if (thisHP <= 0.25f) { GUI::DrawIcon(heartFile, 3, Vec2f(16,16), heartpos); } // Vec2f(12,12)
            else if (thisHP <= 0.375f) { GUI::DrawIcon(heartFile, 2, Vec2f(16,16), heartpos); } // Vec2f(12,12)
			else if (thisHP > 0.375f) { GUI::DrawIcon(heartFile, 1, Vec2f(16,16), heartpos); } // else { GUI::DrawIcon(heartFile, 1, Vec2f(12,12), heartpos); }
            else { GUI::DrawIcon(heartFile, 0, Vec2f(16,16), heartpos); }
        }
        HPs++;
    }
    GUI::DrawIcon("GUI/jends2.png", 1, Vec2f(8,16), origin+Vec2f(segmentWidth*HPs,0)); // ("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16,32), origin+Vec2f(32*HPs,0));
}

void onInit( CSprite@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender( CSprite@ this )
{
	if (g_videorecording)
		return;

    CBlob@ blob = this.getBlob();
    // Vec2f dim = Vec2f(320,64);
    // Vec2f ul( getScreenWidth()/2.0f - dim.x/2.0f, getScreenHeight() - dim.y + 12 );
    // Vec2f lr( ul.x + dim.x, ul.y + dim.y );
	// GUI::DrawPane(ul, lr);
    // renderBackBar(ul, dim.x, 1.0f);
    // u8 bar_width_in_slots = blob.get_u8("gui_HUD_slots_width");
    // f32 width = bar_width_in_slots * 32.0f;
    // renderFrontStone( ul+Vec2f(dim.x,0), width, 1.0f);
	Vec2f topleft(52,10);
    renderHPBar( blob, topleft); // ( blob, ul);
	
	RenderUpkeepHUD(blob);
	RenderTeamInventoryHUD(blob);
	
	GUI::DrawIcon("GUI/jslot.png", 1, Vec2f(32,32), Vec2f(2,2));
    // GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(128,32), topLeft);
}



void RenderUpkeepHUD(CBlob@ this)
{
	const u8 myTeam = this.getTeamNum();
	
	if (myTeam >= 100) return;
	
	u16 scWidth = getScreenWidth();
	
	TeamData@ team_data;
	GetTeamData(myTeam, @team_data);
	
	if (team_data is null) return;
	
	f32 upkeep_percentage = Maths::Max(0, Maths::Min(f32(team_data.upkeep) / f32(team_data.upkeep_cap), 1));
	u8 color_green = u8(Maths::Min(510.0f * (1.00f - upkeep_percentage), 255));
	u8 color_red = u8(Maths::Min(510.0f * upkeep_percentage, 255));
	
	GUI::SetFont("menu");
	GUI::DrawText("Faction Upkeep: " + team_data.upkeep + " / " + team_data.upkeep_cap, Vec2f(scWidth - 352, 42), SColor(255, color_red, color_green, 0));
	GUI::SetFont("");
	// if (upkeep_percentage >= 0.65f) GUI::DrawText("Your upkeep is too high, build\nmore Quarters!" + (team_data.upkeep > team_data.upkeep_cap ? "\n\nNext player to die gets kicked!" : ""), Vec2f(scWidth - 352, 62 + Maths::Sin(getGameTime() / 8.0f)), SColor(255, color_red, color_green, 0));
	if (upkeep_percentage >= 0.65f) GUI::DrawText("Your upkeep is too high, build\nmore Quarters, Camps or Fortresses!" + (team_data.upkeep > team_data.upkeep_cap ? "\n\nYour faction cannot accept\nany more members!" : ""), Vec2f(scWidth - 352, 62 + Maths::Sin(getGameTime() / 8.0f)), SColor(255, color_red, color_green, 0));
	// if (upkeep_percentage >= 0.65f) GUI::DrawText("Your upkeep is too high, build\nmore Quarters!", Vec2f(scWidth - 352, 62 + Maths::Sin(getGameTime() / 8.0f)), SColor(255, color_red, color_green, 0));
	
	
	
	// GUI::SetFont("");
	// if (upkeep_percentage >= 1) GUI::DrawText("Your upkeep is too high, build\nmore Farms or Quarters!\n\nNext player to die gets kicked!", Vec2f(scWidth - 352, 62 + Maths::Sin(getGameTime() / 8.0f)), SColor(255, color_red, color_green, 0));
	
	// getRules().GetTeamData(myTeam, @team_data);
	
	// this.get("team_list", @team_list);
	// u8 maxTeams = team_list.length;
	
	// const u16 scWidth = getScreenWidth();
	// f32 upkeep = memberCount * 10;
	// f32 upkeep_cap = 
	
	// f32 upkeep_percentage = Maths::Max(0, Maths::Min(f32(upkeep) / f32(upkeep_cap), 1));
	// u8 color_green = u8(Maths::Min(510.0f * (1.00f - upkeep_percentage), 255));
	// u8 color_red = u8(Maths::Min(510.0f * upkeep_percentage, 255));
	
	// GUI::SetFont("menu");
	// // GUI::DrawText("Modifier: " + upkeep_colormod, Vec2f(scWidth - 352, 42), SColor(255, 255, 0, 0));
	// // GUI::DrawText("Green: " + color_green + "; Red: " + color_red, Vec2f(scWidth - 352, 82), SColor(255, 255, 0, 0));
	// GUI::DrawText("Faction Upkeep: " + upkeep + " / " + upkeep_cap, Vec2f(scWidth - 352, 42), SColor(255, color_red, color_green, 0));
	
	// GUI::SetFont("");
	// if (upkeep_percentage >= 1) GUI::DrawText("Your upkeep is too high, build\nmore Farms or Quarters!\n\nNext player to die gets kicked!", Vec2f(scWidth - 352, 62 + Maths::Sin(getGameTime() / 8.0f)), SColor(255, color_red, color_green, 0));
}

// Made by Merser (Mirsario)
const string[] teamItems =
{
	"mat_wood",
	"mat_stone",
	"mat_hemp",
	"mat_oil",
	"mat_coal",
	"mat_mithril",
	"mat_mithrilingot",
	"mat_steelingot",
	"mat_lifesteelingot"
	"mat_copperwire",
	"mat_gear",
	"mat_gunpowder",
	"mat_gyromat",
	"mat_ironplate",
	"mat_pipe",
	"mat_wheel"
};
const string[] teamOres =
{
	"mat_copper",
	"mat_iron",
	"mat_gold"
};
const string[] teamIngots =
{
	"mat_copperingot",
	"mat_ironingot",
	"mat_goldingot"
};

void RenderTeamInventoryHUD(CBlob@ this)
{
	Vec2f hudPos = Vec2f(0, 0);

	int playerTeam=	this.getTeamNum();
	if(playerTeam>=0 && playerTeam<7)
	{
		CBlob@[] baseBlobs;
		getBlobsByTag("faction_base",@baseBlobs);
		CBlob@[] itemsToShow;
		int[] itemAmounts;
		int[] jArray;
		bool closeEnough=false;
		
		for(int i=0;i<baseBlobs.length;i++) 
		{
			CBlob@ baseBlob=baseBlobs[i];
			if(baseBlob.getTeamNum()!=playerTeam){
				continue;
			}
			if((baseBlob.getPosition()-this.getPosition()).Length()<250.0f){
				closeEnough=true;
			}
			CInventory@ inv=baseBlob.getInventory();
			if (inv is null) return;
			
			for(int j=0;j<inv.getItemsCount();j++){
				CBlob@ item=inv.getItem(j);
				string name=item.getInventoryName();
				bool doContinue=false;
				for(int k=0;k<itemsToShow.length;k++){
					if(itemsToShow[k].getInventoryName()==name){
						itemAmounts[k]=itemAmounts[k]+item.getQuantity();
						doContinue=true;
						break;
					}
				}
				if(doContinue){
					continue;
				}
				itemsToShow.push_back(item);
				itemAmounts.push_back(item.getQuantity());
				jArray.push_back(-1);
			}
		}
						
		GUI::DrawIcon("GUI/jslot.png",0,					Vec2f(32,32),Vec2f((getScreenWidth()-54),8)+hudPos);
		GUI::DrawIcon("Emblems.png",playerTeam,				Vec2f(32,32),Vec2f((getScreenWidth()-62),0)+hudPos);
		GUI::DrawIcon("GUI/jslot.png",0,					Vec2f(32,32),Vec2f((getScreenWidth()-102),8)+hudPos);
		GUI::DrawIcon("MenuItems.png",closeEnough ? 28 : 29,Vec2f(32,32),Vec2f((getScreenWidth()-110),0)+hudPos);
		GUI::SetFont("menu");
		GUI::DrawText("Remote access to team storages - ",Vec2f((getScreenWidth()-352),22)+hudPos,closeEnough ? SColor(255,0,255,0) : SColor(255,255,0,0));
		
		int j=0;
		//indian code, gotta repeat it two times
		for(int i=0;i<itemsToShow.length;i++) {
			//draw ores
			CBlob@ item=			itemsToShow[i];
			string itemName=		item.getName();
			bool passed=			false;
			int oreId=				-1;
			for(int k=0;k<teamOres.length;k++){
				if(teamOres[k]==itemName){
					oreId=k;
					passed=true;
					break;
				}
			}
			if(!passed){
				continue;
			}
			bool hasIngot=false;
			for(int l=0;l<itemsToShow.length;l++) {
				if(teamIngots[oreId]==itemsToShow[l].getName()){
					hasIngot=true;
					break;
				}
			}
			jArray[i]=	j;
			
			Vec2f itemPos=	Vec2f(getScreenWidth()-150,54+j*46)+hudPos;
			GUI::DrawIcon("GUI/jslot.png",0,Vec2f(32,32),itemPos);
			GUI::DrawIcon("GUI/jslot.png",2,Vec2f(32,32),itemPos+Vec2f(48,0));
			GUI::DrawIcon(item.inventoryIconName,item.inventoryIconFrame,item.inventoryFrameDimension,itemPos+Vec2f(8,8));
			
			if(!hasIngot){
				GUI::DrawIcon("GUI/jslot.png",0,Vec2f(32,32),itemPos+Vec2f(96,0));
				if(teamIngots[oreId]=="mat_copperingot"){
					GUI::DrawIcon("Material_CopperIngot.png",0,Vec2f(16,16),itemPos+Vec2f(104,8));
				}else if(teamIngots[oreId]=="mat_ironingot"){
					GUI::DrawIcon("Material_IronIngot.png",0,Vec2f(16,16),itemPos+Vec2f(104,8));
				}else if(teamIngots[oreId]=="mat_goldingot"){
					GUI::DrawIcon("Material_GoldIngot.png",0,Vec2f(16,16),itemPos+Vec2f(104,8));
				}
				GUI::SetFont("menu");
				GUI::DrawText("0",itemPos+Vec2f(126,26),SColor(255,255,0,0));
			}
			
			int quantity=	itemAmounts[i];
			f32 ratio=		float(quantity)/float(item.maxQuantity);
			SColor col=	(ratio>0.4f ? SColor(255,255,255,255) :
						(ratio>0.2f ? SColor(255,255,255,128) :
						(ratio>0.1f ? SColor(255,255,128,0)   : SColor(255,255,0,0))));
			int l=	int((""+quantity).get_length());
			if(quantity!=1) {
				GUI::SetFont("menu");
				GUI::DrawText(""+quantity,itemPos+Vec2f(38-(l*8),26),col);
			}
			j++;
		}
		int jMax=j;
		for(int i=0;i<itemsToShow.length;i++) {
			//draw ingots
			int j2=j;
			CBlob@ item=			itemsToShow[i];
			string itemName=		item.getName();
			bool passed=			false;
			int oreId=				-1;
			for(int k=0;k<teamIngots.length;k++){
				if(teamIngots[k]==itemName){
					oreId=k;
					passed=true;
					break;
				}
			}
			if(!passed){
				continue;
			}
			bool hasOre=false;
			for(int l=0;l<itemsToShow.length;l++) {
				if(teamOres[oreId]==itemsToShow[l].getName()){
					j2=jArray[l];
					hasOre=true;
					break;
				}
			}
			
			Vec2f itemPos=	Vec2f(getScreenWidth()-54,54+j2*46)+hudPos;
			GUI::DrawIcon("GUI/jslot.png",0,Vec2f(32,32),itemPos);
			GUI::DrawIcon(item.inventoryIconName,item.inventoryIconFrame,item.inventoryFrameDimension,itemPos+Vec2f(8,8));
			
			if(!hasOre){
				GUI::DrawIcon("GUI/jslot.png",2,Vec2f(32,32),itemPos-Vec2f(48,0));
				GUI::DrawIcon("GUI/jslot.png",0,Vec2f(32,32),itemPos-Vec2f(96,0));
				if(teamOres[oreId]=="mat_copper"){
					GUI::DrawIcon("Material_Copper.png",0,Vec2f(16,16),itemPos+Vec2f(-88,8));
				}else if(teamOres[oreId]=="mat_iron"){
					GUI::DrawIcon("Material_Iron.png",0,Vec2f(16,16),itemPos+Vec2f(-88,8));
				}else if(teamOres[oreId]=="mat_gold"){
					GUI::DrawIcon("Materials.png",2,Vec2f(16,16),itemPos+Vec2f(-88,8));
				}
				GUI::SetFont("menu");
				GUI::DrawText("0",itemPos+Vec2f(-66,26),SColor(255,255,0,0));
			}
			
			int quantity=	itemAmounts[i];
			f32 ratio=		float(quantity)/float(item.maxQuantity);
			SColor col=	(ratio>0.4f ? SColor(255,255,255,255) :
						(ratio>0.2f ? SColor(255,255,255,128) :
						(ratio>0.1f ? SColor(255,255,128,0)   : SColor(255,255,0,0))));
			int l=	int((""+quantity).get_length());
			if(quantity!=1) {
				GUI::SetFont("menu");
				GUI::DrawText(""+quantity,itemPos+Vec2f(38-(l*8),26),col);
			}
			if(j2>=jMax){
				j++;
			}
		}
		for(int i=0;i<itemsToShow.length;i++) {
			//draw everything but ores & ingots
			CBlob@ item=	itemsToShow[i];
			string itemName=item.getName();
			bool passed=	false;
			for(int k=0;k<teamItems.length;k++){
				if(teamItems[k]==itemName){
					passed=true;
					break;
				}
			}
			if(!passed){
				continue;
			}
			
			Vec2f itemPos=	Vec2f(getScreenWidth()-54,54+j*46)+hudPos;
			GUI::DrawIcon("GUI/jslot.png",0,Vec2f(32,32),itemPos);
			if(itemName=="mat_stone")		{GUI::DrawIcon("GUI/jitem.png",1,Vec2f(16,16),itemPos+Vec2f(6,6),1.0f);}
			else if(itemName=="mat_wood")	{GUI::DrawIcon("GUI/jitem.png",2,Vec2f(16,16),itemPos+Vec2f(6,6),1.0f);}
			else{
				GUI::DrawIcon(item.inventoryIconName,item.inventoryIconFrame,item.inventoryFrameDimension,itemPos+Vec2f(8,8));
			}
			
			int quantity=	itemAmounts[i];
			f32 ratio=		float(quantity)/float(item.maxQuantity);
			SColor col=	(ratio>0.4f ? SColor(255,255,255,255) :
						(ratio>0.2f ? SColor(255,255,255,128) :
						(ratio>0.1f ? SColor(255,255,128,0)   : SColor(255,255,0,0))));
			int l=	int((""+quantity).get_length());
			if(quantity!=1) {
				GUI::SetFont("menu");
				GUI::DrawText(""+quantity,itemPos+Vec2f(38-(l*8),26),col);
			}
			j++;
		}
		/*Vec2f itemPos=	Vec2f(getScreenWidth()-54,54+j*46)+hudPos;
		GUI::DrawIcon("GUI/jslot.png",0,Vec2f(32,32),itemPos);
		GUI::DrawIcon("Items/Materials/Raw/Material_Oil.png",0,Vec2f(16,16),itemPos+Vec2f(9,9));
		int quantity=getRules().get_u32("team"+playerTeam+"_oilAmount");
		int l=	int((""+quantity).get_length());
		GUI::DrawText(""+quantity,itemPos+Vec2f(38-(l*8),26),SColor(255,255,255,255));*/
	}
}

