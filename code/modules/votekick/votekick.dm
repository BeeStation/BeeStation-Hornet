/client/verb/votekick(client/C as null|anything in GLOB.clients)
	set name = "Vote Kick"
	set category = "Admin"
	if(C)
		del(C)