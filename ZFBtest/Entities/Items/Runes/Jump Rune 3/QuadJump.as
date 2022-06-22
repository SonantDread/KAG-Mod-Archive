#include "RunnerMovement.as"
 int ju3 = 3; // 0
void onTick( CBlob@ blob )
{
// CBlob@ blob = this.getBlob();
 RunnerMoveVars@ moveVars;
    if (!blob.get( "moveVars", @moveVars )) {
        return;
    }
	const bool up		= blob.isKeyPressed(key_up);
		const bool onground = blob.isOnGround() || blob.isOnLadder();
	if(ju3 == 0)
				{
					if (moveVars.jumpCount > 7 && blob.isKeyPressed(key_up))
					{
					blob.AddForce(Vec2f(0,-440)); //-220
					 ju3 = 1; //1
					 moveVars.jumpCount = 0; //0
					}
					
				}
				if (ju3 == 1 && moveVars.jumpCount > 7 && blob.isKeyPressed(key_up))
						{
						blob.AddForce(Vec2f(0,-220));
						ju3 = 9; //2
						moveVars.jumpCount = 0; //0
						}
				if (ju3 == 2 && moveVars.jumpCount > 7 && blob.isKeyPressed(key_up))
							{
							blob.AddForce(Vec2f(0,-220));
							ju3 = 9; //3
							}
				if (onground)
						{
						ju3 = 0;
						}
	
}
 






