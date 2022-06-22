//Zable was a great help with finding problems and suggesting features.

enum CommandType//For the interactive help menu (todo)
{
    Debug = 1,
    Testing,
    Legacy,
    Template,
    TODO,
    Info,
    Moderation,
    Stupid,
    BeyondStupid,
}

enum PermissionLevel//For what you need to use what command.
{
    pModerator = 1,
    pAdmin,
    pSuperAdmin,
    pBan,
    pUnban,
    pKick,
    pFreeze,
    pMute,
}

shared interface ICommand
{
    void Setup(string[]@ tokens);

    void RefreshVars();
    
    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob);

    bool canUseCommand(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob);

    bool isActive();
    void setActive(bool value);

    string inGamemode();
    void setGamemode(string value);

    array<int> getNames();
    void setNames(array<int> value);
    
    u16 getPermLevel();
    void setPermLevel(u16 value);

    u16 getCommandType();
    void setCommandType(u16 value);
    
    u8 getTargetPlayerSlot();
    void setTargetPlayerSlot(u8 value);
    
    bool getTargetPlayerBlobParam();
    void setTargetPlayerBlobParam(bool value);

    bool getNoSvTest();
    void setNoSvTest(bool value);

    bool getBlobMustExist();
    void setBlobMustExist(bool value);

    u8 getMinimumParameterCount();
    void setMinimumParameterCount(u8 value);

}

class CommandBase : ICommand
{
    
    //Happens only once when the command is first created.
    CommandBase()
    {
        //Commented out as I'm too lazy to add constructors to all the classes myself.
        //error("Command missing constructor");    
    }

    //Happens every time someone sends a message with ! as the first character. This is done as commands may differ depending on the amount of parameters given.
    void Setup(string[]@ tokens)//TODO - Find a more fitting name opposed to "Setup". This happens every time someone sends a message with ! as the first character. Better name please.    
    {
        error("SETUP METHOD NOT FOUND!");
    }

    //Happens right before Setup(), this refreshes the variables to prevent problems.
    void RefreshVars()
    {
        permlevel = 0;
        commandtype = 0;
        target_player_slot = 0;
        target_player_blob_param = true;
        no_sv_test = false;
        blob_must_exist = true;
        minimum_parameter_count = 0;
    }
    //What the command does. This happens as long as all the other checks went through.
    bool CommandCode(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob, Vec2f pos, int team, CPlayer@ target_player, CBlob@ target_blob)
    {
        error("COMMANDCODE METHOD NOT FOUND!");
        return false;
    }
    //Happens before CommandCode, confirms that the player can indeed use this command.
    bool canUseCommand(CRules@ rules, string[]@ tokens, CPlayer@ player, CBlob@ blob)
    {
        bool _sv_test = sv_test;
        CSecurity@ security = getSecurity();


        if(blob_must_exist)
        {
            if(blob == null)
            {
                sendClientMessage(player, "Your blob appears to be null, this command will not work unless your blob actually exists.");
                return false;
            }
        }

        if(no_sv_test)
        {
            _sv_test = false;
        }

        //Is okay to use if in the specified gamemode.
        if(in_gamemode == rules.gamemode_name)
        {
            _sv_test = true;
        }


        //Security check.
        if(permlevel == pModerator && !player.isMod() && !_sv_test)
        {
            sendClientMessage(player, "You must be a moderator or higher to use this command.");
            return false;
        }
        if(permlevel == pAdmin && !security.checkAccess_Command(player, "admin_color") && !_sv_test)
        {
            sendClientMessage(player, "You must be a admin or higher to use this command.");
            return false;
        }
        if(permlevel == pSuperAdmin && !security.checkAccess_Command(player, "ALL") && !_sv_test)
        {
            sendClientMessage(player, "You must be a superadmin to use this command.");
            return false;
        }
        if(permlevel == pFreeze && (!security.checkAccess_Command(player, "freezeid") || !getSecurity().checkAccess_Command(player, "unfreezeid")))
        {
            sendClientMessage(player, "You do not sufficient permissions to freeze and unfreeze a player.");
            return false;
        }
        if(permlevel == pKick && !security.checkAccess_Command(player, "kick"))
        {
            sendClientMessage(player, "You do not sufficient permissions to kick a player.");
            return false;
        }
        if(permlevel == pUnban && !security.checkAccess_Command(player, "unban")){
            sendClientMessage(player, "You do not sufficient permissions to unban a player.");
            return false;
        }
        if(permlevel == pBan && !security.checkAccess_Command(player, "ban")){
            sendClientMessage(player, "You do not sufficient permissions to ban a player.");
            return false;
        }
        if(permlevel == pMute && (!security.checkAccess_Command(player, "mute") || !security.checkAccess_Command(player, "unmute"))){
            sendClientMessage(player, "You do not sufficient permissions to mute a player.");
            return false;
        }



        //Minimum parameter check
        if(tokens.size() < minimum_parameter_count + 1)
        {
            sendClientMessage(player, "This command requires at least " + minimum_parameter_count + " parameters.");
            return false;
        }

        return true;
    }

