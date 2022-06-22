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
		Animation@ anim2 = frontleg.addAnimation("lie", 3, true);
		anim2.AddFrame(5);
		anim2.AddFrame(5);
		anim2.AddFrame(5);
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
		Animation@ anim2 = backleg.addAnimation("lie", 3, true);
		anim2.AddFrame(12);
		anim2.AddFrame(12);
		anim2.AddFrame(12);
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
	this.RemoveSpriteLayer("shield");
	CSpriteLayer@ shield = this.addSpriteLayer("shield", "Shield.png" , 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (shield !is null)
	{
		int shields = 2;
		Animation@ anim = shield.addAnimation("default", 0, false);
		for(int i = 0;i < shields;i++)anim.AddFrame(i*4);
		Animation@ anim1 = shield.addAnimation("raised", 0, false);
		for(int i = 0;i < shields;i++)anim1.AddFrame(i*4+1);
		Animation@ anim2 = shield.addAnimation("slide", 0, false);
		for(int i = 0;i < shields;i++)anim2.AddFrame(i*4+2);
		Animation@ anim3 = shield.addAnimation("rest", 0, false);
		for(int i = 0;i < shields;i++)anim3.AddFrame(i*4+3);
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
	
	
	if(getGameTime() % 30 == 0){
		
		reloadSpriteBody(this,blob);
		
		if(blob.get_u8("sprite_fore_eye") != blob.get_u8("fore_eye"))this.RemoveSpriteLayer("head");
		if(blob.get_u8("sprite_back_eye") != blob.get_u8("back_eye"))this.RemoveSpriteLayer("head");
		
		if(this.isVisible()){
			if(!blob.exists("head_sprite_index") || blob.get_s8("head_sprite_index") != blob.get_u8("head_type")){
				blob.set_s8("head_sprite_index",blob.get_u8("head_type"));
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
	
	bool LyingDown = blob.isAttachedToPoint("BED") || (!blob.hasTag("alive") && !blob.hasTag("animated"));
	
	bool Visible = true;
	
	if(this.getSpriteLayer("head") !is null)this.getSpriteLayer("head").SetVisible(Visible);
	
	if(blob.isAttached()){
		if(blob.isAttachedToPoint("BED")){
			CAttachment@ attach = blob.getAttachments();
			if(attach.getAttachedBlob("BED") !is null){
				blob.SetFacingLeft(true);
				//if(attach.getAttachedBlob("BED").getName() == "quarters"){
					Visible = false;
					if(this.getSpriteLayer("head") !is null)this.getSpriteLayer("head").SetVisible(true);
				//}
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
	
	int frontLeg = blob.get_u8("fleg_type");
	int backLeg = blob.get_u8("bleg_type");
	
	bool Crawling =  !isLimbUsable(blob,frontLeg) || !isLimbUsable(blob,backLeg) || blob.getHealth()<= 0;//!LyingDown;

	if((frontLeg == BodyType::Golem && backLeg == BodyType::Golem) || (frontLeg == BodyType::Wood && backLeg == BodyType::Wood)){
		Crawling = false;
		LyingDown = false;
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
	if (blob.hasTag("seated"))Sitting = true;
	
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
	
	if(Crawling){
		MainArmOffset = DefaultMainArmOffset+Vec2f(-3.0f,3.0f);
		SubArmOffset = DefaultSubArmOffset+Vec2f(1.0f,4.0f);
	}
	
	//////////////////////////////////Leg handlin
	
	bool FrontLegVisible = Visible;
	bool BackLegVisible = Visible;
	
	if(blob.get_u8("fleg_type") == BodyType::None)FrontLegVisible = false;
	if(blob.get_u8("bleg_type") == BodyType::None)BackLegVisible = false;
	
	this.getSpriteLayer("frontleg").SetVisible(FrontLegVisible);
	this.getSpriteLayer("backleg").SetVisible(BackLegVisible);
	
	this.getSpriteLayer("frontleg").SetOffset(FrontLegOffset);
	this.getSpriteLayer("backleg").SetOffset(BackLegOffset);
	
	this.getSpriteLayer("frontleg").ResetTransform();
	this.getSpriteLayer("backleg").ResetTransform();
	
	if(LyingDown){
		this.getSpriteLayer("frontleg").SetOffset(FrontLegOffset+Vec2f(-10,0));
		this.getSpriteLayer("backleg").SetOffset(BackLegOffset+Vec2f(-10,0));
		this.getSpriteLayer("frontleg").SetAnimation("lie"); //Liar, liar, pants on fire
		this.getSpriteLayer("backleg").SetAnimation("lie");
	}
	else
	if(Crawling){
		this.getSpriteLayer("frontleg").SetOffset(FrontLegOffset+Vec2f(6,13));
		this.getSpriteLayer("backleg").SetOffset(BackLegOffset+Vec2f(3,12));
		this.getSpriteLayer("frontleg").SetAnimation("lie");
		this.getSpriteLayer("backleg").SetAnimation("lie");
		
		this.getSpriteLayer("frontleg").RotateBy(180, Vec2f(0,0));
		this.getSpriteLayer("backleg").RotateBy(180, Vec2f(0,0));
	}
	else 
	if(Sitting){
		this.getSpriteLayer("frontleg").SetAnimation("sitting");
		this.getSpriteLayer("backleg").SetAnimation("sitting");
	}
	else
	if(Crouching){
		this.getSpriteLayer("frontleg").SetAnimation("crouch");
		this.getSpriteLayer("backleg").SetAnimation("crouch");
	}
	else
	if ((left || right) || (blob.isOnLadder() && (up || down)))
	{
		this.getSpriteLayer("frontleg").SetAnimation("run");
		this.getSpriteLayer("backleg").SetAnimation("run");
	}
	else 
	{
		if(true)
			this.getSpriteLayer("frontleg").SetAnimation("default");
		else
			this.getSpriteLayer("frontleg").SetAnimation("broken");
			
		if(true)
			this.getSpriteLayer("backleg").SetAnimation("default");
		else
			this.getSpriteLayer("backleg").SetAnimation("broken");
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

	if(blob.get_u8("marm_type") == BodyType::None)mainarmvisible = false;
	if(blob.get_u8("sarm_type") == BodyType::None)subarmvisible = false;

	int Down = 90;
	if (this.isFacingLeft())Down = 270;
	
	this.getSpriteLayer("frontarm").SetOffset(MainArmOffset);
	this.getSpriteLayer("backarm").SetOffset(SubArmOffset);
	
	int Wobble = (this.getSpriteLayer("frontleg").getFrame()-1);
	if(!this.getSpriteLayer("frontleg").isAnimation("default")){
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
	if(shielding || bowcharge > 0){ //bow
		aimingMain = true;
		aimingSub = true;
	}
	
	bool canUseArms = true;
	
	if(LyingDown){
		canUseArms = false;
		setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 0, Vec2f(0, 0), "default");
		this.getSpriteLayer("frontarm").SetOffset(Vec2f(-3,5.5f));
		
		setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 0, Vec2f(0, 0), "default");
		this.getSpriteLayer("backarm").SetOffset(Vec2f(-3,2));
	} else {
		if (knocked > 0){
			canUseArms = false;
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
		}
	}

	if(canUseArms || true){
	
		if(aimingMain){
			setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(0, 0), "stretch");
		} else {
			if(LyingDown){
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 0, Vec2f(0, 0), "default");
				this.getSpriteLayer("frontarm").SetOffset(Vec2f(-3,5.5f));
			} else
			if(blob.getCarriedBlob() !is null){
				int Carry = -20;
				if (this.isFacingLeft())Carry = 20;
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down+Carry*2, Vec2f(0, 0), "default");
			} else 
			if (is_emote(blob, 255, true))
			{
				setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle, Vec2f(0, 0), "point");
			} else 
			setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down+Wobble*20, Vec2f(0, 0), "default");
		}
		if(aimingSub){
			setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle, Vec2f(0, 0), "stretch");
		} else {
			if(LyingDown){
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 0, Vec2f(0, 0), "default");
				this.getSpriteLayer("backarm").SetOffset(Vec2f(-3,2));
			} else
			if(blob.getCarriedBlob() !is null){
				int Carry = -20;
				if (this.isFacingLeft())Carry = 20;
				setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down+Carry, Vec2f(0, 0), "default");
			} else
			setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, Down-Wobble*20, Vec2f(0, 0), "default");
		}

		int inverse = -1;
		if(this.isFacingLeft())inverse = 1;
		
		int main_implement = blob.get_u16("marm_equip");
		int sub_implement = blob.get_u16("sarm_equip");
		setAimValues(this,this.getSpriteLayer("main_equip"), false, 0, Vec2f(0, 0), "default");
		setAimValues(this,this.getSpriteLayer("sub_equip"), false, 0, Vec2f(0, 0), "default");
	
		switch(main_implement){
			
			case Equipment::Pick:{
				int swing = blob.get_u8("pickaxe_counter");
				if(swing > 0){
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle-70.0f*inverse+swing*inverse*2.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,this.getSpriteLayer("main_equip"), true, angle-70.0f*inverse+swing*inverse*2.0f, Vec2f(0, 0), "pick",blob.get_u16("marm_equip_type"));
					this.getSpriteLayer("main_equip").SetOffset(MainArmOffset);
				}
			break;}
			
			case Equipment::Hammer:{
				int swing = blob.get_u8("hammer_swing");
				if(swing > 0){
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, angle-70.0f*inverse+swing*inverse*16.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,this.getSpriteLayer("main_equip"), true, angle-70.0f*inverse+swing*inverse*16.0f, Vec2f(0, 0), "hammer",blob.get_u16("marm_equip_type"));
					this.getSpriteLayer("main_equip").SetOffset(MainArmOffset);
				}
			break;}
			
			case Equipment::Sword:{
				int state = blob.get_s8("sword_state");
				if(state != KnightStates::normal){
				
					f32 aim = 0.0f;
					
					if(state == KnightStates::sword_drawn)aim = -135.0f+(blob.get_f32("sword_ratio")*180.0f);
					else if(state == -1)aim = 45.0f;
					else if(state == -2)aim = 135.0f;
					else if(state == KnightStates::sword_power)aim = 45.0f-Maths::Min((blob.get_f32("sword_ratio")*720.0f),180.0f);
					else if(state == KnightStates::sword_power_super)aim = 135.0f-Maths::Min((blob.get_f32("sword_ratio")*720.0f),270.0f);
					else aim = angle*inverse-70.0f+135.0f-Maths::Min((blob.get_f32("sword_ratio")*720.0f),180.0f);
					
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, aim*inverse, Vec2f(0, 0), "stretch");
					setWeaponAim(this,this.getSpriteLayer("main_equip"), true, aim*inverse, Vec2f(0, 0), "sword",blob.get_u16("marm_equip_type"));
					this.getSpriteLayer("main_equip").SetOffset(MainArmOffset);
				}
			break;}
			
			case Equipment::ZombieHands:{
				if(!LyingDown){
					int swing = 0;
					Wobble = (getGameTime()/3) % 4;
					if(Wobble == 2)Wobble = 0;
					else if(Wobble == 3)Wobble = -1;
					else if(Wobble > 3) Wobble = 0;
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, swing*inverse-Wobble*20, Vec2f(0, 0), "stretch");
				}
			break;}
			
			case Equipment::GreatSword:{
				int state = blob.get_s8("sword_state");
				if(state != KnightStates::normal){
				
					f32 aim = 0.0f;
					
					if(state == KnightStates::sword_drawn)aim = -135.0f+(blob.get_f32("sword_ratio")*180.0f);
					else if(state == -1)aim = 45.0f;
					else if(state == -2)aim = 135.0f;
					else if(state == KnightStates::sword_power)aim = 45.0f-Maths::Min((blob.get_f32("sword_ratio")*720.0f),180.0f);
					else if(state == KnightStates::sword_power_super)aim = 135.0f-Maths::Min((blob.get_f32("sword_ratio")*720.0f),270.0f);
					else aim = angle*inverse-70.0f+135.0f-Maths::Min((blob.get_f32("sword_ratio")*720.0f),180.0f);
					
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, aim*inverse, Vec2f(0, 0), "stretch");
					setWeaponAim(this,this.getSpriteLayer("main_equip"), true, aim*inverse, Vec2f(0, 6), "great_sword",blob.get_u16("marm_equip_type"));
					this.getSpriteLayer("main_equip").SetOffset(MainArmOffset+Vec2f(0,-6));
				} else {
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, Down+20*inverse, Vec2f(0, 0), "default");
					setWeaponAim(this,this.getSpriteLayer("main_equip"), true, 180+Down+20*inverse, Vec2f(0, 0), "great_sword",blob.get_u16("marm_equip_type"));
					this.getSpriteLayer("main_equip").SetOffset(MainArmOffset+Vec2f(5,10));
				}
			break;}
		
		}
		
		switch(sub_implement){
			
			case Equipment::Pick:{
				int swing = blob.get_u8("pickaxe_counter");
				if(swing > 0){
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle-70.0f*inverse+swing*inverse*2.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,this.getSpriteLayer("sub_equip"), true, angle-70.0f*inverse+swing*inverse*2.0f, Vec2f(0, 0), "pick",blob.get_u16("sarm_equip_type"));
					this.getSpriteLayer("sub_equip").SetOffset(SubArmOffset);
				}
			break;}
			
			case Equipment::Hammer:{ 
				int swing = blob.get_u8("hammer_swing");
				if(swing > 0){
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, angle-70.0f*inverse+swing*inverse*16.0f, Vec2f(0, 0), "stretch");
					setWeaponAim(this,this.getSpriteLayer("sub_equip"), true, angle-70.0f*inverse+swing*inverse*16.0f, Vec2f(0, 0), "hammer",blob.get_u16("sarm_equip_type"));
					this.getSpriteLayer("sub_equip").SetOffset(SubArmOffset);
				}
			break;}
			
			case Equipment::Sword:{
				int state = blob.get_s8("sword_state");
				if(state != KnightStates::normal){
				
					f32 aim = 0.0f;
					
					if(state == KnightStates::sword_drawn)aim = -135.0f+(blob.get_f32("sword_ratio")*180.0f);
					else if(state == -1)aim = 45.0f;
					else if(state == -2)aim = 135.0f;
					else if(state == KnightStates::sword_power)aim = 45.0f-Maths::Min((blob.get_f32("sword_ratio")*720.0f),180.0f);
					else if(state == KnightStates::sword_power_super)aim = 135.0f-Maths::Min((blob.get_f32("sword_ratio")*720.0f),270.0f);
					else aim = angle*inverse-70.0f+135.0f-Maths::Min((blob.get_f32("sword_ratio")*720.0f),180.0f);
					
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, aim*inverse, Vec2f(0, 0), "stretch");
					setWeaponAim(this,this.getSpriteLayer("sub_equip"), true, aim*inverse, Vec2f(0, 0), "sword",blob.get_u16("sarm_equip_type"));
					this.getSpriteLayer("sub_equip").SetOffset(SubArmOffset);
				}
			break;}
			
			case Equipment::ZombieHands:{
				if(!LyingDown){
					int swing = 0;
					Wobble = (getGameTime()/3) % 4;
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
		
		if(shielding){
			
			this.getSpriteLayer("shield").SetOffset(MainArmOffset);
			this.getSpriteLayer("shield").SetRelativeZ(100.0f);
			if(sub_implement == Equipment::Shield)this.getSpriteLayer("shield").SetFrameIndex(blob.get_u16("sarm_equip_type"));
			else this.getSpriteLayer("shield").SetFrameIndex(blob.get_u16("marm_equip_type"));
			
			if(vec.Angle() > 45 && vec.Angle() < 135){
				setAimValues(this,this.getSpriteLayer("shield"), true, 0, Vec2f(0, 0), "raised");
				if(this.isFacingLeft()){
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 110, Vec2f(0, 0), "stretch");
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 70, Vec2f(0, 0), "stretch");
				} else {
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 250, Vec2f(0, 0), "stretch");
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 290, Vec2f(0, 0), "stretch");
				}
			} else
			if(vec.Angle() > 270-45 && vec.Angle() < 270+45){
				setAimValues(this,this.getSpriteLayer("shield"), true, 0, Vec2f(0, 0), "slide");
				
				if(this.animation.frame == 0)this.animation.frame = 2;
				
				this.getSpriteLayer("frontarm").SetOffset(MainArmOffset+Vec2f(0,2));
				this.getSpriteLayer("backarm").SetOffset(SubArmOffset+Vec2f(0,2));
				
				if(this.isFacingLeft()){
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 290, Vec2f(0, 0), "stretch");
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 290, Vec2f(0, 0), "stretch");
				} else {
					setAimValues(this,this.getSpriteLayer("frontarm"), mainarmvisible, 70, Vec2f(0, 0), "stretch");
					setAimValues(this,this.getSpriteLayer("backarm"), subarmvisible, 70, Vec2f(0, 0), "stretch");
				}
			} else setAimValues(this,this.getSpriteLayer("shield"), true, angle, Vec2f(0, 0), "default");
		} else {
			if(main_implement == Equipment::Shield || sub_implement == Equipment::Shield){
				setAimValues(this,this.getSpriteLayer("shield"), true, Down-Wobble*20, Vec2f(0, 0), "rest");
				this.getSpriteLayer("shield").SetRelativeZ(-100.0f);
				if(sub_implement == Equipment::Shield)this.getSpriteLayer("shield").SetFrameIndex(blob.get_u16("sarm_equip_type"));
				else this.getSpriteLayer("shield").SetFrameIndex(blob.get_u16("marm_equip_type"));
				this.getSpriteLayer("shield").SetOffset(MainArmOffset);
			}
			else setAimValues(this,this.getSpriteLayer("shield"), false, angle, Vec2f(0, 0), "default"); //Make shield invis
		}
		
	} else { //Can't use arms
		setAimValues(this,this.getSpriteLayer("shield"), false, angle, Vec2f(0, 0), "default"); //Make shield invis
	}

	//////////////////////////////set head
	if(LyingDown){
		blob.Tag("sleep head");
	}
	else
	if (knocked > 0 || (!blob.hasTag("alive") && !blob.hasTag("animated"))) //Are we stunned or dead?
	{
		blob.Tag("dead head"); //Use the 'dead' head.
		blob.Untag("sleep head");
	}
	else if (blob.isInFlames()) //Are we using our left click ability or are we on fire?
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
