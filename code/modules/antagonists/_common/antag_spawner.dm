/obj/item/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY

	/// Whether or not this contract has been used
	var/used = FALSE
	/// Whether or not we're currently polling ghosts, to prevent spam
	var/currently_polling_ghosts = FALSE

/obj/item/antag_spawner/proc/spawn_antag(client/chosen_client, turf/forced_turf, datum/mind/user)
	return

/obj/item/antag_spawner/proc/equip_antag(mob/target)
	return

///////////WIZARD

/obj/item/antag_spawner/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"

	var/school

/obj/item/antag_spawner/contract/attack_self(mob/user)
	user.set_machine(src)
	var/dat
	if(used)
		dat = "<B>You have already summoned your apprentice.</B><BR>"
	else
		dat = "<B>Contract of Apprenticeship:</B><BR>"
		dat += "<I>Using this contract, you may summon an apprentice to aid you on your mission.</I><BR>"
		dat += "<I>If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook to refund your points.</I><BR>"
		dat += "<B>Which school of magic is your apprentice studying?:</B><BR>"
		dat += "<A href='byond://?src=[REF(src)];school=[APPRENTICE_DESTRUCTION]'>Destruction</A><BR>"
		dat += "<I>Your apprentice is skilled in offensive magic. They know Magic Missile and Fireball.</I><BR><BR>"
		dat += "<A href='byond://?src=[REF(src)];school=[APPRENTICE_BLUESPACE]'>Bluespace Manipulation</A><BR>"
		dat += "<I>Your apprentice is able to defy physics, melting through solid objects. They know Ethereal Jaunt and have a wand of teleportation.</I><BR><BR>"
		dat += "<A href='byond://?src=[REF(src)];school=[APPRENTICE_HEALING]'>Healing</A><BR>"
		dat += "<I>Your apprentice is training to cast spells that will aid your survival. They know Forcewall and Charge and come with a Wand of Healing.</I><BR><BR>"
		dat += "<A href='byond://?src=[REF(src)];school=[APPRENTICE_ROBELESS]'>Robeless</A><BR>"
		dat += "<I>Your apprentice is training to cast spells without their robes. They know Knock and Mindswap.</I><BR><BR>"
		dat += "<A href='byond://?src=[REF(src)];school=[APPRENTICE_WILDMAGIC]'>Wild Magic</A><BR>"
		dat += "<I>Your apprentice is training wild magic. You don't know which spells they got from the wild magic, but it's how the school of wild magic is.</I><BR><BR>"
	user << browse(HTML_SKELETON(dat), "window=radio")
	onclose(user, "radio")
	return