    private bool active = true;//If this is false, this command is disabled and unusable (People will all permissions I.E rcon access bypass this).
    bool isActive() { return active; }
    void setActive(bool value) { active = value; }

    private string in_gamemode = "xxxxx";//If the gamemode is equal to this, this command can be used without its specified permissions.
    string inGamemode(){ return in_gamemode; }
    void setGamemode(string value) { in_gamemode = value; }

    private array<int> names(4);//Names to call this command. If more than 4 are desired, use names.push_back();
    array<int> getNames() { return names; }
    void setNames(array<int> value) { names = value; }

    private u16 permlevel = 0;//The role/permission required to use this command. 0 is nothing.
    u16 getPermLevel(){ return permlevel; }
    void setPermLevel(u16 value) { permlevel = value; }

    private u16 commandtype = 0;//The type of command. For the moment this does nothing and can be ignored.
    u16 getCommandType() { return commandtype; }
    void setCommandType(u16 value){ commandtype = value; }

    private u8 target_player_slot = 0;//Specifies what param is expected to have a username. Gets this player and puts it into target_player
    u8 getTargetPlayerSlot() { return target_player_slot;}
    void setTargetPlayerSlot(u8 value) { target_player_slot = value; }

    private bool target_player_blob_param = false;//Specifies if target_blob is supposed to come with the target_player. target_player_slot must be specified for this to take effect.
    bool getTargetPlayerBlobParam() { return target_player_blob_param; }
    void setTargetPlayerBlobParam(bool value) { target_player_blob_param = value; }

    private bool no_sv_test = false;//All commands besides those specified with no_sv_test = true; can be used when sv_test is 1.
    bool getNoSvTest() { return no_sv_test; }
    void setNoSvTest(bool value) { no_sv_test = value; }

    private bool blob_must_exist = true;//If this is true, when the player's blob does not exist the command code will not run and the player will be informed that their blob is null.
    bool getBlobMustExist() { return blob_must_exist; }
    void setBlobMustExist(bool value) { blob_must_exist = value; }

    private u8 minimum_parameter_count = 0;//The minimum amount of parameters that must be used in this command.
    u8 getMinimumParameterCount() { return minimum_parameter_count; }
    void setMinimumParameterCount(u8 value) { minimum_parameter_count = value; }
}

















//Rules, what player the command is being sent to, what is the message?
void sendClientMessage(CPlayer@ player, string message)
{
    CRules@ rules = getRules();

	CBitStream params;//Assign the params
	params.write_string(message);
    params.write_u8(255);
    params.write_u8(255);
    params.write_u8(0);
    params.write_u8(0);

	rules.SendCommand(rules.getCommandID("clientmessage"), params, player);
}
void sendClientMessage(CPlayer@ player, string message, SColor color)//Now with color
{
    CRules@ rules = getRules();

	CBitStream params;//Assign the params
	params.write_string(message);
    params.write_u8(color.getAlpha());
    params.write_u8(color.getRed());
    params.write_u8(color.getGreen());
    params.write_u8(color.getBlue());

	rules.SendCommand(rules.getCommandID("clientmessage"), params, player);
}

void sendEngineMessage(CPlayer@ player, string message)
{
    CRules@ rules = getRules();

	CBitStream params;//Assign the params
	params.write_string(message);

	rules.SendCommand(rules.getCommandID("enginemessage"), params, player);
}

