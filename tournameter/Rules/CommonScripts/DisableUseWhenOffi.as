void onTick(CRules@ this)
{
    if (this.hasTag("offi match"))
    {    
        CBlob@[] blobs;
        getBlobsByTag("player", @blobs);
        for (uint i = 0; i < blobs.length; i++)
        {
            CBlob@ blob = blobs[i];
            blob.DisableKeys(key_use);    
        }        
    }        
}
