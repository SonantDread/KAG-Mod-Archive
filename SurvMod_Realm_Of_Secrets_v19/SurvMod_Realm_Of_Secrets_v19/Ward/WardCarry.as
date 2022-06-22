void onInit(CBlob @this){
	this.Tag("carries_wards");
}

void onInit(CSprite@ this)
{
	for(int i = 0; i < 4; i += 1)
	{
		this.RemoveSpriteLayer("ward"+i);
		CSpriteLayer@ ward = this.addSpriteLayer("ward"+i, "Ward.png" , 8, 17, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (ward !is null)
		{
			Animation@ anim = ward.addAnimation("default", 0, false);
			ward.SetFrame(0);
			ward.SetOffset(Vec2f(8-i*4,-3));
			ward.SetAnimation("default");
			ward.SetVisible(false);
			ward.SetRelativeZ(-1.0f*i);
		}
	}
}

void onTick(CSprite@ this)
{
	if(getGameTime() % 36 == 0){
		CBlob@ blob = this.getBlob();

		for(int i = 0; i < 4; i += 1)this.getSpriteLayer("ward"+i).SetVisible(false);
		
		int currentSlot = 1;
		
		CInventory@ inv = blob.getInventory();
		if(inv !is null){
			for (int i = 0; i < inv.getItemsCount(); i++)
			{
				CBlob@ item = inv.getItem(i);
				if(item !is null){
					if(item.getName() == "ward"){
						this.getSpriteLayer("ward"+currentSlot).SetVisible(true);
						this.getSpriteLayer("ward"+currentSlot).SetFrame(item.get_u8("mat")*9+item.get_s8("factor"));
						this.getSpriteLayer("ward"+currentSlot).SetOffset(Vec2f(8-currentSlot*4,-4));
						if(currentSlot == 1)currentSlot = 2;
						else if(currentSlot == 2)currentSlot = 0;
						else if(currentSlot == 0)currentSlot = 3;
					}
				}
			}
		}
	}
}