//Get an array of players that have "shortname" at the start of their username. If their username is exactly the same, it will return an array containing only that player.
array<CPlayer@> getPlayersByShortUsername(string shortname)
{
    array<CPlayer@> playersout;//The main array for storing all the players which contain shortname

    for(int i = 0; i < getPlayerCount(); i++)//For every player
    {
        CPlayer@ player = getPlayer(i);//Grab the player
        string playerusername = player.getUsername();//Get the player's username

        if(playerusername == shortname)//If the name is exactly the same
        {
            array<CPlayer@> playersoutone;//Make a quick array
            playersoutone.push_back(player);//Put the player in that array
            return playersoutone;//Return this array
        }

        if(playerusername.substr(0, shortname.length()) == shortname)//If the players username contains shortname
        {
            playersout.push_back(player);//Put the array.
        }
    }
    return playersout;//Return the array
}

//Uses the above getPlayersByShortUsername method.
CPlayer@ getPlayerByShortUsername(string shortname)
{
    array<CPlayer@> target_players = getPlayersByShortUsername(shortname);//Get a list of players that have this as the start of their username
    if(target_players.length() > 1)//If there is more than 1 player in the list
    {
        string playernames = "";
        for(int i = 0; i < target_players.length(); i++)//for every player in that list
        {
            playernames += " : " + target_players[i].getUsername();//put their name in a string
        }
        print("There is more than one possible player for the player param" + playernames);//tell the client that these players in the string were found
        return @null;//don't send the message to chat, don't do anything else
    }
    else if(target_players == null || target_players.length == 0)
    {
        print("No player was found for the player param.");
        return @null;
    }
    return target_players[0];
}

string TagSpecificBlob(CBlob@ targetblob, string typein, string namein, string input)
{
    if(targetblob == null)
    {
        return "something weird happened when assigning tags";
    }

    if(typein == "u8")
    {
        u8 innum = parseInt(input);
        targetblob.set_u8(namein, innum);
    }
    else if(typein == "s8")
    {
        s8 innum = parseInt(input);
        targetblob.set_s8(namein, innum);
    }
    else if(typein == "u16")
    {
        u16 innum = parseInt(input);
        targetblob.set_u16(namein, innum);
    }
    else if(typein == "s16")
    {
        s16 innum = parseInt(input);
        targetblob.set_s16(namein, innum);
    }
    else if(typein == "u32")
    {
        u32 innum = parseInt(input);
        targetblob.set_u32(namein, innum);
    }
    else if(typein == "s32")
    {
        s32 innum = parseInt(input);
        targetblob.set_s32(namein, innum);
    }
    else if(typein == "f32")
    {
        float innum = parseFloat(input);
        targetblob.set_f32(namein, innum);
    }
    else if(typein == "bool")
    {
        
        if (input == "true" || input == "1")
        {
            targetblob.set_bool(namein, true);
        }
        else if (input == "false" || input == "0")
        {
            targetblob.set_bool(namein, false);
        }
        else
        {
            return "True or false, it isn't that hard";
        }
    }
    else if(typein == "string")
    {
        targetblob.set_string(namein, input);
    }
    else if(typein == "tag")
    {
        if(input == "true" || input == "1")
        {
            targetblob.Tag(namein);
        }
        else if (input == "false" || input == "0")
        {
            targetblob.Untag(namein);
        }
        else
        {
            return "Set the value to true, to tag. Set the value to false, to untag.";
        }
    }
    else
    {
        return "typein " + typein + " is not one of the types you can use.";
    }

    targetblob.Sync(namein, true);
    
    return "";
}


