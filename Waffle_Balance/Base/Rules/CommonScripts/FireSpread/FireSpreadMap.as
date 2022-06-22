
#include "FireSpreadCommon.as"

void onSetTile(CMap@ this, u32 index, TileType newtile, TileType oldtile)
{
    Vec2f pos = this.getTileSpacePosition(index);
    if (this.isTileInFire(pos.x, pos.y) && this.get_u32(last_damage_time + (pos * this.tilemapwidth)) + getTicksASecond() < getGameTime())
    {
        FireSpread(pos * this.tilesize);
    }
}
