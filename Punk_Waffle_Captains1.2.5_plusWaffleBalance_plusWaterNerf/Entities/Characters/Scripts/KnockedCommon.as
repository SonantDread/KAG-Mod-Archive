const string knockedProp = "knocked";
const string dazzledProp = "dazzled_time";
const string knockedTag = "knockable";

void InitKnockable(CBlob@ this)
{
	this.set_u8(knockedProp, 0);
	this.set_u8(dazzledProp, 0);
	this.Tag(knockedTag);

	this.Sync(knockedProp, true);
	this.Sync(dazzledProp, true);
	this.Sync(knockedTag, true);

	this.addCommandID("knocked");
	this.addCommandID("dazzle");

	this.set_u32("justKnocked", 0);
	this.set_u32("dazzleFlashTime", 0);
}

// returns true if the new knocked time would be longer than the current.
bool setKnocked(CBlob@ blob, int ticks, bool server_only = false)
{
	if (blob.hasTag("invincible"))
		return false; //do nothing

	u8 knockedTime = ticks;
	u8 currentKnockedTime = blob.get_u8(knockedProp);
	if (knockedTime > currentKnockedTime)
	{
		if (getNet().isServer())
		{
			blob.set_u8(knockedProp, knockedTime);

			CBitStream params;
			params.write_u8(knockedTime);

			blob.SendCommand(blob.getCommandID("knocked"), params);

		}

		if(!server_only && blob.isMyPlayer())
		{
			blob.set_u8(knockedProp, knockedTime);
		}

		return true;
	}
	return false;
}

bool setDazzled(CBlob@ blob, int ticks, bool server_only = false)
{
	if (blob.hasTag("invincible"))
		return false;

	u8 dazzledTime = ticks;
	u8 currenDazzledTime = blob.get_u8(dazzledProp);
	if (dazzledTime > currenDazzledTime)
	{
		if (getNet().isServer())
		{
			blob.set_u8(dazzledProp, dazzledTime);

			CBitStream params;
			params.write_u8(dazzledTime);

			blob.SendCommand(blob.getCommandID("dazzle"), params);
		}

		if (!server_only && blob.isMyPlayer())
		{
			blob.set_u8(dazzledProp, dazzledTime);
		}
		return true;
	}
	return false;
}

void KnockedCommands(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("knocked") && getNet().isClient())
	{
		u8 knockedTime = 0;
		if (!params.saferead_u8(knockedTime))
		{
			return;

		}

		this.set_u32("justKnocked", getGameTime());
		this.set_u8(knockedProp, knockedTime);
	}

	else if (cmd == this.getCommandID("dazzle") && getNet().isClient())
	{
		u8 dazzledTime = 0;
		if (!params.saferead_u8(dazzledTime))
			return;

		this.set_u32("dazzleFlashTime", getGameTime() + 10);
		this.set_u8(dazzledProp, dazzledTime);
	}
}

u8 getKnockedRemaining(CBlob@ this)
{
	u8 currentKnockedTime = this.get_u8(knockedProp);
	return currentKnockedTime;
}

u8 getDazzledRemaining(CBlob@ this)
{
	return this.get_u8(dazzledProp);
}

bool isKnocked(CBlob@ this)
{
	if (this.getPlayer() !is null && this.getPlayer().freeze)
	{
		return true;
	}

	return (getKnockedRemaining(this) > 0);
}

bool isDazzled(CBlob@ this)
{
	return (getDazzledRemaining(this) > 0);
}

bool isJustKnocked(CBlob@ this)
{
	return this.get_u32("justKnocked") == getGameTime();
}

void DoKnockedUpdate(CBlob@ this)
{
	if (this.hasTag("invincible"))
	{
		this.DisableKeys(0);
		this.DisableMouse(false);
		return;
	}

	u8 knockedRemaining = getKnockedRemaining(this);
	u8 dazzledRemaining = getDazzledRemaining(this);
	bool frozen = false;
	if (this.getPlayer() !is null && this.getPlayer().freeze)
	{
		frozen = true;
	}

	u16 takekeys = 0;
	bool disable_mouse = false;

	if (knockedRemaining > 0 || frozen)
	{
		if (knockedRemaining > 0)
		{
			knockedRemaining--;
			this.set_u8(knockedProp, knockedRemaining);
		}

		if (knockedRemaining < 2 || (this.hasTag("dazzled") && knockedRemaining < 30))
		{
			takekeys = key_action1 | key_action2 | key_action3;

			if (this.isOnGround())
			{
				this.AddForce(this.getVelocity() * -10.0f);
			}
		}
		else
		{
			takekeys = key_left | key_right | key_up | key_down | key_action1 | key_action2 | key_action3;
		}

		disable_mouse = true;

		// Disable keys takes the keys for tick after it's called
		// so we want to end on time by not calling DisableKeys before knocked finishes
		if (knockedRemaining < 2 && !frozen)
		{
			takekeys = 0;
			disable_mouse = false;
		}

		this.Tag("prevent crouch");
	}
	else if (dazzledRemaining > 0) // Dazzle timer is paused until knocked runs out - todo: fix?
	{
		dazzledRemaining--;
		this.set_u8(dazzledProp, dazzledRemaining);
		
		if (dazzledRemaining > 2)
		{
			takekeys = key_left | key_right | key_up | key_down;
		}
	}
	else
	{
		takekeys = 0;
		disable_mouse = false;
	}
	
	this.DisableKeys(takekeys);
	this.DisableMouse(disable_mouse);

	if (knockedRemaining == 0 && dazzledRemaining == 0)
	{
		this.Untag("dazzled"); // the star animation
	}
}

bool isKnockable(CBlob@ blob)
{
	return blob.hasTag(knockedTag);
}