//When getting blobs, returns netid's
//When getting players, returns usernames
string atFindAndReplace(Vec2f point, string text_in, bool skip_one = true, bool skip_unactive_and_inventory = true)
{
    string text_out;
    
    string[]@ tokens = text_in.split(" ");
    
    array<CPlayer@> target_players();

    array<CBlob@> target_blobs();

    s8 skip_count = 0;
    if(skip_one)
    {
        skip_count = 1;
    }

    u16 replaced_tokens = 0;

    u16 old_replaced_tokens = replaced_tokens;

    for(u16 q = 0; q < tokens.size(); q++)
    {

        //replaced_tokens < 5 is only added to prevent people from using @whatever so many times in a sentence that it lags the server.
        if(tokens[q].substr(0,1) == "@" && tokens[q].size() > 1 && replaced_tokens < 5)
        {
            string _str = tokens[q].substr(1, tokens[q].length());
            string _str_0 = _str.substr(0, 1);

            for(;;)//No loops, only done so I can break out whenever and easily.
            {
                if(_str == "closeplayer" || _str == "closep" || _str_0 == "p")
                {
                    if(_str_0 == "p")
                    {
                        string _str_1 = _str.substr(1, _str.size());
                        if(_str_1.size() == 0 || !IsDigitsOnly(_str_1))
                        {
                            break;
                        }
                        
                        skip_count = parseInt(_str_1);
                    }


                    if(target_players.size() == 0)
                    {
                        target_players = SortPlayersByDistance(point, 99999999, skip_unactive_and_inventory);
                    }

                    if(target_players.size() > skip_count)
                    {
                        _str = target_players[skip_count].getUsername();
                        replaced_tokens++;
                    }
                }
                else if(_str == "closeblob" || _str == "closeb" || _str_0 == "b")
                {
                    if(_str_0 == "b")
                    {
                        string _str_1 = _str.substr(1, _str.size());
                        if(_str_1.size() == 0 ||!IsDigitsOnly(_str_1))
                        {
                            break;
                        }
                        
                        skip_count = parseInt(_str_1);
                    }

                    if(target_blobs.size() == 0)
                    {
                        array<CBlob@> _blobs;
                        getBlobs(_blobs);
                        target_blobs = SortBlobsByDistance(point, 99999999, _blobs, skip_unactive_and_inventory);
                    }
                    
                    if(target_blobs.size() > skip_count)
                    {
                        _str = target_blobs[skip_count].getNetworkID();
                        replaced_tokens++;
                    }
                }
                else if(_str == "farplayer" || _str == "farp")//Farp
                {
                    if(target_players.size() == 0)
                    {
                        target_players = SortPlayersByDistance(point, 99999999, skip_unactive_and_inventory);
                    }

                    if(target_players.size() != 0)
                    {
                        _str = target_players[target_players.size() - 1].getUsername();
                        replaced_tokens++;
                    }
                }
                else if(_str == "farblob" || _str == "farb")
                {
                    if(target_blobs.size() == 0)
                    {
                        array<CBlob@> _blobs; 
                        getBlobs(_blobs);
                        target_blobs = SortBlobsByDistance(point, 99999999, _blobs, skip_unactive_and_inventory);
                    }
                    if(target_blobs.size() != 0)
                    {
                        _str = target_blobs[target_blobs.size() - 1].getNetworkID();
                        replaced_tokens++;
                    }
                }

                break;
            }
            
            tokens[q] = (replaced_tokens == old_replaced_tokens ? "@" : "") + _str;
            old_replaced_tokens = replaced_tokens;
        }


        string _space = " ";
        if(q == 0){ _space = ""; }

        text_out += _space + tokens[q];
    }
    
    return text_out;
}
//IDEAS
//Team versions i.e @closeblobonsameteam or @closeblobnotonsameteam.
//Specify value of which. I.E @blob3 to get the third closest blob. @blob0 to get your blob


//Players without blobs are not included in the array.
array<CPlayer@> SortPlayersByDistance(Vec2f point, f32 radius, bool skip_unactive_and_inventory = true)
{
    u16 i;

    u16 non_null_count = 0;
    
    array<CBlob@> playerblobs(getPlayerCount());

    //Put all blobs in playerblobs array
    for(i = 0; i < playerblobs.size(); i++)
    {
        CPlayer@ player = getPlayer(i);
        if(player != null)
        {
            CBlob@ player_blob = player.getBlob();
            
            if(player_blob != null//If the player has a blob. 
            && (!skip_unactive_and_inventory || player_blob.isActive() || !player_blob.isInInventory()))//And if skip_unactive is true, only if the blob is active and not in an inventory.
            {
                @playerblobs[non_null_count] = @player_blob;
                non_null_count++;
            }
        }
    }

    playerblobs.resize(non_null_count);

    playerblobs = SortBlobsByDistance(point, radius, playerblobs);
    
    array<CPlayer@> sorted_players(playerblobs.size());

    for(i = 0; i < non_null_count; i++)
    {
        @sorted_players[i] = @playerblobs[i].getPlayer();
    }

    return sorted_players;
}

