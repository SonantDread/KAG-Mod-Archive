// Template animations

#include "FireCommon.as"
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";
#include "EmotesCommon.as";
#include "Requirements.as";
#include "BuilderCommon.as";
#include "HumanoidAnimCommon.as";
#include "PixelOffsets.as";
#include "EquipmentCommon.as";
#include "KnightCommon.as";
#include "ArcherCommon.as";
#include "LimbsCommon.as";
#include "TimeCommon.as";
#include "GetPlayerData.as";

Vec2f DefaultMainArmOffset = Vec2f(2.0f, 1.0f);
Vec2f DefaultSubArmOffset = Vec2f(-3.0f, 1.0f);
Vec2f DefaultFrontLegOffset = Vec2f(1.0f, 4.0f);
Vec2f DefaultBackLegOffset = Vec2f(2.0f, 4.0f);

void onInit(CSprite@ this)
{
	//Arms
	
	this.RemoveSpriteLayer("frontarm");
	CSpriteLayer@ frontarm = this.addSpriteLayer("frontarm", "Human_Arms.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (frontarm !is null)
	{
		Animation@ anim = frontarm.addAnimation("default", 0, false);
		anim.AddFrame(0);
		Animation@ anim3 = frontarm.addAnimation("stretch", 0, false);
		anim3.AddFrame(2);
		Animation@ anim2 = frontarm.addAnimation("open_hand", 0, false);
		anim2.AddFrame(4);
		Animation@ anim4 = frontarm.addAnimation("point", 0, false);
		anim4.AddFrame(6);
		frontarm.SetOffset(DefaultMainArmOffset);
		frontarm.SetRelativeZ(3.0f);
	}
	
	this.RemoveSpriteLayer("backarm");
	CSpriteLayer@ backarm = this.addSpriteLayer("backarm", "Human_Arms.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backarm !is null)
	{
		Animation@ anim = backarm.addAnimation("default", 0, false);
		anim.AddFrame(1);
		Animation@ anim3 = backarm.addAnimation("stretch", 0, false);
		anim3.AddFrame(3);
		Animation@ anim2 = backarm.addAnimation("open_hand", 0, false);
		anim2.AddFrame(5);
		Animation@ anim4 = backarm.addAnimation("point", 0, false);
		anim4.AddFrame(7);
		
		backarm.SetOffset(DefaultSubArmOffset);
		backarm.SetRelativeZ(-3.0f);
	}
	
	this.RemoveSpriteLayer("frontleg");
	CSpriteLayer@ frontleg = this.addSpriteLayer("frontleg", "Human_Legs.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (frontleg !is null)
	{
		Animation@ anim1 = frontleg.addAnimation("default", 0, false);
		anim1.AddFrame(0);
		Animation@ anim = frontleg.addAnimation("run", 3, true);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		Animation@ anim2 = frontleg.addAnimation("lie", 0, true);
		anim2.AddFrame(5);
		Animation@ anim3 = frontleg.addAnimation("broken", 0, false);
		anim3.AddFrame(6);
		Animation@ anim4 = frontleg.addAnimation("sitting", 0, false);
		anim4.AddFrame(3);
		Animation@ anim5 = frontleg.addAnimation("crouch", 0, false);
		anim5.AddFrame(2);
		frontleg.SetOffset(DefaultFrontLegOffset);
		frontleg.SetRelativeZ(0.22f);
	}
	
	this.RemoveSpriteLayer("backleg");
	CSpriteLayer@ backleg = this.addSpriteLayer("backleg", "Human_Legs.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (backleg !is null)
	{
		Animation@ anim1 = backleg.addAnimation("default", 0, false);
		anim1.AddFrame(7);
		Animation@ anim = backleg.addAnimation("run", 3, true);
		anim.AddFrame(8);
		anim.AddFrame(9);
		anim.AddFrame(10);
		anim.AddFrame(11);
		Animation@ anim2 = backleg.addAnimation("lie", 0, true);
		anim2.AddFrame(12);
		Animation@ anim3 = backleg.addAnimation("broken", 0, false);
		anim3.AddFrame(13);
		Animation@ anim4 = backleg.addAnimation("sitting", 0, false);
		anim4.AddFrame(8);
		Animation@ anim5 = backleg.addAnimation("crouch", 0, false);
		anim5.AddFrame(11);
		backleg.SetOffset(DefaultBackLegOffset);
		backleg.SetRelativeZ(-1.0f);
	}
	
	//Shield
	this.RemoveSpriteLayer("back_shield");
	CSpriteLayer@ shield = this.addSpriteLayer("back_shield", "Shield.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	if (shield !is null)
	{
		int shields = 2;
		Animation@ anim = shield.addAnimation("default", 0, false);
		for(int i = 0;i < shields;i++)anim.AddFrame(i*5);
		Animation@ anim1 = shield.addAnimation("raised", 0, false);
		for(int i = 0;i < shields;i++)anim1.AddFrame(i*5+1);
		Animation@ anim2 = shield.addAnimation("slide", 0, false);
		for(int i = 0;i < shields;i++)anim2.AddFrame(i*5+2);
		Animation@ anim3 = shield.addAnimation("rest", 0, false);
		for(int i = 0;i < shields;i++)anim3.AddFrame(i*5+3);
		shield.SetOffset(Vec2f(2.0f, -2.5f));
		shield.SetRelativeZ(100.0f);
		shield.SetVisible(false);
	}
	
	this.RemoveSpriteLayer("front_shield");
	@shield = this.addSpriteLayer("front_shield", "Shield.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	if (shield !is null)
	{
		int shields = 2;
		Animation@ anim = shield.addAnimation("default", 0, false);
		for(int i = 0;i < shields;i++)anim.AddFrame(i*5);
		Animation@ anim1 = shield.addAnimation("raised", 0, false);
		for(int i = 0;i < shields;i++)anim1.AddFrame(i*5+1);
		Animation@ anim2 = shield.addAnimation("slide", 0, false);
		for(int i = 0;i < shields;i++)anim2.AddFrame(i*5+2);
		Animation@ anim3 = shield.addAnimation("rest", 0, false);
		for(int i = 0;i < shields;i++)anim3.AddFrame(i*5+4);
		shield.SetOffset(Vec2f(2.0f, -2.5f));
		shield.SetRelativeZ(100.0f);
		shield.SetVisible(false);
	}
	
	
	
	//grapple
	this.RemoveSpriteLayer("hook");
	CSpriteLayer@ hook = this.addSpriteLayer("hook", "Grapple.png" , 16, 8, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (hook !is null)
	{
		Animation@ anim = hook.addAnimation("default", 0, false);
		anim.AddFrame(2);
		hook.SetRelativeZ(2.0f);
		hook.SetVisible(false);
	}

	this.RemoveSpriteLayer("rope");
	CSpriteLayer@ rope = this.addSpriteLayer("rope", "Grapple.png" , 32, 8, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (rope !is null)
	{
		Animation@ anim = rope.addAnimation("default", 0, false);
		anim.AddFrame(0);
		rope.SetRelativeZ(-1.5f);
		rope.SetVisible(false);
	}
	
	//Bow
	
	this.RemoveSpriteLayer("bow");
	CSpriteLayer@ bow = this.addSpriteLayer("bow", "Bow.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (bow!is null)
	{
		Animation@ anim = bow.addAnimation("default", 0, false);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		bow.SetOffset(DefaultMainArmOffset);
		bow.SetRelativeZ(2.0f);
		bow.SetVisible(false);
	}

	int ImageFramesInWidth = 8;
	
	{
		this.RemoveSpriteLayer("main_equip");
		CSpriteLayer@ layer = this.addSpriteLayer("main_equip", "equipment.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("pick", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*0+i);
			@anim = layer.addAnimation("hammer", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*1+i);
			@anim = layer.addAnimation("sword", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*2+i);
			@anim = layer.addAnimation("great_sword", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*3+i);
			@anim = layer.addAnimation("pole", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*4+i);
			@anim = layer.addAnimation("axe", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*5+i);
			@anim = layer.addAnimation("knife", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*6+i);
			
			layer.SetOffset(DefaultMainArmOffset);
			layer.SetRelativeZ(2.0f);
		}
	}
	
	{
		this.RemoveSpriteLayer("sub_equip");
		CSpriteLayer@ layer = this.addSpriteLayer("sub_equip", "equipment.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (layer!is null)
		{
			Animation@ anim = layer.addAnimation("pick", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*0+i);
			@anim = layer.addAnimation("hammer", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*1+i);
			@anim = layer.addAnimation("sword", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*2+i);
			@anim = layer.addAnimation("great_sword", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*3+i);
			@anim = layer.addAnimation("pole", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*4+i);
			@anim = layer.addAnimation("axe", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*5+i);
			@anim = layer.addAnimation("knife", 0, false);
			for(int i = 0;i < ImageFramesInWidth;i++)anim.AddFrame(ImageFramesInWidth*6+i);
			
			layer.SetOffset(DefaultSubArmOffset);
			layer.SetRelativeZ(-2.0f);
		}
	}

}

void onTick(CSprite@ this)
{

	CBlob@ blob = this.getBlob();

	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);
	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	
	LimbInfo@ limbs;
	if(!blob.get("limbInfo", @limbs))return;
	
	if(getGameTime() % 30 == 0){
		
		reloadSpriteBody(this,blob);
		
		if(blob.get_u8("sprite_fore_eye") != blob.get_u8("fore_eye"))this.RemoveSpriteLayer("head");
		if(blob.get_u8("sprite_back_eye") != blob.get_u8("back_eye"))this.RemoveSpriteLayer("head");
		
		if(this.isVisible()){
			if(!blob.exists("head_sprite_index") || blob.get_s8("head_sprite_index") != limbs.Head){
				blob.set_s8("head_sprite_index",limbs.Head);
				this.RemoveSpriteLayer("head");
			}
		}
	}
	
	doRopeUpdate(this, null, null);
	ArcherInfo@ archer;
	bool hasArchery = blob.get("archerInfo", @archer);
	if (hasArchery)
	{
		if(blob.hasTag("alive") || blob.hasTag("animated"))doRopeUpdate(this, blob, archer);
	}
	
	RenderStyle::Style style = RenderStyle::normal;
	
	this.setRenderStyle(style);
	
	///Is visible? Beds hiding bodies and such
	
	bool LyingDown = (!blob.hasTag("alive") && !blob.hasTag("animated")); //If dead, lying down
	
	if((limbs.FrontLeg == BodyType::Golem && limbs.BackLeg == BodyType::Golem) || (limbs.FrontLeg == BodyType::Metal && limbs.BackLeg == BodyType::Metal) || (limbs.FrontLeg == BodyType::Gold && limbs.BackLeg == BodyType::Gold)){
		LyingDown = false;
	}
	
	if(blob.isAttachedToPoint("BED"))LyingDown = true; //Everyone lies down in bed
	
	bool Visible = true;
	
	if(this.getSpriteLayer("head") !is null)this.getSpriteLayer("head").SetVisible(Visible);
	
	if(blob.isAttached()){
		if(blob.isAttachedToPoint("BED")){
			blob.SetFacingLeft(false);
			CAttachment@ attach = blob.getAttachments();
			for(int i = 0;i < blob.getAttachmentPointCount();i++){
				AttachmentPoint @ attach = blob.getAttachmentPoint(i);
				if(attach !is null)
				if(attach.getOccupied() !is null)
				if(attach.getOccupied().getName() == "bed_frame"){
					Visible = false;
					if(this.getSpriteLayer("head") !is null)this.getSpriteLayer("head").SetVisible(true);
				}
			}
		}
		
		if(blob.isAttachedToPoint("SEX_A") || blob.isAttachedToPoint("SEX_B")){
			Visible = false;
			if(this.getSpriteLayer("head") !is null)this.getSpriteLayer("head").SetVisible(false);
		}
		
		
	}
	
	this.SetVisible(Visible);
	
	//Animations
	
	this.animation.frame = 0;
	
	bool Crawling =  !isLimbMovable(blob,LimbSlot::FrontLeg) || !isLimbMovable(blob,LimbSlot::BackLeg);//!LyingDown;
	
	if((limbs.FrontLeg == BodyType::Golem && limbs.BackLeg == BodyType::Golem) || (limbs.FrontLeg == BodyType::Metal && limbs.BackLeg == BodyType::Metal) || (limbs.FrontLeg == BodyType::Gold && limbs.BackLeg == BodyType::Gold)){
		//LyingDown = false;
		Crawling = false;
	}
	
	if(LyingDown)this.animation.frame = 1;
	
	bool Crouching = false;
	if(blob.isOnGround() && down){
		if(!left && !right)Crouching = true;
	}
	if(blob.get_bool("short_hitbox"))Crawling = true;
	
	if(Crawling)Crouching = false;
	
	if(LyingDown){
		Crawling = false;
		Crouching = false;
	}
	
	this.SetOffset(Vec2f(0,-4));
	if(Crouching && !Crawling)this.SetOffset(Vec2f(0,-1));
	else if(Crawling)this.SetOffset(Vec2f(0,-6));
	
	bool Sitting = false;
	if(blob.isAttachedToPoint("SEAT"))Sitting = true;
	
	if(Sitting)this.SetOffset(Vec2f(0,0));

	const u8 knocked = getKnocked(blob);

	RunnerMoveVars@ moveVars;
	if (!blob.get("moveVars", @moveVars))
	{
		return;
	}

	
	if (knocked > 0 && !LyingDown)
	{
		this.animation.frame = 2;
	}
	else if (inair)
	{
		
		f32 vy = blob.getVelocity().y;
		if (vy < -0.0f && moveVars.walljumped)
		{
			this.SetAnimation("run");
		}
		else
		{
			this.SetAnimation("fall");
			this.animation.timer = 0;
		}
	}
	
	///////////////////////////////////////////Offsets
	
	if(Crawling)this.animation.frame = 3;
	
	Vec2f MainArmOffset = DefaultMainArmOffset;
	Vec2f SubArmOffset = DefaultSubArmOffset;
	Vec2f FrontLegOffset = DefaultFrontLegOffset;
	Vec2f BackLegOffset = DefaultBackLegOffset;
	
	//blob.Tag("force_offset_reload");
	
	if(true){
	
		if(blob.exists("MA_offset_cache") && blob.exists("SA_offset_cache") && blob.exists("FL_offset_cache") && blob.exists("BL_offset_cache") && !blob.hasTag("force_offset_reload")){
		
			MainArmOffset = blob.get_Vec2f("MA_offset_cache");
			SubArmOffset = blob.get_Vec2f("SA_offset_cache");
			FrontLegOffset = blob.get_Vec2f("FL_offset_cache");
			BackLegOffset = blob.get_Vec2f("BL_offset_cache");
			
		
		} else {
			string tex_name = this.getFilename();
			if(Texture::exists(tex_name)){
				SColor[] colours = {SColor(64,255,0,0),SColor(64,0,255,0),SColor(64,0,0,255),SColor(64,0,255,255)};
				PixelOffsets@ Poffsets = getPixelOffsetsForTexture(tex_name, Vec2f(32,32), colours);
				
				Vec2f[] MA_offsets = Poffsets.getOffsets(Vec2f(32,32),SColor(64,255,0,0),0);
				if(MA_offsets.length > 0)blob.set_Vec2f("MA_offset_cache",Vec2f(-MA_offsets[0].x+13,MA_offsets[0].y-15));
				
				Vec2f[] SA_offsets = Poffsets.getOffsets(Vec2f(32,32),SColor(64,0,255,0),0);
				if(SA_offsets.length > 0)blob.set_Vec2f("SA_offset_cache",Vec2f(-SA_offsets[0].x+18,SA_offsets[0].y-15));
				
				Vec2f[] FL_offsets = Poffsets.getOffsets(Vec2f(32,32),SColor(64,0,0,255),0);
				if(FL_offsets.length > 0)blob.set_Vec2f("FL_offset_cache",Vec2f(-FL_offsets[0].x+15,FL_offsets[0].y-20));
				
				Vec2f[] BL_offsets = Poffsets.getOffsets(Vec2f(32,32),SColor(64,0,255,255),0);
				if(BL_offsets.length > 0)blob.set_Vec2f("BL_offset_cache",Vec2f(-BL_offsets[0].x+19,BL_offsets[0].y-20));
				//else if(FL_offsets.length > 0)blob.set_Vec2f("BL_offset_cache",Vec2f(-FL_offsets[0].x,-FL_offsets[0].y));
			
				blob.Untag("force_offset_reload");
			
			} else Texture::createFromFile(tex_name, this.getFilename());
		}
		
	}
	
	MainArmOffset += this.getOffset();
	SubArmOffset += this.getOffset();
	FrontLegOffset += this.getOffset();
	BackLegOffset += this.getOffset();
	
	if(this.animation.frame == 2){
		MainArmOffset += Vec2f(0,1.0f);
		SubArmOffset += Vec2f(0,1.0f);
	}
	if(this.animation.frame == 3){
		MainArmOffset = DefaultMainArmOffset+Vec2f(-3.0f,3.0f);
		SubArmOffset = DefaultSubArmOffset+Vec2f(1.0f,4.0f);
	}
	
	
	AttachmentPoint@ waistslot = blob.getAttachments().getAttachmentPointByName("WAIST");
	if(waistslot !is null){
		waistslot.offset = this.getOffset()+Vec2f(-4,6);
		waistslot.offsetZ = this.getZ()-1.8f;
	}
	AttachmentPoint@ backslot = blob.getAttachments().getAttachmentPointByName("BACK");
	if(backslot !is null){
		backslot.offset = this.getOffset()+Vec2f(-4,-1);
		backslot.offsetZ = this.getZ()-4.0f;
	}
	
	//////////////////////////////////Leg handlin
	
	bool FrontLegVisible = Visible;
	bool BackLegVisible = Visible;
	
	if(limbs.FrontLeg == BodyType::None)FrontLegVisible = false;
	if(limbs.BackLeg == BodyType::None)BackLegVisible = false;
	
	CSpriteLayer@ FrontLeg = this.getSpriteLayer("frontleg");
	CSpriteLayer@ BackLeg = this.getSpriteLayer("backleg");
	
	FrontLeg.SetVisible(FrontLegVisible);
	BackLeg.SetVisible(BackLegVisible);
	
	FrontLeg.SetOffset(FrontLegOffset);
	BackLeg.SetOffset(BackLegOffset);
	
	FrontLeg.ResetTransform();
	BackLeg.ResetTransform();
	
	if(LyingDown){
		FrontLeg.SetOffset(FrontLegOffset+Vec2f(-10,0));
		BackLeg.SetOffset(BackLegOffset+Vec2f(-10,0));
		FrontLeg.SetAnimation("lie"); //Liar, liar, pants on fire
		BackLeg.SetAnimation("lie");
	}
	else
	if(Crawling){
		FrontLeg.SetOffset(FrontLegOffset+Vec2f(6,13));
		BackLeg.SetOffset(BackLegOffset+Vec2f(3,12));
		FrontLeg.SetAnimation("lie");
		BackLeg.SetAnimation("lie");
		
		FrontLeg.RotateBy(180, Vec2f(0,0));
		BackLeg.RotateBy(180, Vec2f(0,0));
	}
	else 
	if(Sitting){
		FrontLeg.SetAnimation("sitting");
		BackLeg.SetAnimation("sitting");
	}
	else
	if(Crouching){
		FrontLeg.SetAnimation("crouch");
		BackLeg.SetAnimation("crouch");
	}
	else
	if ((left || right) || (blob.isOnLadder() && (up || down)))
	{
		FrontLeg.SetAnimation("run");
		BackLeg.SetAnimation("run");
		
		FrontLeg.getAnimation("run").time = 3.0f/Maths::Max(moveVars.walkFactor,0.01f);
		BackLeg.getAnimation("run").time = 3.0f/Maths::Max(moveVars.walkFactor,0.01f);;
	}
	else 
	{
		if(true)
			FrontLeg.SetAnimation("default");
		else
			FrontLeg.SetAnimation("broken");
			
		if(true)
			BackLeg.SetAnimation("default");
		else
			BackLeg.SetAnimation("broken");
	}

	
	
	///////////////////////////////Arm handlin
	Vec2f vec = blob.getAimPos() - blob.getPosition();
	f32 angle = -vec.Angle();
	
	if (this.isFacingLeft())
	{
		angle = 180.0f + angle;
	}

	if(angle > 180.0f)
	{
		angle -= 360.0f;
	} else
	if (angle < -180.0f)
	{
		angle += 360.0f;
	}
	
	bool mainarmvisible = Visible;
	bool subarmvisible = Visible;

	if(limbs.MainArm == BodyType::None)mainarmvisible = false;
	if(limbs.SubArm == BodyType::None)subarmvisible = false;

	int Down = 90;
	if (this.isFacingLeft())Down = 270;
	
	this.getSpriteLayer("frontarm").SetOffset(MainArmOffset);
	this.getSpriteLayer("backarm").SetOffset(SubArmOffset);
	
	int Wobble = (FrontLeg.getFrame()-1);
	if(!FrontLeg.isAnimation("default")){
		if(Crawling)if(left || right)Wobble = (getGameTime()/3) % 4;
		if(Wobble == 2)Wobble = 0;
		else if(Wobble == 3)Wobble = -1;
		else if(Wobble > 3) Wobble = 0;
	} else Wobble = 0;
	
	bool action2 = blob.isKeyPressed(key_action2);
	bool action1 = blob.isKeyPressed(key_action1);
	
	if(blob.getCarriedBlob() !is null){
		action1 = false;
		action2 = false;
	}
	
	bool aimingMain = action1;
	bool aimingSub = action2;
	
	bool shielding = blob.hasTag("shielding");
	int bowcharge = 0;
	if(hasArchery)bowcharge = archer.charge_time;
	if(bowcharge > 0){ //bow
		aimingMain = true;
		aimingSub = true;
	}
	
	bool showEquipment = true;

	if(LyingDown){
		showEquipment = false;
		setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 0, Vec2f(0, 0), "default");
		this.getSpriteLayer("frontarm").SetOffset(Vec2f(-3,5.5f));
		//this.getSpriteLayer("frontarm").SetOffset(Vec2f(MainArmOffset.y,MainArmOffset.x));
		//print("");
		
		setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 0, Vec2f(0, 0), "default");
		this.getSpriteLayer("backarm").SetOffset(Vec2f(-3,2));
		//this.getSpriteLayer("backarm").SetOffset(Vec2f(SubArmOffset.y,SubArmOffset.x));
	} else
	if (knocked > 0){
		if(!Crawling) //can stand
		{
			if(this.isFacingLeft()){
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down+40, Vec2f(0, 0), "default");
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down+40, Vec2f(0, 0), "default");
			} else {
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down-40, Vec2f(0, 0), "default");
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down-40, Vec2f(0, 0), "default");
			}
		}
	} else
	if(blob.getCarriedBlob() !is null){
		int Carry = -20;
		if (this.isFacingLeft())Carry = 20;
		
		setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down+Carry*2, Vec2f(0, 0), "default");
		setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down+Carry, Vec2f(0, 0), "default");
	} else {
		if (is_emote(blob, 255, true))setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(0, 0), "point");
		else setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down+Wobble*20, Vec2f(0, 0), "default");
		setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down-Wobble*20, Vec2f(0, 0), "default");
	}
	
	CSpriteLayer@ main_equip = this.getSpriteLayer("main_equip");
	CSpriteLayer@ sub_equip = this.getSpriteLayer("sub_equip");
	
	if(blob.hasTag("reload_equipment")){
		int team = getPlayerBlobColour(blob);
	
		main_equip.ReloadSprite("equipment.png", 32, 32, team, 0);
		sub_equip.ReloadSprite("equipment.png", 32, 32, team, 0);
		
		this.getSpriteLayer("front_shield").ReloadSprite("Shield.png", 32, 32, team, 0);
		this.getSpriteLayer("back_shield").ReloadSprite("Shield.png", 32, 32, team, 0);
	
		blob.Untag("reload_equipment");
	}

	 //Make all equipment invisible
	setAimValues(this,main_equip, false, 0, Vec2f(0, 0), "default");
	setAimValues(this,sub_equip, false, 0, Vec2f(0, 0), "default");
	main_equip.SetRelativeZ(2.0f);
	sub_equip.SetRelativeZ(-2.0f);
	
	setAimValues(this,this.getSpriteLayer("front_shield"), false, 0, Vec2f(0, 0), "default");
	setAimValues(this,this.getSpriteLayer("back_shield"), false, 0, Vec2f(0, 0), "default");
	
	if(showEquipment){
	
		EquipmentInfo@ equip;
		if (!blob.get("equipInfo", @equip))return;
	
		int inverse = -1;
		if(this.isFacingLeft())inverse = 1;
	
		switch(equip.MainHand){
			
			case Equipment::None:{
				f32 punch = equip.mainSwingTimer;
				if(punch > 30)punch = -30+(punch-30);
				else punch = punch/2;
				if(equip.mainSwingTimer > 0){
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(0, 0), "stretch");
					
					f32 RadAngle = float(-vec.Angle())/1000*17.4;
					this.getSpriteLayer("frontarm").SetOffset(MainArmOffset+Vec2f(Maths::Cos(RadAngle)*punch*-0.15*inverse,Maths::Sin(RadAngle)*punch*-0.15));
				}
			break;}
			
			case Equipment::Pole:{
				f32 pole = equip.mainSwingTimer;
				if(pole > 0){
					if(pole > 20)pole = -70+(pole-20);
					
					f32 RadAngle = float(-vec.Angle())/1000*17.4;
					
					main_equip.SetOffset(MainArmOffset+Vec2f(0,3.5f)+Vec2f(Maths::Cos(RadAngle)*pole*-0.3*inverse,Maths::Sin(RadAngle)*pole*-0.3));

					setWeaponAim(this,main_equip, true, angle, Vec2f(0, 0), "pole",equip.MainHandType);
					
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down-pole*inverse, Vec2f(0, 0), "default");
				} else {
					setWeaponAim(this,main_equip, true, 135*inverse, Vec2f(0, 0), "pole",equip.MainHandType);
					main_equip.SetOffset(Vec2f(2.0f,2.0f)+this.getOffset());
					main_equip.SetRelativeZ(-5.0f);
				}
			break;}
			
			case Equipment::Pick:{
				f32 swing = equip.mainSwingTimer;
				if(swing > 0){
					if(swing > 100)swing = 100-((swing-100)*5);
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle-70.0f*inverse+swing*inverse*2.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,main_equip, true, angle-70.0f*inverse+swing*inverse*2.0f, Vec2f(0, 0), "pick",equip.MainHandType);
					main_equip.SetOffset(MainArmOffset);
				} else {
					setWeaponAim(this,main_equip, true, 45*inverse, Vec2f(0, 0), "pick",equip.MainHandType);
					main_equip.SetOffset(Vec2f(4.0f,8.0f)+this.getOffset());
					main_equip.SetRelativeZ(-5.0f);
				}
			break;}
			
			case Equipment::Axe:{
				f32 swing = equip.mainSwingTimer;
				if(swing != 0){
					if(swing > 30)swing = 30 + (swing-30.0f)/2.0f;
					if(swing < 0)swing = 30+swing;
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle-70.0f*inverse+swing*inverse*4.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,main_equip, true, angle-70.0f*inverse+swing*inverse*4.0f, Vec2f(0, 0), "axe",equip.MainHandType);
					main_equip.SetOffset(MainArmOffset);
				} else {
					setWeaponAim(this,main_equip, true, 45*inverse, Vec2f(0, 0), "axe",equip.MainHandType);
					main_equip.SetOffset(Vec2f(4.0f,8.0f)+this.getOffset());
					main_equip.SetRelativeZ(-5.0f);
				}
			break;}
			
			case Equipment::Hammer:{
				f32 swing = equip.mainSwingTimer;
				if(swing != 0){
					if(swing > 30)swing = 30 + (swing-30.0f)/2.0f;
					if(swing < 0)swing = 30+swing;
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle-70.0f*inverse+swing*inverse*4.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,main_equip, true, angle-70.0f*inverse+swing*inverse*4.0f, Vec2f(0, 0), "hammer",equip.MainHandType);
					main_equip.SetOffset(MainArmOffset);
				} else {
					setWeaponAim(this,main_equip, true, 45*inverse, Vec2f(0, 0), "hammer",equip.MainHandType);
					main_equip.SetOffset(Vec2f(4.0f,8.0f)+this.getOffset());
					main_equip.SetRelativeZ(-5.0f);
				}
			break;}
			
			case Equipment::Sword:{
				f32 swing = equip.mainSwingTimer;
				
				setWeaponAim(this,main_equip, true, 120*inverse, Vec2f(0, 0), "sword",equip.MainHandType);
				main_equip.SetOffset(Vec2f(0.0f,10.0f)+this.getOffset());
				
				if(swing > 0 && swing < 15){
					f32 ang = vec.Angle();
					if(ang < 155 && ang > 90)ang = 155;
					if(ang > 25 && ang <= 90)ang = 25;
					f32 RadAngle = float(-ang)/1000*17.4;
					
					main_equip.SetOffset(MainArmOffset+Vec2f(7.0f,2.0f)+Vec2f(Maths::Cos(RadAngle)*swing*-0.2*inverse,Maths::Sin(RadAngle)*swing*-0.2));

					ang = angle;
					if(ang < -25)ang = -25;
					if(ang > 25)ang = 25;
					setWeaponAim(this,main_equip, true, ang-90*inverse, Vec2f(5*inverse, 2), "sword",equip.MainHandType);
					
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down-swing*2.0f*inverse, Vec2f(0, 0), "default");
				} else 
				if(swing >= 15){
					if(swing < 38){
						swing -= 15;
						if(swing > 8)swing = 8;
					} else {
						swing -= 30;
						if(swing > 12)swing = 12;
					}
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, -80.0f*inverse+swing*inverse*20.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,main_equip, true, -80.0f*inverse+swing*inverse*20.0f, Vec2f(0, 0), "sword",equip.MainHandType);
					main_equip.SetOffset(MainArmOffset);
				}
				if(swing < 0 && swing >= -15){
					f32 ang = vec.Angle();
					if(ang < 155 && ang > 90)ang = 155;
					if(ang > 25 && ang <= 90)ang = 25;
					f32 RadAngle = float(-ang)/1000*17.4;
					
					
					main_equip.SetOffset(MainArmOffset+Vec2f(7.0f,2.0f)+Vec2f(Maths::Cos(RadAngle)*swing*-0.3*inverse,Maths::Sin(RadAngle)*swing*-0.3));
					
					ang = angle;
					if(ang < -25)ang = -25;
					if(ang > 25)ang = 25;
					setWeaponAim(this,main_equip, true, ang-90*inverse, Vec2f(5*inverse, 2), "sword",equip.MainHandType);
					
					
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down-swing*2.0f*inverse, Vec2f(0, 0), "default");
				}
				if(swing < -15 && swing >= -60){
					swing += 60;
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 80.0f*inverse-swing*inverse*30.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,main_equip, true, 80.0f*inverse-swing*inverse*30.0f, Vec2f(0, 0), "sword",equip.MainHandType);
					main_equip.SetOffset(MainArmOffset);
				}
				if(swing < -80 && swing >= -90){
					swing += 90;
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 80.0f*inverse-swing*inverse*30.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,main_equip, true, 80.0f*inverse-swing*inverse*30.0f, Vec2f(0, 0), "sword",equip.MainHandType);
					main_equip.SetOffset(MainArmOffset);
				}
			break;}
			
			case Equipment::Knife:{
				f32 swing = equip.mainSwingTimer;
				
				setWeaponAim(this,main_equip, true, 120*inverse, Vec2f(0, 0), "knife",equip.MainHandType);
				main_equip.SetOffset(Vec2f(0.0f,10.0f)+this.getOffset());
				
				if(swing > 0){
					if(swing > 15)swing = 15;
					
					f32 ang = vec.Angle();
					if(ang < 155 && ang > 90)ang = 155;
					if(ang > 25 && ang <= 90)ang = 25;
					f32 RadAngle = float(-ang)/1000*17.4;
					
					main_equip.SetOffset(MainArmOffset+Vec2f(7.0f,2.0f)+Vec2f(Maths::Cos(RadAngle)*swing*-0.2*inverse,Maths::Sin(RadAngle)*swing*-0.2));

					ang = angle;
					if(ang < -25)ang = -25;
					if(ang > 25)ang = 25;
					setWeaponAim(this,main_equip, true, ang-90*inverse, Vec2f(5*inverse, 2), "knife",equip.MainHandType);
					
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down-swing*2.0f*inverse, Vec2f(0, 0), "default");
				}
				
				if(swing < 0){
					if(swing <= -35)swing += 35;
					
					f32 ang = vec.Angle();
					if(ang < 155 && ang > 90)ang = 155;
					if(ang > 25 && ang <= 90)ang = 25;
					f32 RadAngle = float(-ang)/1000*17.4;
					
					
					main_equip.SetOffset(MainArmOffset+Vec2f(7.0f,2.0f)+Vec2f(Maths::Cos(RadAngle)*swing*-0.3*inverse,Maths::Sin(RadAngle)*swing*-0.3));
					
					ang = angle;
					if(ang < -25)ang = -25;
					if(ang > 25)ang = 25;
					setWeaponAim(this,main_equip, true, ang-90*inverse, Vec2f(5*inverse, 2), "knife",equip.MainHandType);
					
					
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down-swing*2.0f*inverse, Vec2f(0, 0), "default");
				}
			break;}
			
			case Equipment::Shield:{
				this.getSpriteLayer("front_shield").SetFrameIndex(equip.MainHandType);
				this.getSpriteLayer("front_shield").SetOffset(MainArmOffset);
				this.getSpriteLayer("front_shield").SetRelativeZ(101.0f);
				if(equip.mainSwingTimer == 1){
					if(vec.Angle() > 45 && vec.Angle() < 135){
						setAimValues(this,this.getSpriteLayer("front_shield"), true, 0, Vec2f(0, 0), "raised");
						if(this.isFacingLeft()){
							setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 110, Vec2f(0, 0), "stretch");
						} else {
							setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 250, Vec2f(0, 0), "stretch");
						}
					} else
					if(vec.Angle() > 270-45 && vec.Angle() < 270+45){
						setAimValues(this,this.getSpriteLayer("front_shield"), true, 0, Vec2f(0, 0), "slide");
						
						if(this.animation.frame == 0)this.animation.frame = 2;
						
						this.getSpriteLayer("frontarm").SetOffset(MainArmOffset+Vec2f(0,2));
						this.getSpriteLayer("backarm").SetOffset(SubArmOffset+Vec2f(0,2));
						
						if(this.isFacingLeft()){
							setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 290, Vec2f(0, 0), "stretch");
						} else {
							setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 70, Vec2f(0, 0), "stretch");
						}
					} else {
						setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(0, 0), "stretch");
						setAimValues(this,this.getSpriteLayer("front_shield"), true, angle, Vec2f(0, 0), "default");
					}
				} else {
					setAimValues(this,this.getSpriteLayer("front_shield"), true, Wobble*20, Vec2f(0, 0), "rest");
				}
			break;}
			
			case Equipment::ZombieHands:{
				if(!LyingDown){
					int swing = 0;
					Wobble = (getGameTime()/30) % 4;
					if(isNight())Wobble = (getGameTime()/3) % 4;
					if(Wobble == 2)Wobble = 0;
					else if(Wobble == 3)Wobble = -1;
					else if(Wobble > 3) Wobble = 0;
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, swing*inverse-Wobble*20, Vec2f(0, 0), "stretch");
				}
			break;}
			
			case Equipment::GreatSword:{
				f32 swing = equip.mainSwingTimer;
				if(swing > 0){
					if(swing >= 15){
						if(swing < 38){
							if(swing > 15)swing = 15;
						} else {
							swing -= 23;
							if(swing > 23)swing = 23;
						}
					}
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, -80.0f*inverse+swing*inverse*10.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,main_equip, true, -80.0f*inverse+swing*inverse*10.0f, Vec2f(0, 10), "great_sword",equip.MainHandType);
					main_equip.SetOffset(MainArmOffset+Vec2f(0,-10));
				} else
				if(swing < 0){
					if(swing >= -15){
						f32 ang = vec.Angle();
						if(ang < 155 && ang > 90)ang = 155;
						if(ang > 25 && ang <= 90)ang = 25;
						f32 RadAngle = float(-ang)/1000*17.4;
						
						
						main_equip.SetOffset(MainArmOffset+Vec2f(7.0f,2.0f)+Vec2f(Maths::Cos(RadAngle)*swing*-1.5f*inverse,Maths::Sin(RadAngle)*swing*-0.3));
						
						ang = angle;
						if(ang < -25)ang = -25;
						if(ang > 25)ang = 25;
						setWeaponAim(this,main_equip, true, ang-90*inverse, Vec2f(5*inverse, 2), "great_sword",equip.MainHandType);
						
						
						setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down-swing*2.0f*inverse, Vec2f(0, 0), "default");
					} else {
						if(swing < -15 && swing >= -60)swing += 60;
						if(swing < -80 && swing >= -90)swing += 90;
					
						if(swing > 0){
							setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 80.0f*inverse-swing*inverse*30.0f, Vec2f(0, 0), "stretch");
							setWeaponAim(this,main_equip, true, 80.0f*inverse-swing*inverse*30.0f, Vec2f(0, 10), "great_sword",equip.MainHandType);
							main_equip.SetOffset(MainArmOffset+Vec2f(0,-10));
						}
					}
				} else
				if(swing == 0){
					if(equip.MainHandType != 3){
						setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down+20*inverse, Vec2f(0, 0), "default");
						setWeaponAim(this,main_equip, true, 180+Down+20*inverse, Vec2f(0, 0), "great_sword",equip.MainHandType);
						main_equip.SetOffset(MainArmOffset+Vec2f(9,11));
					} else {
						setWeaponAim(this,main_equip, true, 45*inverse, Vec2f(0, 0), "great_sword",equip.MainHandType);
						main_equip.SetOffset(Vec2f(7.0f,6.0f)+this.getOffset());
						main_equip.SetRelativeZ(-5.0f);
					}
				}
			break;}
		
		}
		
		switch(equip.SubHand){
			
			case Equipment::None:{
				f32 punch = equip.subSwingTimer;
				if(punch > 30)punch = -30+(punch-30);
				else punch = punch/2;
				if(equip.subSwingTimer > 0){
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle, Vec2f(0, 0), "stretch");
					
					f32 RadAngle = float(-vec.Angle())/1000*17.4;
					this.getSpriteLayer("backarm").SetOffset(SubArmOffset+Vec2f(Maths::Cos(RadAngle)*punch*-0.15*inverse,Maths::Sin(RadAngle)*punch*-0.15));
				}
			break;}
			
			case Equipment::Pole:{
				f32 pole = equip.subSwingTimer;
				if(pole > 0){
					if(pole > 20)pole = -70+(pole-20);
					
					f32 RadAngle = float(-vec.Angle())/1000*17.4;
					
					sub_equip.SetOffset(SubArmOffset+Vec2f(0,3.5f)+Vec2f(Maths::Cos(RadAngle)*pole*-0.3*inverse,Maths::Sin(RadAngle)*pole*-0.3));

					setWeaponAim(this,sub_equip, true, angle, Vec2f(0, 0), "pole",equip.SubHandType);
					
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down-pole*inverse, Vec2f(0, 0), "default");
				} else {
					setWeaponAim(this,sub_equip, true, 45*inverse, Vec2f(0, 0), "pole",equip.SubHandType);
					sub_equip.SetOffset(Vec2f(0,2.0f)+this.getOffset());
					sub_equip.SetRelativeZ(-5.0f);
				}
			break;}
			
			case Equipment::Pick:{
				f32 swing = equip.subSwingTimer;
				if(swing > 0){
					if(swing > 100)swing = 100-((swing-100)*5);
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle-70.0f*inverse+swing*inverse*2.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,sub_equip, true, angle-70.0f*inverse+swing*inverse*2.0f, Vec2f(0, 0), "pick",equip.SubHandType);
					sub_equip.SetOffset(SubArmOffset);
				} else {
					setWeaponAim(this,sub_equip, true, -45*inverse, Vec2f(0, 0), "pick",equip.SubHandType);
					sub_equip.SetOffset(Vec2f(5.0f,1.0f)+this.getOffset());
					sub_equip.SetRelativeZ(-5.0f);
					
				}
			break;}
			
			case Equipment::Axe:{
				f32 swing = equip.subSwingTimer;
				if(swing != 0){
					if(swing > 30)swing = 30 + (swing-30.0f)/2.0f;
					if(swing < 0)swing = 30+swing;
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle-70.0f*inverse+swing*inverse*4.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,sub_equip, true, angle-70.0f*inverse+swing*inverse*4.0f, Vec2f(0, 0), "axe",equip.SubHandType);
					sub_equip.SetOffset(SubArmOffset);
				} else {
					setWeaponAim(this,sub_equip, true, -45*inverse, Vec2f(0, 0), "axe",equip.SubHandType);
					sub_equip.SetOffset(Vec2f(5.0f,1.0f)+this.getOffset());
					sub_equip.SetRelativeZ(-5.0f);
					
				}
			break;}
			
			case Equipment::Hammer:{ 
				f32 swing = equip.subSwingTimer;
				if(swing != 0){
					if(swing > 30)swing = 30 + (swing-30.0f)/2.0f;
					if(swing < 0)swing = 30+swing;
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle-70.0f*inverse+swing*inverse*4.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,sub_equip, true, angle-70.0f*inverse+swing*inverse*4.0f, Vec2f(0, 0), "hammer",equip.SubHandType);
					sub_equip.SetOffset(SubArmOffset);
				} else {
					setWeaponAim(this,sub_equip, true, -45*inverse, Vec2f(0, 0), "hammer",equip.SubHandType);
					sub_equip.SetOffset(Vec2f(5.0f,1.0f)+this.getOffset());
					sub_equip.SetRelativeZ(-5.0f);
					
				}
			break;}
			
			case Equipment::Sword:{
				setWeaponAim(this,sub_equip, true, 120*inverse, Vec2f(0, 0), "sword",equip.SubHandType);
				sub_equip.SetOffset(Vec2f(-6.0f,10.0f)+this.getOffset());
				
				f32 swing = equip.subSwingTimer;
				if(swing > 0 && swing < 15){
					f32 ang = vec.Angle();
					if(ang < 155 && ang > 90)ang = 155;
					if(ang > 25 && ang <= 90)ang = 25;
					f32 RadAngle = float(-ang)/1000*17.4;
					
					sub_equip.SetOffset(SubArmOffset+Vec2f(7.0f,2.0f)+Vec2f(Maths::Cos(RadAngle)*swing*-0.2*inverse,Maths::Sin(RadAngle)*swing*-0.2));

					ang = angle;
					if(ang < -25)ang = -25;
					if(ang > 25)ang = 25;
					setWeaponAim(this,sub_equip, true, ang-90*inverse, Vec2f(5*inverse, 2), "sword",equip.SubHandType);
					
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down-swing*2.0f*inverse, Vec2f(0, 0), "default");
				} else 
				if(swing >= 15){
					if(swing < 38){
						swing -= 15;
						if(swing > 8)swing = 8;
					} else {
						swing -= 30;
						if(swing > 12)swing = 12;
					}
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, -80.0f*inverse+swing*inverse*20.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,sub_equip, true, -80.0f*inverse+swing*inverse*20.0f, Vec2f(0, 0), "sword",equip.SubHandType);
					sub_equip.SetOffset(SubArmOffset);
				}
				
				if(swing < 0 && swing >= -15){
					f32 ang = vec.Angle();
					if(ang < 155 && ang > 90)ang = 155;
					if(ang > 25 && ang <= 90)ang = 25;
					f32 RadAngle = float(-ang)/1000*17.4;
					
					
					sub_equip.SetOffset(SubArmOffset+Vec2f(7.0f,2.0f)+Vec2f(Maths::Cos(RadAngle)*swing*-0.3*inverse,Maths::Sin(RadAngle)*swing*-0.3));
					
					ang = angle;
					if(ang < -25)ang = -25;
					if(ang > 25)ang = 25;
					setWeaponAim(this,sub_equip, true, ang-90*inverse, Vec2f(5*inverse, 2), "sword",equip.SubHandType);
					
					
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down-swing*2.0f*inverse, Vec2f(0, 0), "default");
				}
				
				if(swing < -15 && swing >= -60){
					swing += 60;
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 80.0f*inverse-swing*inverse*30.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,sub_equip, true, 80.0f*inverse-swing*inverse*30.0f, Vec2f(0, 0), "sword",equip.SubHandType);
					sub_equip.SetOffset(SubArmOffset);
				}
				if(swing < -80 && swing >= -90){
					swing += 90;
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 80.0f*inverse-swing*inverse*30.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,sub_equip, true, 80.0f*inverse-swing*inverse*30.0f, Vec2f(0, 0), "sword",equip.SubHandType);
					sub_equip.SetOffset(SubArmOffset);
				}
			break;}
			
			case Equipment::Knife:{
				f32 swing = equip.subSwingTimer;
				
				setWeaponAim(this,sub_equip, true, 120*inverse, Vec2f(0, 0), "knife",equip.SubHandType);
				sub_equip.SetOffset(Vec2f(-6.0f,10.0f)+this.getOffset());
				
				if(swing > 0){
					if(swing > 15)swing = 15;
					
					f32 ang = vec.Angle();
					if(ang < 155 && ang > 90)ang = 155;
					if(ang > 25 && ang <= 90)ang = 25;
					f32 RadAngle = float(-ang)/1000*17.4;
					
					sub_equip.SetOffset(SubArmOffset+Vec2f(7.0f,2.0f)+Vec2f(Maths::Cos(RadAngle)*swing*-0.2*inverse,Maths::Sin(RadAngle)*swing*-0.2));

					ang = angle;
					if(ang < -25)ang = -25;
					if(ang > 25)ang = 25;
					setWeaponAim(this,sub_equip, true, ang-90*inverse, Vec2f(5*inverse, 2), "knife",equip.SubHandType);
					
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down-swing*2.0f*inverse, Vec2f(0, 0), "default");
				}
				
				if(swing < 0){
					if(swing <= -35)swing += 35;
					
					f32 ang = vec.Angle();
					if(ang < 155 && ang > 90)ang = 155;
					if(ang > 25 && ang <= 90)ang = 25;
					f32 RadAngle = float(-ang)/1000*17.4;
					
					
					sub_equip.SetOffset(SubArmOffset+Vec2f(7.0f,2.0f)+Vec2f(Maths::Cos(RadAngle)*swing*-0.3*inverse,Maths::Sin(RadAngle)*swing*-0.3));
					
					ang = angle;
					if(ang < -25)ang = -25;
					if(ang > 25)ang = 25;
					setWeaponAim(this,sub_equip, true, ang-90*inverse, Vec2f(5*inverse, 2), "knife",equip.SubHandType);
					
					
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down-swing*2.0f*inverse, Vec2f(0, 0), "default");
				}
			break;}
			
			case Equipment::Shield:{
				this.getSpriteLayer("back_shield").SetFrameIndex(equip.SubHandType);
				this.getSpriteLayer("back_shield").SetOffset(SubArmOffset);
				
				if(equip.subSwingTimer == 1){
					this.getSpriteLayer("back_shield").SetRelativeZ(1.9f);

					if(vec.Angle() > 45 && vec.Angle() < 135){
						setAimValues(this,this.getSpriteLayer("back_shield"), true, 0, Vec2f(0, 0), "raised");
						this.getSpriteLayer("back_shield").SetOffset(MainArmOffset-Vec2f(4,0));
						
						if(this.isFacingLeft()){
							setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 70, Vec2f(0, 0), "stretch");
						} else {
							setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 290, Vec2f(0, 0), "stretch");
						}
					} else
					if(vec.Angle() > 270-45 && vec.Angle() < 270+45){
						setAimValues(this,this.getSpriteLayer("back_shield"), true, 0, Vec2f(0, 0), "slide");
						this.getSpriteLayer("back_shield").SetOffset(MainArmOffset-Vec2f(4,0));
						
						if(this.animation.frame == 0)this.animation.frame = 2;
						
						this.getSpriteLayer("backarm").SetOffset(SubArmOffset+Vec2f(0,2));
						
						if(this.isFacingLeft()){
							setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 290, Vec2f(0, 0), "stretch");
						} else {
							setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 70, Vec2f(0, 0), "stretch");
						}
					} else {
						setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle, Vec2f(0, 0), "stretch");
						setAimValues(this,this.getSpriteLayer("back_shield"), true, angle, Vec2f(0, 0), "default");
					}
				} else {
					setAimValues(this,this.getSpriteLayer("back_shield"), true, Wobble*-20, Vec2f(0, 0), "rest");
					this.getSpriteLayer("back_shield").SetRelativeZ(-4.0f);
				}
			break;}
			
			case Equipment::ZombieHands:{
				if(!LyingDown){
					int swing = 0;
					Wobble = (getGameTime()/30) % 4;
					if(isNight())Wobble = (getGameTime()/3) % 4;
					if(Wobble == 2)Wobble = 0;
					else if(Wobble == 3)Wobble = -1;
					else if(Wobble > 3) Wobble = 0;
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, swing*inverse+Wobble*20, Vec2f(0, 0), "stretch");
				}
			break;}
		
		}

		if(hasArchery){
			if(archer.grappling){ ///Grappleing
				Vec2f off = archer.grapple_pos - blob.getPosition();
				int grappleAngle = -off.Angle();
				if (this.isFacingLeft())
				{
					grappleAngle = 180.0f + grappleAngle;
				}
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, grappleAngle, Vec2f(0, 0), "stretch");
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, grappleAngle, Vec2f(0, 0), "stretch");
			}
		
			if(bowcharge > 0){
				if(bowcharge < 10)this.getSpriteLayer("bow").SetFrameIndex(0);
				else if(bowcharge <= 20)this.getSpriteLayer("bow").SetFrameIndex(1);
				else this.getSpriteLayer("bow").SetFrameIndex(2);
				
				if(!this.isFacingLeft())setAimValues(this,this.getSpriteLayer("bow"), true, angle, Vec2f(-0.0, 0), "default");
				else setAimValues(this,this.getSpriteLayer("bow"), true, angle, Vec2f(0.0, 0), "default");
				
				f32 offset = 3;
				
				if(this.getSpriteLayer("bow").getFrameIndex() == 0)offset = 1;
				if(this.getSpriteLayer("bow").getFrameIndex() == 1)offset = 3;
				if(this.getSpriteLayer("bow").getFrameIndex() == 2)offset = 5;
				if(this.getSpriteLayer("bow").getFrameIndex() == 3)offset = 5;
				
				this.getSpriteLayer("frontarm").SetOffset(MainArmOffset+Vec2f(offset,0));
				this.getSpriteLayer("bow").SetOffset(MainArmOffset);
				
				
				if(!this.isFacingLeft())offset = -offset;

				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(offset, 0), "open_hand");
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle, Vec2f(0, 0), "stretch");
			} else {
				setAimValues(this,this.getSpriteLayer("bow"), false, angle, Vec2f(0, 0), "default");
			}
		
		}
	}

	//////////////////////////////set head
	
	if(LyingDown){
		blob.Tag("sleep head");
	} else
	if (knocked > 0) //Are we stunned?
	{
		blob.Tag("dead head"); //Use the 'dead' head.
		blob.Untag("attack head");
		blob.Untag("sleep head");
	}else
	if(limbs.Head == BodyType::Golem || limbs.Head == BodyType::Wood || limbs.Head == BodyType::Metal || limbs.Head == BodyType::Gold){
		blob.Untag("attack head");
		blob.Untag("dead head");
		blob.Untag("sleep head");
	} else 
	if(!blob.hasTag("alive") && !blob.hasTag("animated")) //Are we dead?
	{
		blob.Tag("dead head"); //Use the 'dead' head.
		blob.Untag("sleep head");
	}
	else if (blob.isInFlames()) //Are we on fire?
	{
		blob.Tag("attack head"); //Set our head to the 'attack' head
		blob.Untag("dead head"); //Unset our head from 'dead' head.
		blob.Untag("sleep head");
	}
	else //Other wise
	{
		blob.Untag("attack head");  //Unset 'attack' head
		blob.Untag("dead head");
		blob.Untag("sleep head");		//Unset 'dead' head
		//This'll make our head normal
	}
}

