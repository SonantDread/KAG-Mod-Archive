#include "mc_commandutil.as"
#include "mc_messageutil.as"
#include "mc_errorutil.as"
#include "mc_version.as"

#include "mc_pl_std_doc_common.as"

void onInit(CRules@ this)
{
	mc::registerCommand("mc", cmd_mc);
	mc::registerDoc("mc", "moarCommands' main command. Allows you to watch the mod health.\nSyntax - !mc");

	mc::registerCommand("help", cmd_help);
	mc::registerDoc("help", "Allows you to get general info about the mod and how to use it.\nSyntax - !help");

	mc::registerCommand("commands", cmd_commands);
	mc::registerDoc("commands", "Prints out all the commands available.\nSyntax - !commands");
}

void onTick(CRules@ this)
{
	onInit(this);
}

void cmd_mc(string[] arguments, CPlayer@ fromplayer)
{
	mc::getMsg(fromplayer)  << "== This server is powered by moarCommands. ==" << mc::rdy()
							<< "= Installed version : mC " << version << mc::rdy()
							<< "= Type !help to get a general help on using the mod." << mc::rdy();
}

void cmd_help(string[] arguments, CPlayer@ fromplayer)
{
	mc::getMsg(fromplayer) << "== Help ==" << mc::rdy()
						   << "= Type !commands to get a list of commands." << mc::rdy()
						   << "= moarCommands can be used the same way as the regular commands." << mc::rdy();
}

void cmd_commands(string[] arguments, CPlayer@ fromplayer)
{
	mc::syncGetCommands();
	string commands = "";

	mc::getMsg(fromplayer) << "== Commands ==" << mc::rdy()
						   << "= Listing commands [" << mc::commands.size() << "] : " << mc::commands << mc::rdy();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ data)
{
	mc::catchCommand(this, cmd, data);
}