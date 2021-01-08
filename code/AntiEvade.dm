//Anti-Evader 1.0
//SPECIAL THANKS TO Kyle Spier-Swenson FOR MAKING MY DREAM A REALITY.
//The code is like, 99% his.

var/list/client/clientcidcheck = list()

/client/New()
	. = ..()
	if (isnull(clientcidcheck[ckey]))
		clientcidcheck[ckey] = computer_id
		src << link("byond://[world.internet_address]:[world.port]")
	else
		if (clientcidcheck[ckey] != computer_id)
			to_chat(src, "Please remove wsock32.dll from c:/program files/byond/bin and reconnect.")
			message_admins("[clientcidcheck[ckey]] may be using Evasion Tools")
			log_game("[clientcidcheck[ckey]] may be using Evasion Tools")
			del(src)
		else
			clientcidcheck[ckey] = null //reset so if they connect from another laptop or something later on, they don't get this message.
