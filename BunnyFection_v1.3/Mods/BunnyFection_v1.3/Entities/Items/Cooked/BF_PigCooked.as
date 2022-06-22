// BF_Carrot script

void onInit( CBlob@ this )
{  
	CSprite@ sprite = this.getSprite();
	sprite.SetZ(10.0f);
    sprite.PlaySound("/BF_CarrotPop.ogg", 2.0f);
	sprite.SetFrameIndex( this.get_u8( "growth_level" ) );
	this.setVelocity(Vec2f((XORRandom(2) == 0 ? -1 : 1) * 2, -2));
	this.SetFacingLeft(XORRandom(2) == 0);
	//print( "initGrowLVL: " + this.get_u8( "growth_level" ) );
	this.Tag( "flora" );
}

void Nibble( CBlob@ this, CBlob@ blob )
{
    if (blob.hasTag("player") && !blob.hasTag("mutant"))
    {
		
    }
}

void onCollision ( CBlob@ this, CBlob@ blob, bool solid )
{
    if (blob is null)
    {
        return;
    }
    if (getNet().isServer() && !blob.hasTag("dead")) 
    {
        Nibble( this, blob );
    }
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
    if (getNet().isServer()) 
    {
        Nibble( this, attached );
    }
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint )
{
    if (getNet().isServer()) 
    {
        Nibble( this, detached );
    }
}