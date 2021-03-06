
#include "EmotesCommon.as";
#include "Abilities.as";

bool init = false;
u8 emote_1 = 0;
u8 emote_2 = 0;
u8 emote_3 = 0;
u8 emote_4 = 0;
u8 emote_5 = 0;
u8 emote_6 = 0;
u8 emote_7 = 0;
u8 emote_8 = 0;
u8 emote_9 = 0;

const string emote_config_file = "EmoteBindings.cfg";

//helper - allow integer entries as well as name entries
u8 read_emote(ConfigFile@ cfg, string name, u8 default_value)
{
	string attempt = cfg.read_string(name, "");
	if (attempt != "")
	{
		//replace quoting and semicolon
		//TODO: how do we not have a string lib for this?
		string[] check_str = {";",   "\"", "\"",  "'",  "'"};
		bool[] check_pos =   {false, true, false, true, false};
		for(int i = 0; i < check_str.length; i++)
		{
			string check = check_str[i];
			if(check_pos[i]) //check front
			{
				if(attempt.substr(0, 1) == check)
				{
					attempt = attempt.substr(1, attempt.size() - 1);
				}
			}
			else //check back
			{
				if(attempt.substr(attempt.size() - 1, 1) == check)
				{
					attempt = attempt.substr(0, attempt.size() - 1);
				}
			}
		}
		//match
		for(int i = 0; i < Emotes::names.length; i++)
		{
			if(attempt == Emotes::names[i])
			{
				return i;
			}
		}

		//fallback to u8 read
		u8 read_val = cfg.read_u8(name, default_value);
		return read_val;
	}
	return default_value;
}

void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";

	if (!init)
	{
		//only load the cfg once to avoid
		//too much file access!
		init = true;

		ConfigFile cfg = ConfigFile();
		cfg.loadFile(emote_config_file);

		emote_1 = read_emote(cfg, "emote_1", Emotes::attn);
		emote_2 = read_emote(cfg, "emote_2", Emotes::smile);
		emote_3 = read_emote(cfg, "emote_3", Emotes::frown);
		emote_4 = read_emote(cfg, "emote_4", Emotes::mad);
		emote_5 = read_emote(cfg, "emote_5", Emotes::laugh);
		emote_6 = read_emote(cfg, "emote_6", Emotes::wat);
		emote_7 = read_emote(cfg, "emote_7", Emotes::troll);
		emote_8 = read_emote(cfg, "emote_8", Emotes::disappoint);
		emote_9 = read_emote(cfg, "emote_9", Emotes::ladder);
	}
	
	for(int i = 1;i <= 9;i++){
		if(!this.exists("slot_"+i))this.set_u8("slot_"+i,0);
	}
	
	this.set_u8("emotehud_1",emote_1);
	this.set_u8("emotehud_2",emote_2);
	this.set_u8("emotehud_3",emote_3);
	this.set_u8("emotehud_4",emote_4);
	this.set_u8("emotehud_5",emote_5);
	this.set_u8("emotehud_6",emote_6);
	this.set_u8("emotehud_7",emote_7);
	this.set_u8("emotehud_8",emote_8);
	this.set_u8("emotehud_9",emote_9);
}

void onTick(CBlob@ this)
{

	CControls@ controls = getControls();
	if (controls.isKeyJustPressed(KEY_KEY_1))
	{
		if(this.get_u8("slot_1") == 0)set_emote(this, emote_1);
		else UseAbilityClient(this,this.get_u8("slot_1"));
	}
	else if (controls.isKeyJustPressed(KEY_KEY_2))
	{
		if(this.get_u8("slot_2") == 0)set_emote(this, emote_2);
		else UseAbilityClient(this,this.get_u8("slot_2"));
	}
	else if (controls.isKeyJustPressed(KEY_KEY_3))
	{
		if(this.get_u8("slot_3") == 0)set_emote(this, emote_3);
		else UseAbilityClient(this,this.get_u8("slot_3"));
	}
	else if (controls.isKeyJustPressed(KEY_KEY_4))
	{
		if(this.get_u8("slot_4") == 0)set_emote(this, emote_4);
		else UseAbilityClient(this,this.get_u8("slot_4"));
	}
	else if (controls.isKeyJustPressed(KEY_KEY_5))
	{
		if(this.get_u8("slot_5") == 0)set_emote(this, emote_5);
		else UseAbilityClient(this,this.get_u8("slot_5"));
	}
	else if (controls.isKeyJustPressed(KEY_KEY_6))
	{
		if(this.get_u8("slot_6") == 0)set_emote(this, emote_6);
		else UseAbilityClient(this,this.get_u8("slot_6"));
	}
	else if (controls.isKeyJustPressed(KEY_KEY_7))
	{
		if(this.get_u8("slot_7") == 0)set_emote(this, emote_7);
		else UseAbilityClient(this,this.get_u8("slot_7"));
	}
	else if (controls.isKeyJustPressed(KEY_KEY_8))
	{
		if(this.get_u8("slot_8") == 0)set_emote(this, emote_8);
		else UseAbilityClient(this,this.get_u8("slot_8"));
	}
	else if (controls.isKeyJustPressed(KEY_KEY_9))
	{
		if(this.get_u8("slot_9") == 0)set_emote(this, emote_9);
		else UseAbilityClient(this,this.get_u8("slot_9"));
	}
}
