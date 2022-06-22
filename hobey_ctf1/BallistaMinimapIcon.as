
void onInit(CBlob@ this)
{
    this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
    // this.SetMinimapVars("../Mods/HobeyMinimap2/BallistaIcon.png", 0, Vec2f(7, 8));
    this.SetMinimapVars("../Mods/HobeyMinimap2/BallistaIcon.png", 0, Vec2f(9, 10));
    // this.SetMinimapRenderAlways(true);
    this.SetMinimapRenderAlways(false);
    
    this.getCurrentScript().runFlags |= Script::remove_after_this;
}
