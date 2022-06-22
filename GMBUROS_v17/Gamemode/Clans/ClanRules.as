#include "GetPlayerData.as"
#include "ClanCommon.as";

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if(player is null)return true;
	CBlob @blob = player.getBlob();
	if(blob is null)return true;

	if (text_in.substr(0, 1) == "!")
	{
		// check if we have tokens
		string[]@ tokens = text_in.split(" ");

		if (tokens.length > 1)
		{
			if(tokens[0].toLower() == "!clan"){
				string name = tokens[1];
				name = name.replace("=", "");
				if(name != ""){
					if(blob.hasBlob("gold_bar",5)){
						bool alreadyInClan = (getBlobClan(blob) != 0);
					
						if(!alreadyInClan){
							int ID = getNextClanID();
							
							CBlob @clan = server_CreateBlobNoInit("clan");
							if(clan !is null){
								blob.TakeBlob("gold_bar",5);
						
								clan.set_string("name",name);
								clan.set_u16("ClanID",ID);
								clan.set_string("leader",player.getUsername());
								clan.set_u8("Level",1);
								//Clan info doesn't need to be synced before oninit
								
								string[] members;
								members.push_back(player.getUsername());
								clan.set("members",@members);
								//Arrays do need to be synced but Clan.as syncs it automatically
								
							
								clan.Init();
							}
						}
					}
				}
				return false;
			}
		}
	}

	return true;
}