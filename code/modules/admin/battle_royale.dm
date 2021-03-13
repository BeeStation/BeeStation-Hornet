GLOBAL_DATUM(battle_royale, /datum/battle_royale_controller)

#define BATTLE_ROYALE_AVERBS list(\
	/client/proc/battle_royale_speed,\
	/client/proc/battle_royale_varedit,\
	/client/proc/battle_royale_spawn_loot,\
	/client/proc/battle_royale_spawn_loot_good\
)

/client/proc/battle_royale()
	set name = "Battle Royale"
	set category = "Fun"
	if(!check_rights(R_FUN))
		to_chat(src, "<span class='warning'>You do not have permission to do that!</span>")
		return
	if(GLOB.battle_royale)
		to_chat(src, "<span class='warning'>A game is already in progress!</span>")
		return
	if(alert(src, "ARE YOU SURE YOU ARE SURE YOU WANT TO START BATTLE ROYALE?",,"Yes","No") != "Yes")
		to_chat(src, "<span class='notice'>oh.. ok then.. I see how it is.. :(</span>")
		return
	log_admin("[key_name(usr)] HAS TRIGGERED BATTLE ROYALE")
	message_admins("[key_name(usr)] HAS TRIGGERED BATTLE ROYALE")
	GLOB.battle_royale = new()
	INVOKE_ASYNC(GLOB.battle_royale, /datum/battle_royale_controller.proc/start)

/client/proc/battle_royale_speed()
	set name = "Battle Royale - Change wall speed"
	set category = "Event"
	if(!check_rights(R_FUN))
		to_chat(src, "<span class='warning'>You do not have permission to do that!</span>")
		return
	if(!GLOB.battle_royale)
		to_chat(src, "<span class='warning'>No game is in progress.</span>")
		return
	var/new_speed = input(src, "New wall delay (seconds)") as num
	if(new_speed > 0)
		GLOB.battle_royale.field_delay = new_speed
		log_admin("[key_name(usr)] has changed the field delay to [new_speed] seconds")
		message_admins("[key_name(usr)] has changed the field delay to [new_speed] seconds")

/client/proc/battle_royale_varedit()
	set name = "Battle Royale - Variable Edit"
	set category = "Event"
	if(!check_rights(R_FUN))
		to_chat(src, "<span class='warning'>You do not have permission to do that!</span>")
		return
	if(!GLOB.battle_royale)
		to_chat(src, "<span class='warning'>No game is in progress.</span>")
		return
	debug_variables(GLOB.battle_royale)

/client/proc/battle_royale_spawn_loot()
	set name = "Battle Royale - Spawn Loot Drop (Minor)"
	set category = "Event"
	if(!check_rights(R_FUN))
		to_chat(src, "<span class='warning'>You do not have permission to do that!</span>")
		return
	if(!GLOB.battle_royale)
		to_chat(src, "<span class='warning'>No game is in progress.</span>")
		return
	GLOB.battle_royale.generate_good_drop()
	log_admin("[key_name(usr)] generated a battle royale drop.")
	message_admins("[key_name(usr)] generated a battle royale drop.")

/client/proc/battle_royale_spawn_loot_good()
	set name = "Battle Royale - Spawn Loot Drop (Major)"
	set category = "Event"
	if(!check_rights(R_FUN))
		to_chat(src, "<span class='warning'>You do not have permission to do that!</span>")
		return
	if(!GLOB.battle_royale)
		to_chat(src, "<span class='warning'>No game is in progress.</span>")
		return
	GLOB.battle_royale.generate_endgame_drop()
	log_admin("[key_name(usr)] generated a good battle royale drop.")
	message_admins("[key_name(usr)] generated a good battle royale drop.")
