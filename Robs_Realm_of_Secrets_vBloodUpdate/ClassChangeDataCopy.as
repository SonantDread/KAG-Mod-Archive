void CopyData(CBlob@ source, CBlob@ target){

	target.set_string("boss",source.get_string("boss"));
	
	target.set_s16("corruption",source.get_s16("corruption"));
	target.set_s16("kills",source.get_s16("kills"));
	
	target.set_s16("death",source.get_s16("death"));
	target.set_s16("life",source.get_s16("life"));
	target.set_s16("blood",source.get_s16("blood"));
	
	target.Tag("checkedfaceless");
	
	if(source.hasTag("evil"))target.Tag("evil");
	if(source.hasTag("evil_potential"))target.Tag("evil_potential");
	
	if(source.hasTag("onewithnature"))target.Tag("onewithnature");
	
	if(source.hasTag("faceless"))target.Tag("faceless");
	
	if(source.get_u8("race") != 0 && !source.hasTag("ghost"))target.set_u8("race",source.get_u8("race"));
	
	target.set_u8("revive_knowledge",source.get_u8("revive_knowledge"));
	
	for(int i = -1; i < 255; i += 1)if(source.hasTag("key"+i))target.Tag("key"+i);
	
	if(getNet().isServer()){
		target.Sync("life",true);
		target.Sync("death",true);
		target.Sync("blood",true);
		target.Sync("corruption",true);
		target.Sync("evil",true);
		target.Sync("evil_potential",true);
		target.Sync("onewithnature",true);
	}
}