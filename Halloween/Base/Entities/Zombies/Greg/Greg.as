#include "EmotesCommon.as"
#include "KnockedCommon.as"

Random gregRand(Time());

void resetTimeout(CBlob@ this)
{
    this.set_u32("timeout", getGameTime());

}

u32 getElapsedTime(CBlob@ this)
{
    return getGameTime() - this.get_u32("timeout");

}

void pickRandTargetPos(CBlob@ this)
{
    CMap@ map = this.getMap();
    int width = map.tilemapwidth*8;
    Vec2f npos(Maths::Abs(gregRand.Next())%width, 20.0f + gregRand.Next()%40);
    this.set_Vec2f("target pos", npos);
    //printVec2f("greg go to", npos);

    this.set_bool("use pos", true);
    resetTimeout(this);

}

void pickRandPlayer(CBlob@ this)
{
    this.Untag("doneparis");
    this.Untag("paris");
    this.Sync("paris", true);
    this.Sync("doneparis", true);

    CBlob@[] players;
    getBlobsByTag("player", players);
    if (players.size() == 0)
    {
        this.set_bool("no target", true);
        pickRandTargetPos(this);
        return;

    }

    u16 targetId = players[gregRand.Next()%players.size()].getNetworkID();
    this.set_u16("targetId", targetId);
    this.set_bool("no target", false);
    this.set_bool("use pos", false);
    resetTimeout(this);

}

CBlob@ getTarget(CBlob@ this)
{
    if (this.get_bool("no target") || this.get_bool("use pos"))
    {
        return null;

    }

    u16 targetId = this.get_u16("targetId");
    CBlob@ target = getBlobByNetworkID(targetId);

    return target;

}

Vec2f getTargetPos(CBlob@ this)
{
    return this.get_Vec2f("target pos");

}

bool useTargetPos(CBlob@ this)
{
    return this.get_bool("use pos");

}

void onInit(CBlob@ this)
{
    pickRandTargetPos(this);
    this.getCurrentScript().tickFrequency = 5;

    CSprite@ sprite = this.getSprite();
    if (sprite !is null)
    {
        sprite.SetRelativeZ(2.0f);

    }

    Sound::Play("GregCry.ogg", this.getPosition());
    this.server_setTeamNum(255); //greg team
    this.addCommandID("legomyego");
    this.addCommandID("dropstatue");
    this.addCommandID("unstatue");
    this.set_s32("statue time", 0);
    this.Sync("statue time", true);

    this.getShape().setFriction(0.7);

}

