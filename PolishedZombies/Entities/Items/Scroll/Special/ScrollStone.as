#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.addCommandID("scroll stone");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("scroll stone"), "Use this to turn all stone in the area into thickstone", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("scroll stone"))
	{
		bool acted = false;
		const int radius = 10;
		
		CMap@ map = this.getMap();
		if   (map is null) return;
		
		Vec2f pos = this.getPosition();
		
		f32 radsq = radius * 7 * radius * 7;
		
		for (int x_step = -radius; x_step < radius; ++x_step)
		{
			for (int y_step = -radius; y_step < radius; ++y_step)
			{
				Vec2f off(x_step * map.tilesize, y_step * map.tilesize);
				
				if (off.LengthSquared() > radsq)
					continue;
				
				Vec2f tpos = pos + off;
				
				TileType t = map.getTile(tpos).type;
				if (map.isTileStone(t))
				{
					map.server_SetTile(tpos, CMap::tile_thickstone);
					acted = true;
				}
			}
		}
		
		
		if (acted)
		{
			this.server_Die();
		}
	}
}