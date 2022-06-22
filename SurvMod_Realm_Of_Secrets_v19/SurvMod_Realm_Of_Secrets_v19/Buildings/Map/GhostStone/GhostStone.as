
void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50.0f);

	// minimap
	//this.SetMinimapOutsideBehaviour(CBlob::minimap_none);
	//this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(8, 8));
	//this.SetMinimapRenderAlways(true);
	
	//this.getSprite().getConsts().accurateLighting = true;

	// defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
	
	if(this.getSprite() !is null)this.getSprite().SetAnimation("default");
	this.SetLight(true);
	this.SetLightColor(SColor(128,192,255,192));
	this.SetLightRadius(64);
	
	this.addCommandID("summon");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if(caller.getCarriedBlob() !is null){
		if(caller.getCarriedBlob().getName() == "ghost_shard")caller.CreateGenericButton(11, Vec2f(0,0), this, this.getCommandID("summon"), "Guardian Spirit", params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("summon"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(caller.getCarriedBlob() !is null){
				if(caller.getCarriedBlob().getName() == "ghost_shard"){
					caller.set_string("player_name",caller.getCarriedBlob().get_string("player_name"));
					caller.Tag("soul_"+caller.getCarriedBlob().get_string("player_name"));
					if(isServer())caller.getCarriedBlob().server_Die();
					caller.add_f32("PowerLevel",0.5);
					caller.Tag("spirit_view");
					caller.add_s16("memories",1);
				}
			}
		}
	}
}