//Blobs outside of the radius are not included within the returned array.
array<CBlob@> SortBlobsByDistance(Vec2f point, f32 radius, array<CBlob@> blob_array, bool skip_unactive_and_inventory = false)
{
    u16 i, j;

    array<CBlob@> sorted_array(blob_array.size());

    array<f32> blob_dist(blob_array.size());

    u16 non_null_count = 0;

    for (i = 0; i < blob_array.size(); i++)//Make an array that contains the distance that each blob is from the point.
    {
        if(blob_array[i] == null//If the blob does not exist
        || (skip_unactive_and_inventory && (blob_array[i].isActive() == false || blob_array[i].isInInventory())))//Or skip_unactive is true and the blob is not active or in an inventory
        {
            continue;//Do not add this to the array
        }

        f32 dist = (blob_array[i].getPosition() - point).getLength();//Find the distance from the point to the blob
        
        if(dist > radius) //If the distance to the blob from the point is greater than the radius.
        {
            continue;//Do not add this to the array
        }

        @sorted_array[non_null_count] = blob_array[i];

        blob_dist[non_null_count] = dist;
        
        non_null_count++;
    }

    sorted_array.resize(non_null_count);//Resize to remove nulls
    blob_dist.resize(non_null_count);//This too. Null things don't have positions to calculate the distance between it and the point given.
    
    for (j = 1; j < non_null_count; j++)//Insertion sort each blob.
    {
        for(i = j; i > 0 && blob_dist[i] < blob_dist[i - 1]; i--)
        {
            //Swap
            float _dist = blob_dist[i - 1];
            blob_dist[i - 1] = blob_dist[i];
            blob_dist[i] = _dist;
            //Swap
            CBlob@ _blob = sorted_array[i - 1];
            @sorted_array[i - 1] = sorted_array[i];
            @sorted_array[i] = _blob;
        }
    }

    //for(i = 0; i < non_null_count; i++)
    //{
    //    print("blob_dist[" + i + "] = " + blob_dist[i]);
    //}

    return sorted_array;
}

bool getAndAssignTargets(CPlayer@ player, string[]@ tokens, u8 target_player_slot, bool target_player_blob_param, CPlayer@ &out target_player, CBlob@ &out target_blob)
{
    if(tokens.length <= target_player_slot)
    {
        sendClientMessage(player, "You must specify the player on param " + target_player_slot);
        return false;
    }

    array<CPlayer@> target_players = getPlayersByShortUsername(tokens[target_player_slot]);//Get a list of players that have this as the start of their name
    if(target_players.size() > 1)//If there is more than 1 player in the list
    {
        string playernames = "";
        for(int i = 0; i < target_players.length(); i++)//for every player in that list
        {
            playernames += " : " + target_players[i].getUsername();// put their name in a string
        }
        sendClientMessage(player, "There is more than one possible player" + playernames);//tell the client that these players in the string were found
        return false;//don't send the message to chat, don't do anything else
    }
    else if(target_players == null || target_players.length == 0)
    {
        sendClientMessage(player, "No players were found from " + tokens[target_player_slot]);
        return false;
    }

    
    @target_player = target_players[0];

    if (target_player != null)
    {
        if(target_player_blob_param == true)
        {
            if(target_player.getBlob() == null)
            {
                sendClientMessage(player, "This player does not yet have a blob.");
                return false;
            }
            @target_blob = @target_player.getBlob();
        }
    }
    else
    {
        sendClientMessage(player, "player " + tokens[target_player_slot] + " not found");
        return false;
    }

    return true;
}

bool getBool(string input_string, bool &out bool_value)
{
    input_string = input_string.toLower();
    if(input_string == "true" || input_string == "1")
    {
        bool_value = true;
        return true;
    }
    else if(input_string == "false" || input_string == "0")
    {
        bool_value = false;
        return true;
    }
    bool_value = false;

    return false;
}

