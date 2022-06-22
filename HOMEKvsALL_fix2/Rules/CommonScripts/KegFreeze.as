void onTick(CRules@ this)
{
    if (getLocalPlayer() is null || !getLocalPlayer().isMod())
    {
        return;
    }

    CControls@ controls = getLocalPlayer().getControls();

    if (controls is null)
    {
        return;
    }

    if (controls.isKeyJustPressed(KEY_F3))
    {
        CBlob@[] blobs;
        Vec2f pos = controls.getMouseWorldPos();

        if (getMap().getBlobsInRadius(pos, 16.0f, blobs))
        {
            for (int i = 0; i < blobs.size(); i++)
            {
                CBlob@ blob = blobs[i];
                if (blob is null) continue;

                if (blob.hasScript("KegVoodoo.as") || blob.hasScript("BouncyKegVoodoo.as"))
                {
                    blob.SendCommand(blob.getCommandID("deactivate"));
                }
            }
        }
    }
}