void onTick(CBlob@ this)
{
    CSprite@ sprite = this.getSprite();
    if (sprite !is null)
    {
        if (this.hasTag("statue"))
        {
            if (sprite.animation.name == "default")
            {
                sprite.SetAnimation("statue");

            }

        }
        else
        {
            if (sprite.animation.name == "statue")
            {
                sprite.SetAnimation("default");

            }

        }

    }

    if (this.hasTag("statue"))
    {
        if (this.isOnGround())
        {
            s32 statuetime = this.get_s32("statue time");
            if (statuetime == 0)
            {
                this.set_s32("statue time", getGameTime() + 1);
                this.Sync("statue time", true);
                Vec2f pos = this.getPosition();
                pos.y += 16;

                /*CMap@ map = getMap();
                pos.x -= 8;
                TileType t = map.getTile(pos).type;
                float dmg = map.isTileWood(t) || map.isTileCastle(t) ? 100.0f : 1.0f;
                map.server_DestroyTile(pos, dmg, this);
                pos.x += 8;
                t = map.getTile(pos).type;
                dmg =  map.isTileWood(t) || map.isTileCastle(t) ? 100.0f : 1.0f;
                map.server_DestroyTile(pos, dmg, this);
                pos.x += 8;
                t = map.getTile(pos).type;
                dmg = map.isTileWood(t) || map.isTileCastle(t) ? 100.0f : 1.0f;
                map.server_DestroyTile(pos, dmg, this);*/

            }
            else
            {
                if (statuetime < getGameTime())
                {
                    this.set_s32("statue time", 0);
                    this.Sync("statue time", true);
                    ParticleZombieLightning(this.getPosition());
                    this.Untag("statue");
                    pickRandTargetPos(this);
                    this.SendCommand(this.getCommandID("unstatue"));

                    this.server_Hit(this, this.getPosition(), Vec2f(1, 1), 1.0f, 0);

                }

            }

        }

        return;

    }
    else
    {
        u16 id = this.getNetworkID();
        if ((getGameTime()+id)%70 == 0)
            Sound::Play("Wings.ogg", this.getPosition(), 0.5);

        Vec2f vel = this.getVelocity();

        bool faceLeft = (vel.x > 0);
        this.SetFacingLeft(faceLeft);

    }

    //do knocking logic
    DoKnockedUpdate(this);

    if (getNet().isServer())
    {

        CBlob@ target = getTarget(this);
        Vec2f targetP = getTargetPos(this);
        bool usepos = useTargetPos(this);

        bool targetAttached = this.isAttachedTo(target);

        //check if we need a new target.
        if ((target is null || target.hasTag("dead")) && !usepos)
        {
            pickRandTargetPos(this);
            return;

        }

        //in case greg gets stuck start doing something else
        if (!targetAttached)
        {
            u32 elapsed = getElapsedTime(this);
            if (usepos && elapsed > 30*10)
            {
                pickRandPlayer(this);

            }
            else if (target !is null && elapsed > 30*30) //go after player for a long time
            {
                pickRandTargetPos(this);

            }

        }

        if (isKnocked(this))
        {
            if (targetAttached)
            {
                this.server_DetachAll();
                target.Untag("picked");
                target.Sync("picked", true);
                pickRandTargetPos(this);

            }

            return;

        }

        //if on fire drop target
        s16 burn_time = this.get_s16("burn timer");
        if (this.isInFlames() || burn_time > 0)
        {
            if (targetAttached)
            {
                this.server_DetachAll();
                target.Untag("picked");
                target.Sync("picked", true);

            }

           pickRandTargetPos(this);

        }

        Vec2f vel = this.getVelocity();

        //set the facing of the greg towards the target
        if (!targetAttached)
        {
            bool faceLeft = (vel.x > 0);
            this.SetFacingLeft(faceLeft);

        }

        if (targetAttached)
        {
	        CPlayer@ local = getLocalPlayer();
	        if (local !is null)
	        {

                CControls@ controls = getControls();

                u16 count = this.get_u16("struggle count");

                count += controls.isKeyJustPressed(KEY_KEY_A) ? 1 : 0;
                count += controls.isKeyJustPressed(KEY_KEY_D) ? 1 : 0;
                count += controls.isKeyJustPressed(KEY_KEY_W) ? 1 : 0;
                count += controls.isKeyJustPressed(KEY_KEY_S) ? 1 : 0;
                count += controls.isKeyJustPressed(KEY_SPACE) ? 1 : 0;
                count += controls.isKeyJustPressed(KEY_KEY_C) ? 1 : 0;
                count += controls.isKeyJustPressed(KEY_KEY_F) ? 1 : 0;
                count += controls.isKeyJustPressed(KEY_KEY_E) ? 1 : 0;

                this.set_u16("struggle count", count);
                //print("oggly booogly count: " + count);

                if (count > 65)
                {
                    this.SendCommand(this.getCommandID("legomyego"));
                    this.set_u16("struggle count", 0);

                }

            }

        }

        Vec2f targetPos = usepos ? targetP : target.getPosition();

        if (!usepos) //hack so gregs don't have to fly low
        {
            targetPos.y = 45;

        }

        bool targetAbove = targetPos.y < this.getPosition().y;
        float flapVel = targetAbove || targetAttached ? 4 : 5;

        if (vel.y > flapVel) //flap to slow decent
        {
            float rat = flapVel/4.0f;
            //120 is enough for a strong flap which actually caries the greg up
            this.setVelocity(Vec2f(vel.x, flapVel*0.96));

            //if we have our target flap into the air.
            f32 force = 70.0f*rat;
            if (targetAttached || targetAbove)
            {
                force += 35.0f;

            }

            this.AddForce(Vec2f(0, -force));

        }
        else if (this.isOnGround()) //get off the ground
        {
            this.setVelocity(Vec2f(vel.x, 0.0f));
            this.AddForce(Vec2f(0, -70.0f));

        }

        Vec2f gregPos = this.getPosition();

        //if we are close to our node
        Vec2f dif = targetPos - gregPos;
        if (usepos && dif.Length() < 25.0f)
        {
            pickRandPlayer(this);

        }

        if (getNet().isServer() && target !is null)
        {
            CMap@ map = getMap();
            Vec2f fpos;
            Vec2f dpos(this.getPosition().x, target.getPosition().y);
            map.rayCastSolidNoBlobs(this.getPosition(), dpos, fpos);
            Vec2f len = target.getPosition() - fpos;
            if (len.getLength() <= 4.0)
            {
                if (!targetAttached)
                {
                    this.Tag("statue");
                    this.SendCommand(this.getCommandID("dropstatue"));
                    this.setVelocity(Vec2f(target.getVelocity().x*0.95, 0));
                    return;
                }
                else
                {
                    CMap@ map = this.getMap();
                    f32 distToGround = map.getLandYAtX(gregPos.x/8.0f)*8.0f - gregPos.y;
                    if (distToGround > 240.0f && !is_emote(this, Emotes::troll) && !this.hasTag("doneparis"))
                    {
                        if (this.hasTag("paris"))
                        {
                            this.Tag("doneparis");
                            this.Sync("doneparis", true);
                            this.Chat("i lied.");
                        }

                        target.Untag("picked");
                        target.Sync("picked", true);

                        set_emote(this, Emotes::troll);

                    }

                    if (distToGround > 260.0f)
                    {
                        //detach and add some velocity so they hopefully die.
                        this.server_DetachAll();
                        this.set_bool("no target", true);
                        //target.setVelocity(Vec2f(0, 8.0f));

                    }
                }
            }

        }

        if (targetAttached)
        {
            //drop the player
            CMap@ map = this.getMap();
            f32 distToGround = map.getLandYAtX(gregPos.x/8.0f)*8.0f - gregPos.y;
            if (distToGround > 240.0f && !is_emote(this, Emotes::troll) && !this.hasTag("doneparis") || this.get_s32("attach time") - getGameTime() > 150)
            {
                if (this.hasTag("paris"))
                {
                    this.Tag("doneparis");
                    this.Sync("doneparis", true);
                    this.Chat("i lied.");
                }

                target.Untag("picked");
                target.Sync("picked", true);

                set_emote(this, Emotes::troll);

            }

            if (distToGround > 260.0f || this.get_s32("attach time") - getGameTime() > 150)
            {
                //detach and add some velocity so they hopefully die.
                this.server_DetachAll();
                target.Untag("picked");
                target.Sync("picked", true);
                this.set_bool("no target", true);
                target.setVelocity(Vec2f(0, 4.0f));

            }

        }

        f32 absVelx = Maths::Abs(vel.x);
        //don't accelarte to quickly
        if (absVelx < 5)
        {
            //calculate a rough distance factor to mult by
            f32 xdist = (gregPos.x - targetPos.x)/50.0f;
            xdist = Maths::Min(Maths::Abs(xdist), 1.0f);

            f32 force = xdist*5.0f;

            f32 stopping = absVelx/8.0f;

            //move towards target
            if (gregPos.x > targetPos.x)
            {
                this.AddForce(Vec2f(-force, 0));

                //apply a stopping force so we start going the other dir quicker
                if (vel.x > 0)
                {
                    this.AddForce(Vec2f(-40.0f*stopping, 0));

                }

            }
            else if (gregPos.x < targetPos.x)
            {
                this.AddForce(Vec2f(force, 0));

                if (vel.x < 0)
                {
                    this.AddForce(Vec2f(40.0f*stopping, 0));

                }


            }

        }

    }

}