bool getCommandByTokens(string[]@ tokens, array<ICommand@> commands, CPlayer@ player, ICommand@ &out command)//Do not use null checks with the variable command. It is always not null for angelscript reasons.
{
    CRules@ rules = getRules();

    int token0Hash = tokens[0].getHash();//Get the hash for the first token (the command name)

    //For every command
    for(u16 p = 0; p < commands.size(); p++)
    {
        commands[p].RefreshVars();//Refersh vars command variables stay even after the command is finished being used. This is called to set them all to default.
        
        commands[p].Setup(tokens);//Setup permissions required to use the command. the permissions can vary based on the tokens.
        
        if(!DebugCommand(commands[p], false))//Confirms that the command isn't missing something. If the bool variable is true, it will print the command's variables.
        {
            error("DebugCommand returned false on command " + p);
            return false;
        }

        array<int> _names = commands[p].getNames();//Gets all the names that this command has.
        
        for(u16 name = 0; name < _names.size(); name++)//Per each name
        {
            if(_names[name] == token0Hash)//If this name is equal to the first token. Both values are hashes
            {   //The desired command is now known
                if(!commands[p].isActive() && !getSecurity().checkAccess_Command(player, "ALL"))//If the command is not active (if the player is a superadmin, they can use the command anyway.)
                {
                    sendClientMessage(player, "This command is not active.");
                    return false;
                }
                //print("token length = " + tokens.size());
                @command = @commands[p];
                return true;
            }
        }
    }

    return true;
}

//Returning false means something happened.
bool DebugCommand(ICommand@ command, bool debug_messages)//if debug_messages is true, stuff will print to console.
{
    string errormessage;

    if(command == null)
    {
        errormessage = "Command was null";
        error(errormessage);
        return false;
    }

    if(debug_messages)
    {
        print("command.isActive() = " + command.isActive() + "\n");

        print("command.inGamemode() = " + command.inGamemode() + "\n");

        array<int> names = command.getNames();

        for(u16 i = 0; i < names.size(); i++)
        {
            if(names[i] != 0)
            {
                print("command.getNames()[" + i + "] = " + names[i] + "\n");
            }
        }
        
        print("command.getPermLevel() = " + command.getPermLevel() + "\n");

        print("command.getCommandType() = " + command.getCommandType() + "\n");
        
        print("command.getTargetPlayerSlot() = " + command.getTargetPlayerSlot() + "\n");
        
        print("command.getTargetPlayerBlobParam() = " + command.getTargetPlayerBlobParam() + "\n");

        print("command.getNoSvTest() = " + command.getNoSvTest() + "\n");

        print("command.getBlobMustExist() = " + command.getBlobMustExist() + "\n");

        print("command.getMinimumParameterCount() = " + command.getMinimumParameterCount() + "\n");
    }

    
    if(command.getNames().size() == 0)//If this command does not have a single name.
    {
        string errormessage = "Command did not have a name to go by. Please add a name to this command";
        error(errormessage);
        return false;
    }

    return true;
}


bool IsDigitsOnly(string _string)
{
    for(u32 i = 0; i < _string.size(); i++)
    {
        string str = _string.substr(i, i + 1);
        
        if(str == "0" || str == "1" || str == "2" || str == "3" || str == "4" || str == "5" || str == "6" || str == "7" || str == "8" || str == "9")
        {
            continue;
        }
        else
        {
            return false;
        }
    }

    return true;
 }

/*array<f32> SortVectorArray(array<f32> vectors)
{


    return vectors;
}*/

/*CPlayer@ findNearestPlayer(bool skipclosest, Vec2f point, f32 radius)
{
    u16 find_closest_count = 2;
    array<CBlob@> playerblobs(getPlayerCount());
    array<CPlayer@> closestplayers(find_closest_count);
    
    for(uint i = 0; i < playerblobs.length(); i++)
    {
        CPlayer@ _player = getPlayer(i);
        if(_player != null)
        {
            @playerblobs[i] = @_player.getBlob();
        }
    }

    array<f32> best_dist(closestplayers.length, 99999999);
    for (uint step = 0; step < playerblobs.length; ++step)
    {
        print("step = " + step);
        if(playerblobs[step] == null)
        {
            continue;
        }

        for(u16 i = 0; i < closestplayers.length; i++)
        {
            Vec2f tpos = playerblobs[step].getPosition();
            f32 dist = (tpos - point).getLength();
            if (dist < best_dist[i])
            {
                @closestplayers[i] = @playerblobs[step].getPlayer();
                best_dist[i] = dist;
                break;
            }   
        }
    }

    if(skipclosest)
    {
        return closestplayers[1];
    }
    
    return closestplayers[0];
}*/