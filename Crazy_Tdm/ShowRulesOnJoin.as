#define CLIENT_ONLY

const string title = "Discord https://discord.gg/fP6j2EmSbt";
const string rules = "If it does not work add TaztheV1#7451 on discord\n" +
/*
const string rules = 
*/
		  
const Vec2f dimensions(655, 155);

bool show_rules = false;

void onTick(CRules@ this)
{
    CPlayer@ player = getLocalPlayer();
	
	if (player !is null)
        show_rules = player.getBlob() is null;
	else
	    show_rules = false;
}

void onRender(CRules@ this)
{
	if (show_rules)
	{
	    Vec2f tl = Vec2f(getScreenWidth() / 2 - dimensions.x / 2, getScreenHeight() - dimensions.y - 24);
	    Vec2f br = Vec2f(tl.x + dimensions.x, tl.y + dimensions.y);
	    Vec2f text_dim;
		
		GUI::DrawPane(tl, br, SColor(0x80ffffff));
		
	    GUI::GetTextDimensions( title, text_dim );
		GUI::DrawText(title, tl + Vec2f(dimensions.x / 2 - text_dim.x / 2, 5), color_white);
		GUI::DrawText(rules, tl + Vec2f(5, 25), color_white);
	}
}
