#include "TekCommon.as"

string getButtonRequirementsText(CBitStream& inout bs, bool missing)
{
	string text, requiredType, name, friendlyName;
	u16 quantity = 0;
	bs.ResetBitIndex();

	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, requiredType, name, friendlyName, quantity);
		string quantityColor;

		if (missing)
		{
			quantityColor = "$RED$";
		}
		else
		{
			quantityColor = "$GREEN$";
		}

		if (requiredType == "blob")
		{
			if (quantity > 0)
			{
				text += quantityColor;
				text += quantity;
				text += quantityColor;
				text += " ";
			}
			text += "$"; text += name; text += "$";
			text += " ";
			text += quantityColor;
			text += getTranslatedString(friendlyName);
			text += quantityColor;
			// text += " required.";
			text += "\n";
		}
		else if (requiredType == "tech" && missing)
		{
			text += quantityColor;
			text += friendlyName;
			text += quantityColor;
			text += " tek required.\n";
		}
		else if (requiredType == "coin")
		{
			text += getTranslatedString("{COINS_QUANTITY} $COIN$ required\n").replace("{COINS_QUANTITY}", "" + quantity);
		}
		else if (requiredType == "no more" && missing)
		{
			text += quantityColor;
			text += "Only " + quantity + " " + friendlyName + " per-team possible. \n";
			text += quantityColor;
		}
		else if (requiredType == "no less" && missing)
		{
			text += quantityColor;
			text += "At least " + quantity + " " + friendlyName + " required. \n";
			text += quantityColor;
		}

	}

	return text;
}

string getButtonRequirementsText(CBlob @this, CBitStream& inout bs, CInventory@ anotherInventory = null)
{
	string text, requiredType, name, friendlyName;
	u16 quantity = 0;
	bs.ResetBitIndex();

	text += "\n";
	
	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, requiredType, name, friendlyName, quantity);
		string quantityColor;
		
		bool discount = false;
		if(name == "coin"){
			CBlob@ blob = anotherInventory !is null ? anotherInventory.getBlob() : null;
			bool got = false;
			if(this !is null)if(hasTek(this, this.getTeamNum(), "tek_economy"))got = true;
			if(blob !is null)if(hasTek(blob, blob.getTeamNum(), "tek_economy"))got = true;
			if(got){
				if(quantity > 1)quantity--;
				discount = true;
			}
		}

		bool missing = false;
		
		CBitStream junk, item;
		if(this.getInventory() !is null){
			
			AddRequirement(item, requiredType, name, friendlyName, quantity);
			if(!hasRequirements(this.getInventory(), anotherInventory, item, junk)){
				missing = true;
			}
		}
		
		if (missing)
		{
			quantityColor = "$RED$";
		}
		else
		{
			quantityColor = "$GREEN$";
		}

		if (requiredType == "blob")
		{
			if (quantity > 0)
			{
				text += quantityColor;
				text += quantity;
				text += quantityColor;
				text += " ";
			}
			text += "$"; text += name; text += "$";
			text += " ";
			text += quantityColor;
			text += getTranslatedString(friendlyName);
			text += quantityColor;
			
			if(discount)text += " (-1 discount from ekonomy)";
			
			// text += " required.";
			text += "\n\n";
		}
		else if (requiredType == "tech" && missing)
		{
			text += quantityColor;
			text += friendlyName;
			text += quantityColor;
			text += " tek required.\n";
		}
		else if (requiredType == "coin")
		{
			text += getTranslatedString("{COINS_QUANTITY} $COIN$ required\n").replace("{COINS_QUANTITY}", "" + quantity);
		}
		else if (requiredType == "no more" && missing)
		{
			text += quantityColor;
			text += "Only " + quantity + " " + friendlyName + " per-team possible. \n";
			text += quantityColor;
		}
		else if (requiredType == "no less" && missing)
		{
			text += quantityColor;
			text += "At least " + quantity + " " + friendlyName + " required. \n";
			text += quantityColor;
		}

	}

	return text;
}

void SetItemDescription(CGridButton@ button, CBlob@ caller, CBitStream &in reqs, const string& in description, CInventory@ anotherInventory = null)
{
	if (button !is null && caller !is null && caller.getInventory() !is null)
	{
		CBitStream missing;

		if (hasRequirements(caller.getInventory(), anotherInventory, reqs, missing))
		{
			button.hoverText = description + "\n\n " + getButtonRequirementsText(caller,reqs,anotherInventory);
		}
		else
		{
			button.hoverText = description + "\n\n " + getButtonRequirementsText(caller,reqs,anotherInventory);
			button.SetEnabled(false);
		}
	}
}

// read / write

void AddRequirement(CBitStream &inout bs, const string &in req, const string &in blobName, const string &in friendlyName, u16 &in quantity = 1)
{
	bs.write_string(req);
	bs.write_string(blobName);
	bs.write_string(friendlyName);
	bs.write_u16(quantity);
}

bool ReadRequirement(CBitStream &inout bs, string &out req, string &out blobName, string &out friendlyName, u16 &out quantity)
{
	if (!bs.saferead_string(req))
	{
		return false;
	}

	if (!bs.saferead_string(blobName))
	{
		return false;
	}

	if (!bs.saferead_string(friendlyName))
	{
		return false;
	}

	if (!bs.saferead_u16(quantity))
	{
		return false;
	}

	return true;
}

