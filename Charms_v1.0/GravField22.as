
void onInit(CBlob@ this)
{

	this.getSprite().SetZ(-100);
	
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.SetGravityScale(0.0);
	shape.SetStatic(true);
	
	this.getSprite().setRenderStyle(RenderStyle::light);
	
	this.Tag("gravity_field");
	this.set_u16("field_size",88);
	
	//if(getNet().isServer())
	this.server_SetTimeToDie(5);
}

void onDie(CBlob@ this)
{

    CBlob@[] all;
    getBlobs( @all );
    for (u32 i=0; i < all.length; i++)
    {       
        CBlob@ blob = all[i];
        if (blob is null) continue;
        if (blob.isInInventory() || blob.hasTag("gravity_field") || (blob.isAttached() && blob.getName() != "spikes")) continue;

        //bool wasinfield = Maths::Sqrt(Maths::Pow(this.getPosition().x-blob.getPosition().x, 2)+Maths::Pow(this.getPosition().y-blob.getPosition().y, 2)) <= blob.get_u16("field_size") + 60;
        
        if (blob.hasTag("stopped") && (blob.getShape().isStatic() || blob.getName() == "spikes" || blob.getName() == "ballista") && blob.get_u16("stopper") == this.getNetworkID())
            {
                blob.Untag("stopped");
                blob.getShape().SetStatic(false);
                blob.getShape().SetGravityScale(blob.get_f32("original grav"));
                int time = 1;
                if (blob.getName() == "arrow") time = 1;
                blob.set_u32("add force time", getGameTime()+time);
                blob.Tag("should add force");
                blob.set_u32("field exit time", getGameTime());

                //print(blob.getName()+" exited the field");
                //print("set " +blob.getName()+"'s velocity to " + blob.get_Vec2f("original velocity"));
            }
	}
}