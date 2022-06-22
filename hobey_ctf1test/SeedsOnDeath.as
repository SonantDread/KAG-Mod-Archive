//tree making logs on death script

#include "MakeSeed.as"

void onDie(CBlob@ this)
{
    if (!getNet().isServer()) return; //SERVER ONLY
    
    Vec2f pos = this.getPosition();
    
    if (!this.hasTag("dropped sapling")) {
        server_MakeSeed(pos, this.getName());
    }
    this.Tag("dropped sapling");
}
