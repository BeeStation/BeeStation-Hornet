/datum/mutation/olfaction
	name = "Transcendent Olfaction"
	desc = "Your sense of smell is comparable to that of a canine."
	quality = POSITIVE
	difficulty = 12
	power_path = /datum/action/spell/olfaction
	instability = 30
	energy_coeff = 1

/datum/action/spell/olfaction
	name = "Remember the Scent"
	desc = "Get a scent off of the item you're currently holding to track it. With an empty hand, you'll track the scent you've remembered."
	cooldown_time = 10 SECONDS
	spell_requirements = null
	button_icon_state = "nose"
	mindbound = FALSE
	var/mob/living/carbon/tracking_target
	var/list/mob/living/carbon/possible = list()

/datum/action/spell/olfaction/on_cast(mob/user, atom/target)
	. = ..()
	var/atom/sniffed = user.get_active_held_item()
	if(sniffed)
		var/old_target = tracking_target
		possible = list()
		var/list/prints = GET_ATOM_FINGERPRINTS(sniffed)
		if(prints)
			for(var/mob/living/carbon/potential_target in GLOB.carbon_list)
				if(prints[rustg_hash_string(RUSTG_HASH_MD5, potential_target.dna?.unique_identity)])
					possible |= potential_target
		if(!length(possible))
			to_chat(user, "<span class='warning'>Despite your best efforts, there are no scents to be found on [sniffed]...</span>")
			return
		tracking_target = tgui_input_list(user, "Choose a scent to remember.", "Scent Tracking", sort_names(possible))
		if(!tracking_target)
			if(!old_target)
				to_chat(user,"<span class='warning'>You decide against remembering any scents. Instead, you notice your own nose in your peripheral vision. This goes on to remind you of that one time you started breathing manually and couldn't stop. What an awful day that was.</span>")
				return
			tracking_target = old_target
			on_the_trail(user)
			return
		to_chat(user,"<span class='notice'>You pick up the scent of <span class='name'>[tracking_target]</span>. The hunt begins.</span>")
		on_the_trail(user)
		return

	if(!tracking_target)
		to_chat(user,"<span class='warning'>You're not holding anything to smell, and you haven't smelled anything you can track. You smell your palm instead; it's kinda salty.</span>")
		return

	on_the_trail(user)

/datum/action/spell/olfaction/proc/on_the_trail(mob/living/user)
	if(!tracking_target)
		to_chat(user,"<span class='warning'>You're not tracking a scent, but the game thought you were. Something's gone wrong! Report this as a bug.</span>")
		return
	if(tracking_target == user)
		to_chat(user,"<span class='warning'>You smell out the trail to yourself. Yep, it's you.</span>")
		return
	if(usr.get_virtual_z_level() < tracking_target.get_virtual_z_level())
		to_chat(user,"<span class='warning'>The trail leads... way up above you? Huh. They must be really, really far away.</span>")
		return
	else if(usr.get_virtual_z_level() > tracking_target.get_virtual_z_level())
		to_chat(user,"<span class='warning'>The trail leads... way down below you? Huh. They must be really, really far away.</span>")
		return
	var/direction_text = "[dir2text(get_dir(usr, tracking_target))]"
	if(direction_text)
		to_chat(user,"<span class='notice'>You consider <span class='name'>[tracking_target]</span>'s scent. The trail leads <b>[direction_text].</b></span>")
