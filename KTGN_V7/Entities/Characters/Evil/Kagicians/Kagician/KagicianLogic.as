// Kagician logic

#include "Hitters.as";
#include "MagicalHitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "MagicCommon.as";

void onInit(CBlob@ this)
{

	this.Tag("player");
	this.Tag("flesh");


	CShape@ shape = this.getShape();


	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	//not serber side only SKRUBS
	string[] scripts;
	scripts.push_back("Gravity");
	scripts.push_back("Bounce");
	scripts.push_back("Harm");
	this.set("scripts", scripts);
	
	
	this.set_u16("charge", 0); //The amount of time the spell has been charged.
	this.set_u8("firestyle", 0); //Style of shooting spells.
	this.set_u8("stylepower", 0);//Strength of fire style's attack.
	this.set_u8("abilityindex", 255);
	this.getSprite().SetEmitSound("/WaterSparkle.ogg");
	this.addCommandID("setspell");
	this.addCommandID("reset");
	this.addCommandID("setstylepower");
	int length = 0;
	for(int i = 0; i < allwords.length; i++)
	{
		string[][] list = allwords[i];
		for(int y = 0; y < list.length; y++)
		{
			string[] listpart = list[y];
			string icon = listpart[0];
			icon = "$" + icon + "$";
			AddIconToken( icon, "MagicIcons.png", Vec2f(16,16), length);
			length++;
		}
	}
	for(int i = 0; i < 5; i++)
	{
		string icon = "$" + i + "$";
		AddIconToken( icon, "NumberIcons.png", Vec2f(16,16), i);
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16));
	}
}



void onTick(CBlob@ this)
{
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
	moveVars.walkFactor *= 0.7f;
	moveVars.jumpFactor *= 2.2f;
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}
	// activate/throw
	if(ismyplayer)
	{

		if(this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if(carried is null || !carried.hasTag("temp blob"))
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}
	CSprite@ sprite = this.getSprite();
	Vec2f vel = this.getVelocity();
	int charge = this.get_u16("charge");
	u8 firestyle = this.get_u8("firestyle");
	u8 stylepower = this.get_u8("stylepower");
	
	bool action2 = this.isKeyPressed(key_action2);
	bool action1 = this.isKeyPressed(key_action1);
	if(this.isKeyJustPressed(key_action2) || this.isKeyJustPressed(key_action1))
	{
		sprite.SetEmitSoundPaused(false);
	}
	if(action2)
	{
		charge = Maths::Min(getChargeMax(firestyle, stylepower), charge + 1);
		sprite.SetEmitSoundSpeed((charge / 200.0f));
		this.set_u16("charge", charge);	
	}
	else if(action1)
	{
		charge = Maths::Min(getCasterThreshold(stylepower) + 1, charge + 1);
		sprite.SetEmitSoundSpeed((charge / 400.0f));
		this.set_u16("charge", charge);	
	}
	
	//meddling with wizardry. Moved to function because Caster
	if(this.isKeyJustReleased(key_action2))
	{
		if(getNet().isClient())
		{
			CBitStream params;
			params.write_Vec2f(this.getAimPos());
			this.SendCommand(this.getCommandID("sendspellstuff"), params);
		}
	}

	if(this.isKeyJustReleased(key_action1)) //cast Caster
	{
		sprite.SetEmitSoundPaused(true);
		if(canCastCaster(this))
		{
			if(getNet().isServer())
			{
				CBlob@ caster = server_CreateBlob("caster", this.getTeamNum(), this.getPosition());
				if(caster !is null)
				{
					string[] scripts;
					this.get("scripts", scripts);
					caster.set("scripts", scripts);
					caster.set_u8("stylepower", this.get_u8("stylepower"));
					caster.set_u8("firestyle", this.get_u8("firestyle"));
					caster.set_Vec2f("aimpos", this.getAimPos());
					caster.SetFacingLeft(this.isFacingLeft());
				}
			}
		}
		this.set_u16("charge", 0);	
	}
	
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData ) //Reset charge.
{
	if(damage != 0)
	{
		this.set_u16("charge", 0);
	}
	return damage;
}