bool hasRequirements(CInventory@ inv1, CInventory@ inv2, CBitStream &inout bs, CBitStream &inout missingBs, bool &in inventoryOnly = false)
{
	string req, blobName, friendlyName;
	u16 quantity = 0;
	missingBs.Clear();
	bs.ResetBitIndex();
	bool has = true;

	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, req, blobName, friendlyName, quantity);

		if (req == "blob")
		{
			uint sum;
			
			if(blobName == "coin"){
				CBlob@ blob1 = inv1 !is null ? inv1.getBlob() : null;
				CBlob@ blob2 = inv2 !is null ? inv2.getBlob() : null;
				bool got = false;
				if(blob1 !is null)if(hasTek(blob1, blob1.getTeamNum(), "tek_economy"))got = true;
				if(blob2 !is null)if(hasTek(blob2, blob2.getTeamNum(), "tek_economy"))got = true;
				if(got){
					if(quantity > 1)quantity--;
				}
			}
			

			if (inventoryOnly)
			{
				sum = (inv1 !is null ? inv1.getCount(blobName) : 0) + (inv2 !is null ? inv2.getCount(blobName) : 0);
			}
			else
			{
				sum = (inv1 !is null ? inv1.getBlob().getBlobCount(blobName) : 0) + (inv2 !is null ? inv2.getBlob().getBlobCount(blobName) : 0);
			}


			if (sum < quantity)
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}
		else if (req == "tech")
		{
			CBlob@ blob1 = inv1 !is null ? inv1.getBlob() : null;
			CBlob@ blob2 = inv2 !is null ? inv2.getBlob() : null;
			bool got = false;
			if(blob1 !is null)if(hasTek(blob1, blob1.getTeamNum(), blobName))got = true;
			if(blob2 !is null)if(hasTek(blob2, blob2.getTeamNum(), blobName))got = true;
			if (!got)
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}
		else if (req == "coin")
		{
			CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;
			CPlayer@ player2 = inv2 !is null ? inv2.getBlob().getPlayer() : null;
			u16 sum = (player1 !is null ? player1.getCoins() : 0) + (player2 !is null ? player2.getCoins() : 0);
			if (sum < quantity)
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}
		else if ((req == "no more" || req == "no less") && inv1 !is null)
		{
			int teamNum = inv1.getBlob().getTeamNum();
			int count = 0;
			CBlob@[] blobs;
			if (getBlobsByName(blobName, @blobs))
			{
				for (uint step = 0; step < blobs.length; ++step)
				{
					CBlob@ blob = blobs[step];
					if (blob.getTeamNum() == teamNum)
					{
						count++;
					}
				}
			}

			if ((req == "no more" && count >= quantity) || (req == "no less" && count < quantity))
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}
	}

	missingBs.ResetBitIndex();
	bs.ResetBitIndex();
	return has;
}

bool hasRequirements(CInventory@ inv, CBitStream &inout bs, CBitStream &inout missingBs, bool &in inventoryOnly = false)
{
	return hasRequirements(inv, null, bs, missingBs, inventoryOnly);
}

void server_TakeRequirements(CInventory@ inv1, CInventory@ inv2, CBitStream &inout bs)
{
	if (!getNet().isServer())
	{
		return;
	}

	string req, blobName, friendlyName;
	u16 quantity;
	bs.ResetBitIndex();
	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, req, blobName, friendlyName, quantity);

		if (req == "blob")
		{
			if(blobName == "coin"){
				CBlob@ blob1 = inv1 !is null ? inv1.getBlob() : null;
				CBlob@ blob2 = inv2 !is null ? inv2.getBlob() : null;
				bool got = false;
				if(blob1 !is null)if(hasTek(blob1, blob1.getTeamNum(), "tek_economy"))got = true;
				if(blob2 !is null)if(hasTek(blob2, blob2.getTeamNum(), "tek_economy"))got = true;
				if(got){
					if(quantity > 1)quantity--;
				}
			}
			
			u16 taken = 0;
			if (inv1 !is null)
			{
				taken += inv1.getBlob().TakeBlob(blobName, quantity);
			}

			if (inv2 !is null && taken < quantity)
			{
				inv2.getBlob().TakeBlob(blobName, quantity - taken);
			}
		}
		else if (req == "coin") // TODO...
		{
			CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;
			CPlayer@ player2 = inv2 !is null ? inv2.getBlob().getPlayer() : null;
			int taken = 0;
			if (player1 !is null)
			{
				taken = Maths::Min(player1.getCoins(), quantity);
				player1.server_setCoins(player1.getCoins() - taken);
			}
			if (player2 !is null)
			{
				taken = quantity - taken;
				taken = Maths::Min(player2.getCoins(), quantity);
				player2.server_setCoins(player2.getCoins() - taken);
			}
		}
	}

	bs.ResetBitIndex();
}

void server_TakeRequirements(CInventory@ inv, CBitStream &inout bs)
{
	server_TakeRequirements(inv, null, bs);
}
