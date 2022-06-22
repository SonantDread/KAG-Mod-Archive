//for use with DefaultActorHUD.as based HUDs

Vec2f getActorHUDStartPosition(CBlob@ blob, const u8 bar_width_in_slots)
{
    f32 width = bar_width_in_slots * 32.0f;
    return Vec2f( getScreenWidth()/2.0f + 160 - width, getScreenHeight() - 40 );
}

void DrawInventoryOnHUD( CBlob@ this, Vec2f tl, Vec2f hudPos = Vec2f(0,0) )
{
	SColor col;		 
	CInventory@ inv = this.getInventory();	 
	if (inv is null) return;
	
	CBlob@[] itemsToShow;
	int[] itemAmounts;
	
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
	}
	
	for (int i = 0; i < itemsToShow.length; i++)
	{
		CBlob@ item = itemsToShow[i];
        string itemname = item.getInventoryName();
        string jitem = "GUI/jitem.png";
        Vec2f jdim = Vec2f(16,16);
        Vec2f adjust = Vec2f(0,2);
		const int quantity = itemAmounts[i];
		
		//vertical belt
		Vec2f itempos = Vec2f(10,54 + i * 46) + hudPos;
		GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32,32), Vec2f(2,46 + i * 46)+hudPos);

		GUI::DrawIcon( item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, itempos, 1.0f ); 

		col = SColor(255,255,255,255);
		if(quantity > item.maxQuantity*3)col = SColor(255,255,255,255);
		else if(quantity > item.maxQuantity*2)col = SColor(255,255,255,128);
		else if(quantity > item.maxQuantity*1)col = SColor(255,255,128,0);
		else col = SColor(255,255,0,0);

		if (quantity != 1)
		{
			if (quantity < 10) { GUI::SetFont("menu"); GUI::DrawText(""+quantity, itempos +Vec2f(22,18), col ); }
			else if (quantity < 100) { GUI::SetFont("menu"); GUI::DrawText(""+quantity, itempos +Vec2f(14,18), col ); }
			else if (quantity < 1000) { GUI::SetFont("menu"); GUI::DrawText(""+quantity, itempos +Vec2f(6,18), col ); }
			else { GUI::SetFont("menu"); GUI::DrawText(""+quantity, itempos +Vec2f(-2,18), col ); }
		}
	}
}

void DrawCoinsOnHUD( CBlob@ this, const int coins, Vec2f tl, const int slot )
{
	if (coins > 0)
	{
		GUI::DrawIcon("GUI/jitem.png", 14, Vec2f(16,16), Vec2f(42,38));
		GUI::SetFont("menu");
		GUI::DrawText(""+coins, Vec2f(72,44), color_white);
	}
}