///Graple
void doRopeUpdate(CSprite@ this, CBlob@ blob, ArcherInfo@ archer)
{
	CSpriteLayer@ rope = this.getSpriteLayer("rope");
	CSpriteLayer@ hook = this.getSpriteLayer("hook");

	bool visible = archer !is null && archer.grappling;

	rope.SetVisible(visible);
	hook.SetVisible(visible);
	if (!visible)
	{
		return;
	}

	Vec2f adjusted_pos = Vec2f(archer.grapple_pos.x, Maths::Max(0.0, archer.grapple_pos.y));
	Vec2f off = adjusted_pos - blob.getPosition();

	f32 ropelen = Maths::Max(0.1f, off.Length() / 32.0f);
	if (ropelen > 200.0f)
	{
		rope.SetVisible(false);
		hook.SetVisible(false);
		return;
	}

	rope.ResetTransform();
	rope.ScaleBy(Vec2f(ropelen, 1.0f));

	rope.TranslateBy(Vec2f(ropelen * 16.0f, 0.0f));

	rope.RotateBy(-off.Angle() , Vec2f());

	hook.ResetTransform();
	if (archer.grapple_id == 0xffff) //still in air
	{
		archer.cache_angle = -archer.grapple_vel.Angle();
	}
	hook.RotateBy(archer.cache_angle , Vec2f());

	hook.TranslateBy(off);
	hook.SetIgnoreParentFacing(true);
	hook.SetFacingLeft(false);

	//GUI::DrawLine(blob.getPosition(), archer.grapple_pos, SColor(255,255,255,255));
}