void onDie( CBlob@ this )
{
    CBlob@ pickedPlayerBlob = this.getAttachmentPoint(0).getOccupied();


    if (pickedPlayerBlob !is null)
    {
        pickedPlayerBlob.Untag("picked");
        pickedPlayerBlob.Sync("picked", true);
    }
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
    if (isKnocked(this) || blob is null)
    {
        return;

    }

    /*if (this.hasTag("statue"))
    {
        if (blob !is null && blob.hasTag("flesh") && !this.isOnGround())
        {
            if (getNet().isServer())
            {
                this.server_Hit(blob, blob.getPosition(), Vec2f(1, 1), 500.0f, 0);
                if (gregRand.Next()%3 == 0)
                    set_emote(this, Emotes::troll);

            }

        }

    }*/

    CBlob@ target = getTarget(this);
    if (target is blob && !target.hasTag("picked"))
    {
        target.Tag("picked");
        target.Sync("picked", true);

        this.set_s32("statue time", 0);
        this.Sync("statue time", true);
        this.set_u16("struggle count", 0);
        this.server_AttachTo(blob, this.getAttachmentPoint(0));
        this.set_s32("attach time", getGameTime());
        this.sync("attach time");
        this.setVelocity(Vec2f_zero);
        this.AddForce(Vec2f(0, -30.0f)); //get a little hop up into the air going.

        this.Tag("paris");
        this.Sync("paris", true);
        this.Chat("we're going to paris.");
        Sound::Play(getTranslatedString("MigrantSayHello") + ".ogg", this.getPosition());
        Sound::Play("GregRoar.ogg", this.getPosition()); //play sound

        setKnocked(blob, 60); //knock the player when we first pick them up so they can't fight back
        blob.Tag("dazzled");

        //make player play the stunned sound
        blob.getSprite().PlaySound("Stun.ogg", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);

    }

}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("legomyego"))
    {
        this.server_DetachAll();
        this.set_bool("no target", true);
        set_emote(this, Emotes::mad);

    }

    if (cmd == this.getCommandID("dropstatue") && getNet().isClient())
    {
        this.server_DetachAll();
        set_emote(this, Emotes::mad);
        this.Tag("statue");
        //this.setVelocity(Vec2f_zero);

    }
    else if (cmd == this.getCommandID("unstatue") && getNet().isClient())
    {
        this.Untag("statue");

    }

}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if (this.hasTag("statue"))
        return 0.0f;
    return damage;

}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
    return blob.getName() != "greg";

}
