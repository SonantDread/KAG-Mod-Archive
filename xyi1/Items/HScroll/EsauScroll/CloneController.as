void onTick(CBlob@ this)
{
    if (this.getPlayer() !is null)
    {
        u16[] clones;

        if (this.get("clones", clones))
        {
            for (int i = 0; i < clones.size(); i++)
            {
                CBlob@ clone = getBlobByNetworkID(clones[i]);
                if (clone !is null)
                {
                    clone.setKeyPressed(key_up, this.isKeyPressed(key_up));
                    clone.setKeyPressed(key_down, this.isKeyPressed(key_down));
                    clone.setKeyPressed(key_left, this.isKeyPressed(key_left));
                    clone.setKeyPressed(key_right, this.isKeyPressed(key_right));
                    clone.setKeyPressed(key_action1, this.isKeyPressed(key_action1));
                    clone.setKeyPressed(key_action2, this.isKeyPressed(key_action2));

                    clone.setAimPos(clone.getPosition() + (this.getAimPos() - this.getPosition()));
                }
            }
        }
    }
}