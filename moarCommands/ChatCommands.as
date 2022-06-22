//
// moarCommands main file
// You should not include this file in a script, else you may encounter script errors, such as function conflict.
// To install the mod, you simply need to add 'moarCommands' in a new line in Mods.cfg
// Then, you need to add 'mc.as' in the script part of your gamemode.cfg
//
// This mC build was designed for build : 1387
//

#include "mc_commandutil.as"
string[] std_scripts = {"mc_pl_std_mc.as",
						"mc_pl_std_apidemo.as",
						"mc_pl_std_doc.as",
						"mc_pl_std_legacy.as",
						"mc_pl_std_spawn.as",
						"mc_pl_std_various.as",
						"mc_pl_me_base.as"};

namespace mc
{
	void setupCommonCommands(CRules@ this)
	{
		this.addCommandID("mc_strsend");
		this.addCommandID("mc_cmdsend");
	}

	void setupLoadSTD(CRules@ this)
	{
		for(uint i = 0; i < std_scripts.size(); i++)
		{
			this.AddScript(std_scripts[i]);
		}
	}

	void setupUnloadSTD(CRules@ this)
	{
		for(uint i = 0; i < std_scripts.size(); i++)
		{
			this.RemoveScript(std_scripts[i]);
		}
	}
}

void onInit(CRules@ this)
{
	warn("moarCommands is initializing...");

	print("Initializing common commands");
	mc::setupCommonCommands(this);
	
	print("Loading handlers");
	
	if (getNet().isServer())
	{
		// We're removing the script first so we don't get a script running twice (not sure if done automatically)
		getRules().RemoveScript("mc_handler_sv.as");
		getRules().AddScript("mc_handler_sv.as");
	}
	
	// This is required for localhost parties, where the player can be the server and the client at the same time.
	// Else we'd get odd issues, such as sending messages but never receiving them.
	if (getNet().isClient())
	{
		getRules().RemoveScript("mc_handler_cl.as");
		getRules().AddScript("mc_handler_cl.as");
	}

	print("Initializing mC's STD");
	mc::setupLoadSTD(this);
	
	warn("moarCommands initialized.");
}