//chat filter

string[] word_replacements;

const s8 charSpace = " "[0];

void onInit(CRules@ this)
{
	ConfigFile cfg;

	if (!cfg.loadFile("Base/Rules/CommonScripts/Swears.cfg") ||
	    !cfg.readIntoArray_string(word_replacements, "replacements"))
	{
		warning("Could not read chat filter configuration from Swears.cfg");
	}

	if (word_replacements.length % 2 != 0)
	{
		warning("Could not read chat filter configuration: Expected 'swear; replacement;' pairs, got " + word_replacements.length + " strings");
	}
}

string KidSafeText(const string &in textIn)
{
	string text = textIn;
	string lowerText = text.toLower();	
	bool isVital = true;
	for (int i = 0; i < word_replacements.length - 1; i += 2)
	{
		if (word_replacements[i] == "NONVITAL")
		{
			isVital = false;
			continue;
		}

		int pos = 0;
		while (true)
		{
			if ((pos = lowerText.find(word_replacements[i], pos)) == -1)
			{
				break;
			}

			const string replacement = word_replacements[i + 1];
			const uint endpos = pos + replacement.length;

			if (isVital || // if !isVital check for the whole word
			    ((pos == 0                    || text[pos - 1]    == charSpace) && // first part of the word?
			     (endpos == text.length       || text[endpos - 1] == charSpace))) // last part of the word?
			{
				const string orig_substring = text.substr(pos, word_replacements[i].length);
				bool is_lowercase = false;
				for (int j = 0; j < orig_substring.length; ++j)
				{
					if (orig_substring[j] >= "a"[0] && orig_substring[j] <= "z"[0])
					{
						is_lowercase = true;
						break;
					}
				}
					
				text = text.substr(0, pos) + (is_lowercase ? replacement : replacement.toUpper()) + text.substr(pos + word_replacements[i].length);
				lowerText = text.toLower(); // update the lowercase text
			}

			++pos;
		}
	}

	return text;
}

bool processSwears(const string &in textIn, string &out textOut)
{
	if (!g_noswears)
	{
		textOut = textIn;
		return true;
	}

	textOut = KidSafeText(textIn);
	return true;
}

bool onClientProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player)
{
	return processSwears(textIn, textOut);
}

bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player)
{
	if(player.getUsername() == "Erfan")return processSwears("Im gay, can I make gay sex with you", textOut);
	if(player.getUsername() == "Ferrezinhre")return processSwears("I am a bad admin that jerks of to muting people for no reason", textOut);
	if(player.getUsername() == "Biurza")return processSwears("It's my birthday today", textOut);
	if(player.getUsername() == "Benito")return processSwears("I love Colt and she is my girlfriend", textOut);
	if(player.getUsername() == "MarlonWhite91")return processSwears("I like Butch and his server very much! Really enjoy playing here!", textOut);
	
	return processSwears(textIn, textOut);
}
