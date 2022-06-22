
#include "EquipmentCommon.as"
#include "SpongeCommon.as";
#include "KnockedCommon.as";

void doDamageStun(CBlob@ this, f32 damage, u8 customData)
{
	if (this.hasTag("invincible"))return;
	if (!this.hasTag("alive") && !this.hasTag("animated"))return;

	u8 time = 0;

	if (damage > 0.25f) //if hasn't been reduced to minimum
	{
		if(damageIsPierce(customData)){
			if(damage > 2.0f){
				time = damage*10.0f;
			}
		}
		if(damageIsHack(customData) || damageIsSlash(customData)){
			time = damage*5.0f;
		}
		if(damageIsBlunt(customData)){
			time = damage*7.0f;
		}
	}

	if (damage == 0)
	{
		//get sponge
		CBlob@ sponge = null;

		{
			//find the sponge with highest absorbed amount
			CBlob@[] sponges;
			//gather held sponge if exists
			//(first, so carried sponge is prioritised if equal)
			CBlob@ carryblob = this.getCarriedBlob();
			if (carryblob !is null && carryblob.getName() == "sponge")
			{
				sponges.push_back(carryblob);
			}
			//gather inventory
			CInventory@ inv = this.getInventory();
			if (inv !is null)
			{
				for (int i = 0; i < inv.getItemsCount(); i++)
				{
					CBlob@ invitem = inv.getItem(i);
					if (invitem.getName() == "sponge")
					{
						sponges.push_back(invitem);
					}
				}
			}
			//check all
			int highest_absorbed = -1;
			for(int i = 0; i < sponges.length; i++)
			{
				CBlob@ current_sponge = sponges[i];
				int absorbed = current_sponge.get_u8(ABSORBED_PROP);
				if (absorbed < ABSORB_COUNT && // skip full sponges
				    absorbed > highest_absorbed)
				{
					highest_absorbed = absorbed;
					@sponge = current_sponge;
				}
			}
		}

		bool has_sponge = sponge !is null;
		bool wet_sponge = false;

		if (customData == Hitters::water_stun
			|| customData == Hitters::water_stun_force)
		{
			if (has_sponge)
			{
				if(customData == Hitters::water_stun_force)
				{
					time = 22;
				}
				else
				{
					time = 5;

				}
				wet_sponge = true;
			}
			else
			{
				time = 45;
			}

			this.Tag("dazzled");
		}

		if (has_sponge && wet_sponge)
		{
			u8 sp_amount = Maths::Min(ABSORB_COUNT, sponge.get_u8(ABSORBED_PROP) + 50);
			sponge.set_u8(ABSORBED_PROP, sp_amount);
			sponge.Sync(ABSORBED_PROP, true);
			spongeUpdateSprite(sponge.getSprite(), sp_amount);
		}
	}

	if (time > 0)
	{
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		setKnocked(this, Maths::Min(time, 60), true);
	}
}