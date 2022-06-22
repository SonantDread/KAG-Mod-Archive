
#include "LimbsCommon.as"
#include "EnchantAnimCommon.as"

void setAimValues(CSprite @this, CSpriteLayer@ arm, bool visible, f32 angle, Vec2f around, string anim)
{
	if (arm !is null)
	{
		arm.SetVisible(visible);
		
		CSpriteLayer @other = null;
		
		if(arm.name == "backarm"){
			@other = this.getSpriteLayer("back_sleeve");
			UpdateEnchantArm(this, false, visible, angle, around, anim);
		} else
		if(arm.name == "frontarm"){
			@other = this.getSpriteLayer("front_sleeve");
			UpdateEnchantArm(this, true, visible, angle, around, anim);
		}
		
		if(other !is null){
			other.SetVisible(visible);

			if (visible)
			{
				if (!other.isAnimation(anim))
				{
					other.SetAnimation(anim);
				}
			
				other.ResetTransform();
				other.RotateBy(angle, around);
			} else return;
		}
		
		if (visible)
		{
			if (!arm.isAnimation(anim))
			{
				arm.SetAnimation(anim);
			}
		
			arm.ResetTransform();
			arm.RotateBy(angle, around);
		} else return;
	}
}

void setWeaponAim(CSprite @this, CSpriteLayer@ weapon, bool visible, f32 angle, Vec2f around, string anim, int type)
{
	if (weapon !is null)
	{
		weapon.SetVisible(visible);
		
		CSpriteLayer @other = null;
		
		if (visible)
		{
			if (!weapon.isAnimation(anim))
			{
				weapon.SetAnimation(anim);
			}
		
			weapon.ResetTransform();
			weapon.RotateBy(angle, around);
			weapon.SetFrameIndex(type);
		}
	}
}

void reloadSpriteBody(CSprite @this, CBlob @blob){
	reloadSpriteHead(this,blob);
	reloadSpriteTorso(this,blob);
	reloadSpriteArms(this,blob);
	reloadSpriteLegs(this,blob);
}

void reloadSpriteHead(CSprite @this, CBlob @blob){
	int gender = blob.get_u8("sex");
	if(blob.get_u8("head sex") != gender){
		this.RemoveSpriteLayer("head");
		this.RemoveSpriteLayer("hair");
	}
}

void reloadSpriteTorso(CSprite @this, CBlob @blob){
	this.setRenderStyle(RenderStyle::normal);

	string gender = "_Male";
	if(blob.get_u8("sex") == 1)gender = "_Female";
	
	if(blob.hasTag("pregnant"))gender = "_Pregnant";
	
	LimbInfo@ limbs;
	if(!blob.get("limbInfo", @limbs))return;
	const string texname = getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(limbs.Torso)+gender+".png";
	
	if(this.getFilename() != texname){
	
		this.ReloadSprite(texname);
		blob.Tag("force_offset_reload");
	}
	
	this.SetVisible(true);
	
	CSpriteLayer@ emote = this.getSpriteLayer("bubble");
	if(emote !is null)emote.setRenderStyle(RenderStyle::normal);
}

void reloadSpriteArms(CSprite @this, CBlob @blob){
	
	int findex = this.getSpriteLayer("frontarm").getFrameIndex();
	int bindex = this.getSpriteLayer("backarm").getFrameIndex();
	
	this.getSpriteLayer("frontarm").setRenderStyle(RenderStyle::normal);
	this.getSpriteLayer("backarm").setRenderStyle(RenderStyle::normal);
	
	LimbInfo@ limbs;
	if(!blob.get("limbInfo", @limbs))return;
	string text_name_main = getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(limbs.MainArm)+"_Arms.png";
	string text_name_sub  = getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(limbs.SubArm)+"_Arms.png";
	
	if(text_name_main != this.getSpriteLayer("frontarm").getFilename())this.getSpriteLayer("frontarm").ReloadSprite(text_name_main);
	if(text_name_sub != this.getSpriteLayer("backarm").getFilename())this.getSpriteLayer("backarm").ReloadSprite(text_name_sub);
	
	this.getSpriteLayer("frontarm").SetFrameIndex(findex);
	this.getSpriteLayer("backarm").SetFrameIndex(bindex);
}

void reloadSpriteLegs(CSprite @this, CBlob @blob){
	this.getSpriteLayer("frontleg").setRenderStyle(RenderStyle::normal);
	this.getSpriteLayer("backleg").setRenderStyle(RenderStyle::normal);
	
	LimbInfo@ limbs;
	if(!blob.get("limbInfo", @limbs))return;
	string text_name_main = getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(limbs.FrontLeg)+"_Legs.png";
	string text_name_sub  = getFilePath(getCurrentScriptName())+"/BodySprites/"+getBodyTypeName(limbs.BackLeg)+"_Legs.png";
	
	if(text_name_main != this.getSpriteLayer("frontleg").getFilename())this.getSpriteLayer("frontleg").ReloadSprite(text_name_main);
	if(text_name_sub  != this.getSpriteLayer("backleg").getFilename())this.getSpriteLayer("backleg").ReloadSprite(text_name_sub);
}