//Spellcasting GUI
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("setspell"))  //from standardcontrols
    {
		u8 spellindex = params.read_u8();
		u8 endex = params.read_u8();
		string[] scripts;
		this.get("scripts", scripts);
		{
			string[] list = allwords[spellindex][endex];
			string word = list[list.length - 1]; //The string on the very end is the script name.
			if(spellindex < 3) //If it's one of the three must-have parts of spells.
			{
				scripts[spellindex] = word; //replace current one
			}
			else if(spellindex == 3) //Attack style thingies get special thingums
			{
				this.set_u8("firestyle", endex);
				//Set stylepower to be anywhere between the maximum stylepower of that firestyle, or 0.
				this.set_u8("stylepower", Maths::Min(list.length - 1, this.get_u8("stylepower")));
			}
			else //misc
			{
				scripts.push_back(word);
			}
		}
		this.set("scripts", scripts);
	}
	else if(cmd == this.getCommandID( "reset" ))
	{
		string[] scripts;
		scripts.push_back("Gravity");
		scripts.push_back("Bounce");
		scripts.push_back("Harm");
		this.set_u8("firestyle", 0);
		this.set_u8("stylepower", 0);
		this.set("scripts", scripts); //10/10
	}
	else if(cmd == this.getCommandID( "setstylepower" ))
	{
		u8 stylepower = params.read_u8();
		this.set_u8("stylepower", stylepower);
	}
}



void onCreateInventoryMenu( CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu )
{

    this.ClearGridMenusExceptInventory();
    Vec2f pos( gridmenu.getUpperLeftPosition().x + 0.5f*(gridmenu.getLowerRightPosition().x - gridmenu.getUpperLeftPosition().x),
               gridmenu.getUpperLeftPosition().y);
	
    //Stylepower
	CGridMenu@ menu = CreateGridMenu( Vec2f(pos.x + 200, pos.y), this, Vec2f( 1, 5 ), "Spell Power");
	if(menu !is null)
	{
		
		menu.deleteAfterClick = false;
		string[] list = allwords[3][this.get_u8("firestyle")];
		for(int i = 0; i < list.length - 1; i++)
		{
			CBitStream params;
			params.write_u8(i);
			string spellname = list[i];
			CGridButton @button = menu.AddButton( "$" + i +"$", spellname, this.getCommandID( "setstylepower" ), params );
		}
	}
	for(int step = 0; step < allwords.length; step++)
	{
		string[][] list = allwords[step];
		CGridMenu@ menu = CreateGridMenu( Vec2f(pos.x, pos.y - 64), this, Vec2f( list.length, 1 ),  spelltypenames[step]);
		if(menu !is null)
		{
			menu.deleteAfterClick = false;
			for (int step2 = 0; step2 < list.length; step2++)
			{
				string spellname = list[step2][0];

				CBitStream params;
				params.write_u8(step);
				params.write_u8(step2);
				//print("$" + spellname +"$");
				CGridButton @button = menu.AddButton( "$" + spellname +"$", spellname, this.getCommandID( "setspell" ), params );


				if (button !is null)
				{
					button.selectOneOnClick = true;
					/*if ( == step2) //is selected
					{
						button.SetSelected(1);
					}*/
				}
			}
		}
		pos.y -= 80;
	}
	{
		CGridMenu@ menu = CreateGridMenu( Vec2f(pos.x, pos.y - 80), this, Vec2f( 1, 1 ),  "Reset");
		if(menu !is null)
		{
			menu.deleteAfterClick = true;
			CBitStream params;
			CGridButton @button = menu.AddButton( "$lantern$", "Reset", this.getCommandID( "reset" ), params );
		}
	}
}