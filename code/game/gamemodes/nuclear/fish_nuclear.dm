/datum/game_mode/nuclear/fishy
	name = "fishy nuclear emergency"
	config_tag = "fish_nuclear"
	report_type = "fish_nuclear"
	false_report_weight = 10
	required_players = 30 // 30 players - 7 players to be the nuke ops = 23 players remaining
	required_enemies = 4
	recommended_enemies = 8
	antag_flag = ROLE_OPERATIVE //same as normal nuclear ops
	enemy_minimum_age = 14

	announce_span = "danger"
	announce_text = "Syndicate forces are approaching the station in an attempt to destroy it!\n\
	<span class='danger'>Operatives</span>: Secure the nuclear authentication disk and use your nuke to destroy the station.\n\
	<span class='notice'>Crew</span>: Defend the nuclear authentication disk and ensure that it leaves with you on the emergency shuttle."

	title_icon = "nukeops"
	operative_antag_datum_type = /datum/antagonist/nukeop/fishop
	leader_antag_datum_type = /datum/antagonist/nukeop/fishop/leader
	nuke_team = new /datum/team/nuclear/fish()

/datum/game_mode/nuclear/fishy/pre_setup()
	var/n_agents = min(round(num_players() / 5), antag_candidates.len, agents_possible)
	if(n_agents >= required_enemies)
		for(var/i = 0, i < n_agents, ++i)
			var/datum/mind/new_op = pick_n_take(antag_candidates)
			pre_nukeops += new_op
			new_op.assigned_role = "A very fishy Nuclear Operative"
			new_op.special_role = "A very fishy Nuclear Operative"
			log_game("[key_name(new_op)] has been selected as a fishy nuclear operative")
		return TRUE
	else
		setup_error = "Not enough fishy candidates"
		return FALSE

/datum/game_mode/nuclear/fishy/post_setup()
	addtimer(CALLBACK(src, .proc/spawn_stuff), 7 SECONDS)
	return ..()

/datum/game_mode/nuclear/fishy/proc/spawn_stuff()
	var/datum/mind/leader_mind = pre_nukeops[1]
	new /obj/item/nuclear_challenge(leader_mind.current.loc)
	for(var/datum/mind/M as() in pre_nukeops)
		new /obj/item/pinpointer/nuke/syndicate(M.current.loc)

/datum/outfit/fishop
	name = "fish operative outfit"

/datum/outfit/fishop/equip(mob/living/carbon/human/H, visualsOnly)
	var/mob/living/simple_animal/hostile/carp/cayenne/fishy_operator/fish = new(H.loc)
	H.mind.transfer_to(fish)
	if(H.key)
		fish.key = H.key
	qdel(H)

	var/obj/item/implant/radio/R = new(fish)
	R.radio.command = TRUE
	R.radio.set_frequency(FREQ_SYNDICATE)
	R.radio.syndie = TRUE
	R.implant(fish)

	ADD_TRAIT(fish, TRAIT_MEDICAL_HUD, INNATE_TRAIT)
	var/datum/atom_hud/Hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	Hud.add_hud_to(fish)
	var/obj/item/implant/explosive/E = new /obj/item/implant/explosive(fish)
	E.implant(fish)
	var/obj/item/implant/weapons_auth/W = new /obj/item/implant/weapons_auth(fish)
	W.implant(fish)

	fish.access_card = new /obj/item/card/id/syndicate/nuke_leader(fish)

	fish.faction |= ROLE_SYNDICATE
	fish.update_icons()

/datum/outfit/fishop/leader
	name = "leader fish operative outfit"

/datum/game_mode/nuclear/fishy/generate_credit_text()
	var/list/round_credits = list()

	round_credits += "<center><h1>Get fished</h1>"

	round_credits += ..()
	return round_credits

/datum/team/nuclear/fish/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>Fishy Operatives:</span>"

	var/fished = FALSE
	switch(get_result())
		if(NUKE_RESULT_FLUKE)
			parts += "<span class='redtext big'>Humiliating Fish Defeat</span>"
			parts += "<B>The crew of [station_name()] gave fishy operatives back their bomb! The syndicate base was destroyed!</B> Next time, don't lose the nuke!"
		if(NUKE_RESULT_NUKE_WIN)
			parts += "<span class='greentext big'>Syndicate Fish Victory!</span>"
			parts += "<B>fishy operatives have destroyed [station_name()]!</B>"
			fished = TRUE
		if(NUKE_RESULT_NOSURVIVORS)
			parts += "<span class='neutraltext big'>Total Fish Annihilation</span>"
			parts +=  "<B>fishy operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!"
			fished = TRUE
		if(NUKE_RESULT_WRONG_STATION)
			parts += "<span class='redtext big'>Crew Minor Victory</span>"
			parts += "<B>Fish operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't do that!"
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			parts += "<span class='redtext big'>Fish operatives have earned Darwin Award!</span>"
			parts += "<B>Fish operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't do that!"
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			parts += "<span class='redtext big'>Crew Major Victory!</span>"
			parts += "<B>The Research Staff has saved the disk and killed the Fish Operatives</B>"
		if(NUKE_RESULT_CREW_WIN)
			parts += "<span class='redtext big'>Crew Major Victory</span>"
			parts += "<B>The Research Staff has saved the disk and stopped the Fish Operatives!</B>"
		if(NUKE_RESULT_DISK_LOST)
			parts += "<span class='neutraltext big'>Neutral Victory!</span>"
			parts += "<B>The Research Staff failed to secure the authentication disk but did manage to kill most of the Fish Operatives!</B>"
		if(NUKE_RESULT_DISK_STOLEN)
			parts += "<span class='greentext big'>Fish Minor Victory!</span>"
			parts += "<B>Fish operatives survived the assault but did not achieve the destruction of [station_name()].</B> Next time, don't lose the disk!"
			fished = TRUE
		else
			parts += "<span class='neutraltext big'>Neutral Victory</span>"
			parts += "<B>Mission aborted!</B>"

	if(fished)
		parts += "<h1>The crew got fished!</h1>"

	var/text = "<br><span class='header'>The syndicate operatives were:</span>"
	var/purchases = ""
	var/TC_uses = 0
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	for(var/I in members)
		var/datum/mind/syndicate = I
		var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[syndicate.key]
		if(H)
			TC_uses += H.total_spent
			purchases += H.generate_render(show_key = FALSE)
	text += printplayerlist(members)

	parts += text

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
