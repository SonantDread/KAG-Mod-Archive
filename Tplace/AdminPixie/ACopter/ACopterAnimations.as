
void onInit(CSprite@ this)
{
    CBlob@ b = this.getBlob();
    b.set_f32("size",0);
    this.SetZ(1450);// draw over ground
}

const f32 speedConst = 0.1; //this is a arbitrary value :D

void onTick(CSprite@ this)
{
    if(this.getBlob().getPlayer() is getLocalPlayer())
    {
        getHUD().SetCursorImage("arrow_cursor.png");
    }
    this.ResetTransform();
    this.RotateBy(Maths::Clamp(this.getBlob().getVelocity().x/32.0f * 180,-45,45), Vec2f_zero);   
}

void onRender(CSprite@ this)
{
    f32 scale = 1;
    Vec2f mpos = getControls().getMouseScreenPos();
    CBlob@ blob = this.getBlob();
    if(getLocalPlayer() is blob.getPlayer())
    {
        int width = 93 * 2;
        int height = 44;
        int teamNum = blob.getTeamNum();

        Vec2f checkbox1 = Vec2f(57,8) * scale;
        Vec2f checkbox2 = Vec2f(57,26) * scale;

        Vec2f mainPos = Vec2f(getScreenWidth() - width * scale - 20, 20);
    }
}