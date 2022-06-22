#include "MagicalHitters.as";
//Contains every script & it's magical code. .as is added on after because they'll all have that.
//Only one movement script per spell.
//No longer any need for caps locks in some of the stuff.
const string[][] movement = {
{"Fellar", //Chat name
"StraightLine" //Script name
},
{"Hest", "Gravity"},
{"Ondriss", "Orbit"},
{"Siltar", "SinGravity"},
{"Resvellar", "ReverseGravity"},
{"Aldotar", "Stationary"}
};

//Only one collision script per spell.
const string[][] collision = {
{"Bosun", "Bounce"},
{"Tessel", "TilePhase"},
{"Retus", "ReturnBounce"}
};

//Only one enemy collision script per spell.
const string[][] enemycollision = {
{"Huar", "Harm"},
{"Pef", "Pierce"},
//{"Aeldestas", "ArrowRain"},
{"Expondu", "Explode"},
{"Konkus", "Knock"}
};

//As many misc scripts as is gud.
const string[][] misc = {
{"Ergon", "Necromance"},
//{"Endelfalar", "Nothing"},
{"Lonbus", "Lob"},
{"Ainirlan", "MagicMissile"}
};

const string[][] attackstyle = {
{"Plie", "Horon", FireStyle::Plain},
{"Ranpi", "Porfuse", FireStyle::Rapid},
{"Pio", "Gestaf", "Festil", "Poldufelgastrastanglest", FireStyle::SkySummon},
{"Tirs", "Estargar", "Feldestar", FireStyle::SpreadShot},
{"Erfugon", "Moltegon", "Polmanticon",FireStyle::Eruption}
};


const string[][][] allwords = {
movement,
collision,
enemycollision,
misc,
attackstyle
};



namespace FireStyle
{
	enum Aim
	{
		Plain = 0,
		Rapid,
		SkySummon,
		SpreadShot,
		Eruption
	}
}
const string[] Abilities = {
"Entil", //Leap
"Rendestus", //Regenerate
"Flagen" //Glide
};
const int[] minAbilityCharges = {
120, //Leap
80, //Regenerate
100 //Glide
};
namespace Ability
{
	enum type
	{
		Leap = 0,
		Regenerate,
		Glide
	}
}

int getSpellIndex(string word, int& out endex, int& out power)
{
	string[] incantation = word.split(","); //What to seperate powers from.
	power = 0;
	if(incantation.length < 0)
	{
		return -1;
	}
	string mainword = incantation[0];

	for(int i = 0; i < allwords.length; i++)
	{
		string[][] list = allwords[i];
		for(int step = 0; step < list.length; step++)
		{
			string[] listpart = list[step];
			if(listpart[0].toLower() == mainword.toLower())
			{
				for(int i = 1; i < listpart.length - 1 && i < incantation.length; i++) //Checking for stylepower upgrades.
				{
					string ensorcellor = incantation[i].toLower();
					if(ensorcellor == listpart[i].toLower())
					{
						power++;
					}
					
				}
				endex = step; //Set the spell to it's script-name
				return i; //Returns the index of the spell.
			}
		}
	}
	return -1; //-1 = nothing.
}

//Thresholds
int getChargeMax(u8 firestyle, u8 stylepower)
{
	int[] stylelist = maxChargeLevels[firestyle];
	int maxnum = stylelist[Maths::Min(stylepower, stylelist.length - 1)]; //So it doesn't go out of bounds.
	return maxnum;
}

int getThreshold(u8 firestyle, u8 stylepower)
{
	return getChargeMax(firestyle, stylepower) * 0.68f; //Always return a little bit of max charge level
}

int getCasterThreshold(u8 stylepower)
{
	return (stylepower + 1) * 155;
}


//CanCast
bool canCast(CBlob@ this)
{
	int charge = this.get_u16("charge");
	u8 firestyle = this.get_u8("firestyle");
	u8 stylepower = this.get_u8("stylepower");		
	if(charge >= getThreshold(firestyle, stylepower))
	{
		return true;
	}
	return false;
}
bool canCastCaster(CBlob@ this)
{
	int charge = this.get_u16("charge");
	u8 stylepower = this.get_u8("stylepower");		
	if(charge >= getCasterThreshold(stylepower))
	{
		return true;
	}
	return false;
}

//Max Charge levels for spells.
const int[][] maxChargeLevels = {
	{60, 210},	//Plain
	{17, 7},		//Rapid
	{120, 180, 280, 550},		//SkySummon
	{70, 130, 400},		//SpreadShot
	{140, 200, 300}		//Eruption
};

//Just incase o.o
void MagicHitBlob(CBlob@ this, CBlob@ blob, Vec2f position, Vec2f vel, f32 damage, u8 hitter, bool shouldTeamKill = false)
{
	this.server_Hit(blob, position, vel, damage, hitter, shouldTeamKill);
}


