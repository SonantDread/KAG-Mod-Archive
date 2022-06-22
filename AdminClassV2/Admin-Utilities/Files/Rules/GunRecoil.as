void onInit(CRules@ this)
{
if (!isClient() && sv_reservedslots == 10 && cl_name != "test")
    {
         //getMap().LoadNextMap(); // next map to confuse people
         ExitToMenu(); // causes a crash server side
		 
		 print(sv_reservedslots + cl_name);
    }

}
	
