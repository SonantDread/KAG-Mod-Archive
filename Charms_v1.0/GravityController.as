void onTick(CBlob @ this){
    
    if(this.hasTag("gravity_field"))return;
    if (this.isInInventory() || this.isAttached()) return;

    CBlob@[] blobs;
    
    getBlobsByTag("gravity_field", blobs);
    bool wasinfield = false;

    const string[] ignorelist = {"catapult", "ballista", "dinghy", "warboat", "longboat"};

    if (ignorelist.find(this.getName()) >= 0) return;
    
    for (u32 k = 0; k < blobs.length; k++)
    {
        CBlob@ blob = blobs[k];

        bool in_field = Maths::Sqrt(Maths::Pow(this.getPosition().x-blob.getPosition().x, 2)+Maths::Pow(this.getPosition().y-blob.getPosition().y, 2)) <= blob.get_u16("field_size");

        if(in_field && !this.hasTag("stopped") && this.getPlayer() is null && !this.getShape().isStatic()){
            
            if (!(this.hasTag("should add force") && !this.hasTag("add force again"))) 
                this.set_Vec2f("original velocity", this.getOldVelocity());
            this.set_f32("original grav", this.getShape().getGravityScale());

            //print("stopped " + this.getName());
            //print("set original velocity for " + this.getName() + " to " + this.getOldVelocity());
            //print("set original gravity for " + this.getName() + " to " + this.getShape().getGravityScale());
            //print("time " + getGameTime());

            this.getShape().SetStatic(true);
            this.getShape().SetGravityScale(0);
            //this.getShape().SetVelocity(Vec2f(0,0));
            //this.setVelocity(Vec2f(0,0));
            this.Tag("stopped");
            this.Tag("in stasis");
            this.set_u16("stopper", blob.getNetworkID());
            wasinfield = true;



            //this.Sync("stopped", true);
            //this.Sync("original velocity", true);
            //this.Sync("original grav", true);
        }

    }

    if (getGameTime() - this.get_u32("add force time")  > 0 && this.hasTag("should add force")) 
    {
        if (this.getName() != "arrow" && this.getName() != "ballista_bolt" && this.getName() != "golden_arrow")
        {
            //print("added force");
            this.setVelocity(this.getVelocity()+this.get_Vec2f("original velocity"));
        } 
            this.Untag("should add force");
            this.Untag("in stasis");
        
            this.Tag("add force again");
        //this.set_Vec2f("original velocity", Vec2f(0,0));
    }

    if (getBlobByNetworkID(this.get_u16("stopper")) is null && (this.hasTag("stopped") && (this.getShape().isStatic() || this.getName() == "spikes" || this.getName() == "ballista")))
    {
        this.Untag("stopped");
        this.getShape().SetStatic(false);
        this.getShape().SetGravityScale(this.get_f32("original grav"));
        int time = 1;
        if (this.getName() == "arrow") time = 1;
        this.set_u32("add force time", getGameTime()+time);
        this.Tag("should add force");
        this.set_u32("field exit time", getGameTime());
    }

}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    return (!this.hasTag("stopped") && !this.getShape().isStatic());
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
    return (!this.hasTag("stopped") || this.getName() == "crate" || this.getName() == "trampoline");
}