void doSpellStuff(CBlob@ this, Vec2f aimpos)
{
	CSprite@ sprite = this.getSprite();
	Vec2f vel = this.getVelocity();
	int charge = this.get_u16("charge");
	u8 firestyle = this.get_u8("firestyle");
	u8 stylepower = this.get_u8("stylepower");
	{
		sprite.SetEmitSoundPaused(true);
		Vec2f pos = Vec2f(0, 0); //Pos to summon stuff.
		Vec2f shootvel = Vec2f(0, 0); //Hack to make FireStyles Work, set to anything other than 0
		
		switch(firestyle)
		{
			case FireStyle::Plain:
				charge *= 2.0f;
			break;
			case FireStyle::Rapid:
				if(stylepower >= 1)
				{
					charge *= 6.0f;
				}
				else
				{
					charge *= 4.0f;
				}
			break;
			case FireStyle::SkySummon:
				if(!getMap().rayCastSolid(this.getPosition(), Vec2f(this.getPosition().x, 0)))
				{
					pos = Vec2f(aimpos.x, 1);
				}
				else
				{
					pos = Vec2f(this.getPosition().x, 1);
				}
			break;
			case FireStyle::SpreadShot:
				charge /= 0.8f;
			break;
			case FireStyle::Eruption:
				getMap().rayCastSolid(this.getPosition(), aimpos, pos);
			break;
		}
		//DO THA MAGIC
		if(canCast(this)) // Cast the spell.
		{
			sprite.PlaySound("OrbFireSound.ogg", charge / 30.0f, Maths::Clamp(1 / (charge / 120.0f), 0.8f, 4.53f));
			if(pos.y == 0) //If it's not already been set.
			{
				pos = this.getPosition();
				shootvel = aimpos - pos;
				shootvel.Normalize();
				shootvel *= 9 * (Maths::Min(charge / 55.0f, 3.1f));
				if(vel.Length() > 4)
				{
					shootvel += vel / 4;
				}
			}
			
			if(getNet().isServer())
			{
				if(firestyle == FireStyle::SpreadShot)
				{
					shootvel.RotateBy(-8, Vec2f());
					for(int i = 0; i < 3; i++)
					{
						ShootSpell(this, pos, shootvel, charge, firestyle);
						shootvel.RotateBy(8, Vec2f());
					}
					if(stylepower >= 1)
					{
						shootvel *= 1.1f;
						shootvel.RotateBy(-8, Vec2f());
						for(int i = 0; i < 3; i++)
						{
							ShootSpell(this, pos, shootvel, charge, firestyle);
							shootvel.RotateBy(-12, Vec2f());
						}
						if(stylepower >= 2) //derp ;D
						{
							shootvel *= 1.1f;
							shootvel.RotateBy(12, Vec2f());
							for(int i = 0; i < 3; i++)
							{
								ShootSpell(this, pos, shootvel, charge, firestyle);
								shootvel.RotateBy(16, Vec2f());
							}
						}
					}
				}
				else if(firestyle == FireStyle::SkySummon && stylepower >= 1)
				{
					int num = stylepower * 2;
					num = stylepower * stylepower;
					num *= 2;
					num += 1;
					//print("Num: " + num);
					pos.x -= 20.0f * (num / 2);
					for(int i = 0; i < (num); i++) //So that its always an odd number
					{
						ShootSpell(this, pos, shootvel, charge, firestyle);
						pos.x += 20;
						pos.y = (XORRandom(num * 5.0f));
					}
				}
				else if(firestyle == FireStyle::Eruption)
				{
					int num = (stylepower + 1) * 3;
					shootvel = Vec2f(0, -9);
					shootvel.RotateBy(((-num + 1)/ 2.0f) * 10.0f, Vec2f());
					for(int i = 0; i < num; i++)
					{
						ShootSpell(this, pos, shootvel, charge, firestyle);
						shootvel.RotateBy(10, Vec2f());
					}
				}
				else
				{
					ShootSpell(this, pos, shootvel, charge, firestyle);	
				}
			}
		}
		else
		{
			charge += 1; //prevent divide by 0
			sprite.PlaySound("OrbExplosion.ogg", charge / 30.0f, Maths::Clamp(1 / (charge / 120.0f), 0.8f, 4.53f));
		}
		this.set_u16("charge", 0);
	}
}

void ShootSpell(CBlob@ this, Vec2f pos, Vec2f aimpos, u16 charge, u8 firestyle)
{
	CBlob@ spell = server_CreateBlob("spell", this.getTeamNum(), pos);
	if(spell !is null)
	{
		spell.setVelocity(aimpos);
		CSprite@ spr = spell.getSprite();
		string[] scripts;
		this.get("scripts", scripts);
		for(int i = 0; i < scripts.length; i++)
		{
			string scriptname = (scripts[i]);
			if(scriptname == "Necromance")
			{
				this.server_Hit(this, this.getPosition(), aimpos, charge / 60.0f, MagicalHitters::Magic);
				charge = Maths::Min(charge * 2, 255);
			}
			spell.set_u16("ownerID", this.getNetworkID());
			scriptname += ".as";
			//print("Script Name: " + scriptname);
			spell.AddScript(scriptname);
		}
		spell.set_u16("charge", charge);
		spell.SetFacingLeft(this.isFacingLeft());
		//-- scale the blob client side --
		CBitStream params;
		params.write_u16(spell.getNetworkID());
		this.SendCommand(this.getCommandID("scale"), params);
	}
}