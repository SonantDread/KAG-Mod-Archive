bool isEnemy(CBlob@ this, CBlob@ target)
{
	CBlob@ friend = getBlobByNetworkID(target.get_netid("brain_friend_id"));
	return (
		(target.hasTag("flesh") || target.hasTag("zombie"))
		&& (target.getTeamNum() != this.getTeamNum() && !target.hasTag("dead"))
		&& (friend is null
			|| (friend.getTeamNum() != this.getTeamNum() && !friend.hasTag("dead"))
		)
	);
}