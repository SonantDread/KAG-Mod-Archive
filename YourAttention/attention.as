#define CLIENT_ONLY

bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
    CPlayer@ p = getLocalPlayer();
    if (p is null || !p.isMyPlayer() || p is player) { return true; }

    int resultUsername = text_in.findFirst(p.getUsername(),0);
    int resultCharName = text_in.findFirst(p.getCharacterName(),0);
    if( resultUsername != -1 || resultCharName != -1){
        Sound::Play( "bell.ogg" );
    }

    return true;
}