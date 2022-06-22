const f32 moveForce = 70.0f;
const f32 jumpForce = 500.0f;
const f32 dashForce = 2000.0f;

void onInit(CMovement@ this)
{
    this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CMovement@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null) return;
    CShape@ shape = blob.getShape();
    if (shape is null) return;

    if (blob.getPlayer() !is null)
    {
        blob.SetDamageOwnerPlayer(blob.getPlayer());
        blob.server_setTeamNum(blob.getPlayer().getTeamNum());
    }

    if (//(ultimately in charge of this blob's movement)
        (blob.isMyPlayer()) ||
        (blob.isBot() && isServer())
    ) {
        HandleStuckAtTop(blob);
    }

    const bool left     = blob.isKeyPressed(key_left);
    const bool right    = blob.isKeyPressed(key_right);
    const bool up       = blob.isKeyPressed(key_up);
    const bool down     = blob.isKeyPressed(key_down);
    const bool lmb      = blob.isKeyPressed(key_action1);
    const bool rmb      = blob.isKeyPressed(key_action2);

    if (down || rmb)
    {
        shape.SetGravityScale(1.5f);
    }
    else
    {
        shape.SetGravityScale(1.0f);
    }

    if (left || right)
    {
        blob.AddForce(Vec2f(left ? -moveForce : moveForce, 0));
    }

    if (up && blob.isOnGround())
    {
        shape.SetGravityScale(0.5f);
        blob.AddForce(Vec2f(0, -jumpForce));
    }

    if (up && (left || right) && blob.isOnWall())
    {
        shape.SetGravityScale(0.5f);
        if (left && getMap().rayCastSolid(blob.getPosition(), blob.getPosition() - Vec2f(10.0f, 3)))
        {
            blob.AddForce(Vec2f(-moveForce, -moveForce * 1.9f));
        }
        else if (right && getMap().rayCastSolid(blob.getPosition(), blob.getPosition() + Vec2f(10.0f, 3)))
        {
            blob.AddForce(Vec2f(moveForce, -moveForce * 1.9f));
        }
    }

    if (lmb && getGameTime() - blob.get_u32("dash_time") > 45)
    {
        Vec2f direction = blob.getAimPos() - blob.getPosition();
        direction.Normalize();


        blob.server_DetachFromAll();
        blob.AddForce(direction * dashForce);
        blob.set_u32("dash_time", getGameTime());
    }
}

void HandleStuckAtTop(CBlob@ this)
{
    Vec2f pos = this.getPosition();
    //at top of map
    if (pos.y < 16.0f)
    {
        CMap@ map = getMap();
        float y = 2.5f * map.tilesize;
        //solid underneath
        if (map.isTileSolid(Vec2f(pos.x, y)))
        {
            //"stuck"; check left and right
            int rad = 10;
            bool found = false;
            float tx = pos.x;
            for (int i = 0; i < rad && !found; i++)
            {
                for (int dir = -1; dir <= 1 && !found; dir += 2)
                {
                    tx = pos.x + (dir * i) * map.tilesize;
                    if (!map.isTileSolid(Vec2f(tx, y)))
                    {
                        found = true;
                    }
                }
            }
            if (found)
            {
                Vec2f towards(tx - pos.x, -1);
                towards.Normalize();
                this.setPosition(pos + towards * 0.5f);
                this.AddForce(towards * 10.0f);
            }
        }
    }
}