/obj/item/antag_spawner/contract/Topic(href, href_list)
	. = ..()
	if(usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if(!ishuman(usr))
		return TRUE
	var/mob/living/carbon/human/H = usr

	if(loc == H || (in_range(src, H) && isturf(loc)))
		H.set_machine(src)
		if(href_list["school"])
			if(currently_polling_ghosts)
				to_chat(H, "Already requesting support!")
				return
			if(used)
				to_chat(H, "You already used this contract!")
				return

			currently_polling_ghosts = TRUE
			var/datum/poll_config/config = new()
			config.question = "Do you want to play as a wizard's [href_list["school"]] apprentice?"
			config.check_jobban = ROLE_WIZARD
			config.poll_time = 15 SECONDS
			config.ignore_category = POLL_IGNORE_WIZARD_HELPER
			config.jump_target = H
			config.role_name_text = "[href_list["school"]] apprentice"
			config.alert_pic = H
			var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(config)
			currently_polling_ghosts = FALSE

			if(!candidate)
				to_chat(H, "Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later.")
				return

			if(QDELETED(src))
				return
			used = TRUE
			school = href_list["school"]
			spawn_antag(candidate.client, get_turf(src), H.mind)

/obj/item/antag_spawner/contract/spawn_antag(client/chosen_client, turf/forced_turf, datum/mind/user)
	new /obj/effect/particle_effect/smoke(forced_turf)
	var/mob/living/carbon/human/apprentice_body = new(forced_turf)
	chosen_client.prefs.apply_prefs_to(apprentice_body)
	apprentice_body.key = chosen_client.key

	var/datum/antagonist/wizard/apprentice/new_apprentice = new()
	new_apprentice.master = user
	new_apprentice.school = school

	var/datum/antagonist/wizard/master_wizard = user.has_antag_datum(/datum/antagonist/wizard)
	if(master_wizard)
		if(!master_wizard.wiz_team)
			master_wizard.create_wiz_team()
		new_apprentice.wiz_team = master_wizard.wiz_team
		master_wizard.wiz_team.add_member(apprentice_body.mind)
	apprentice_body.mind.add_antag_datum(new_apprentice)

	apprentice_body.mind.assigned_role = "Apprentice"
	apprentice_body.mind.special_role = "apprentice"

	SEND_SOUND(apprentice_body, sound('sound/effects/magic.ogg'))

///////////BORGS AND OPERATIVES

/obj/item/antag_spawner/nuke_ops
	name = "syndicate operative beacon"
	desc = "A single-use beacon designed to quickly launch reinforcement operatives into the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	/// The name of the special role given to the recruit
	var/special_role_name = ROLE_OPERATIVE
	/// The applied outfit
	var/datum/outfit/syndicate/outfit = /datum/outfit/syndicate/no_crystals
	/// The antag datum applied
	var/antag_datum = /datum/antagonist/nukeop
	/// Style used by the droppod
	var/pod_style = STYLE_SYNDICATE
	/// The picture to use for the ghost poll. If null, src is used
	var/poll_alert_pic

/// Creates the drop pod the nukie will be dropped by
/obj/item/antag_spawner/nuke_ops/proc/setup_pod()
	var/obj/structure/closet/supplypod/pod = new(null, pod_style)
	pod.explosionSize = list(0,0,0,0)
	pod.bluespace = TRUE
	return pod

/obj/item/antag_spawner/nuke_ops/proc/check_usability(mob/user)
	if(!user?.mind)
		return FALSE
	if(used)
		to_chat(user, span_warning("[src] is out of power!"))
		return FALSE
	if(!user.mind.has_antag_datum(/datum/antagonist/nukeop, TRUE))
		to_chat(user, span_danger("AUTHENTICATION FAILURE. ACCESS DENIED."))
		return FALSE
	return TRUE

/obj/item/antag_spawner/nuke_ops/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	to_chat(user, span_notice("You activate [src] and wait for confirmation."))

	currently_polling_ghosts = TRUE
	var/datum/poll_config/config = new()
	config.check_jobban = ROLE_OPERATIVE
	config.poll_time = 5 SECONDS //15 SECONDS
	config.jump_target = user
	config.role_name_text = "reinforcement [special_role_name]"
	config.alert_pic = poll_alert_pic || src
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(config)
	currently_polling_ghosts = FALSE

	if(!candidate)
		to_chat(user, span_warning("Unable to connect to Syndicate command. Please wait and try again later or use the beacon on your uplink to get your points refunded."))
		return

	if(QDELETED(src) || !check_usability(user))
		return
	used = TRUE

	spawn_antag(candidate.client, null, user?.mind)
	do_sparks(4, TRUE, src)
	qdel(src)

/obj/item/antag_spawner/nuke_ops/spawn_antag(client/chosen_client, turf/forced_turf, datum/mind/user)
	var/mob/living/carbon/human/nukie_body = new()
	chosen_client.prefs.apply_prefs_to(nukie_body)
	nukie_body.ckey = chosen_client.key

	var/datum/antagonist/nukeop/new_op = new antag_datum()
	new_op.send_to_spawnpoint = FALSE
	new_op.nukeop_outfit = outfit

	var/datum/antagonist/nukeop/creator_op = user?.has_antag_datum(/datum/antagonist/nukeop, TRUE)
	nukie_body.mind.add_antag_datum(new_op, creator_op?.get_team())
	nukie_body.mind.special_role = special_role_name

	var/obj/structure/closet/supplypod/pod = setup_pod()
	nukie_body.forceMove(pod)
	new /obj/effect/pod_landingzone(forced_turf || get_turf(src), pod)

//////CLOWN OP
/obj/item/antag_spawner/nuke_ops/clown
	name = "clown operative beacon"
	desc = "A single-use beacon designed to quickly launch reinforcment clown operatives into the field."
	special_role_name = ROLE_CLOWN_OPERATIVE
	pod_style = STYLE_HONK
	outfit = /datum/outfit/syndicate/clownop/no_crystals
	antag_datum = /datum/antagonist/nukeop/clownop

//////SYNDICATE BORG
/obj/item/antag_spawner/nuke_ops/borg_tele
	name = "syndicate cyborg beacon"
	desc = "A single-use beacon designed to quickly launch reinforcement cyborgs into the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	special_role_name = "Syndicate Cyborg"

	/// The type of borg to spawn
	var/mob/living/silicon/robot/model/syndicate/borg_to_spawn = /mob/living/silicon/robot/model/syndicate

/obj/item/antag_spawner/nuke_ops/borg_tele/assault
	name = "syndicate assault cyborg beacon"
	borg_to_spawn = /mob/living/silicon/robot/model/syndicate
	poll_alert_pic = /mob/living/silicon/robot/model/syndicate
	special_role_name = "Syndicate Assault Cyborg"

/obj/item/antag_spawner/nuke_ops/borg_tele/medical
	name = "syndicate medical beacon"
	borg_to_spawn = /mob/living/silicon/robot/model/syndicate/medical
	poll_alert_pic = /mob/living/silicon/robot/model/syndicate/medical
	special_role_name = "Syndicate Medical Cyborg"

/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	name = "syndicate saboteur beacon"
	borg_to_spawn = /mob/living/silicon/robot/model/syndicate/saboteur
	poll_alert_pic = /mob/living/silicon/robot/model/syndicate/saboteur
	special_role_name = "Syndicate Saboteur Cyborg"

/obj/item/antag_spawner/nuke_ops/borg_tele/spawn_antag(client/chosen_client, turf/forced_turf, datum/mind/user)
	var/datum/antagonist/nukeop/creator_op = user?.has_antag_datum(/datum/antagonist/nukeop, TRUE)
	if(!creator_op)
		return

	var/mob/living/silicon/robot/borg = new borg_to_spawn()
	borg.key = chosen_client.key

	var/brainfirstname = prob(50) ? pick(GLOB.first_names_male) : pick(GLOB.first_names_female)
	var/brainopslastname = creator_op?.nuke_team.syndicate_name || pick(GLOB.last_names)
	var/brainopsname = "[brainfirstname] [brainopslastname]"

	borg.mmi.name = "[initial(borg.mmi.name)]: [brainopsname]"
	borg.mmi.brain.name = "[brainopsname]'s brain"
	borg.mmi.brainmob.real_name = brainopsname
	borg.mmi.brainmob.name = brainopsname
	borg.real_name = borg.name

	var/datum/antagonist/nukeop/new_borg = new()
	new_borg.send_to_spawnpoint = FALSE
	borg.mind.add_antag_datum(new_borg, creator_op.get_team())
	borg.mind.special_role = special_role_name

	var/obj/structure/closet/supplypod/pod = setup_pod()
	borg.forceMove(pod)
	new /obj/effect/pod_landingzone(forced_turf || get_turf(src), pod)

///////////SLAUGHTER DEMON

/obj/item/antag_spawner/slaughter_demon //Warning edgiest item in the game
	name = "vial of blood"
	desc = "A magically infused bottle of blood, distilled from countless murder victims. Used in unholy rituals to attract horrifying creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

	/// The message to show when the bottle is shattered
	var/shatter_msg = span_notice("You shatter the bottle, no turning back now!")
	/// Also the message shown when the bottle is shattered
	var/veil_msg = span_warning("You sense a dark presence lurking just beyond the veil...")
	/// The type of demon to spawn
	var/mob/living/demon_type = /mob/living/simple_animal/hostile/imp/slaughter
	/// The antag datum to apply to the demon
	var/antag_type = /datum/antagonist/slaughter

/obj/item/antag_spawner/slaughter_demon/attack_self(mob/user)
	if(!is_station_level(user.z))
		to_chat(user, span_notice("You should probably wait until you reach the station."))
		return
	if(used)
		return

	currently_polling_ghosts = TRUE
	var/datum/poll_config/config = new()
	config.check_jobban = ROLE_SLAUGHTER_DEMON
	config.poll_time = 10 SECONDS
	config.jump_target = user
	config.role_name_text = initial(demon_type.name)
	config.alert_pic = /mob/living/simple_animal/hostile/imp/slaughter
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(config)
	currently_polling_ghosts = FALSE

	if(!candidate)
		to_chat(user, span_notice("You can't seem to work up the nerve to shatter the bottle. Perhaps you should try again later."))
		return

	if(used || QDELETED(src))
		return
	used = TRUE

	spawn_antag(candidate.client, get_turf(src), user.mind)
	to_chat(user, shatter_msg)
	to_chat(user, veil_msg)
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, TRUE)
	qdel(src)

/obj/item/antag_spawner/slaughter_demon/spawn_antag(client/chosen_client, turf/forced_turf, datum/mind/user)
	var/mob/living/simple_animal/hostile/imp/slaughter/demon = new demon_type(forced_turf)
	new /obj/effect/dummy/phased_mob(forced_turf, demon)
	demon.key = chosen_client.key
	demon.mind.assigned_role = demon.name
	demon.mind.special_role = demon.name
	demon.mind.add_antag_datum(antag_type)
	to_chat(demon, span_bold("You are currently not currently in the same plane of existence as the station. Use your Blood Crawl ability near a pool of blood to manifest and wreak havoc."))

/obj/item/antag_spawner/slaughter_demon/laughter
	name = "vial of tickles"
	desc = "A magically infused bottle of clown love, distilled from countless hugging attacks. Used in funny rituals to attract adorable creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	color = "#FF69B4" // HOT PINK

	veil_msg = span_warning("You sense an adorable presence lurking just beyond the veil...")
	demon_type = /mob/living/simple_animal/hostile/imp/slaughter/laughter
	antag_type = /datum/antagonist/slaughter/laughter
