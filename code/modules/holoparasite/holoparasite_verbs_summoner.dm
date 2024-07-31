/mob/living/proc/update_holoparasite_verbs()
	remove_verb(list(
		/mob/living/proc/holoparasite_recall,
		/mob/living/proc/holoparasite_reset,
		/mob/living/proc/holoparasite_communicate,
		/mob/living/proc/holoparasite_set_notes,
		/mob/living/proc/holoparasite_lock
	))
	if(has_holoparasites())
		add_verb(list(
			/mob/living/proc/holoparasite_recall,
			/mob/living/proc/holoparasite_reset,
			/mob/living/proc/holoparasite_communicate,
			/mob/living/proc/holoparasite_set_notes,
			/mob/living/proc/holoparasite_lock
		))

/mob/living/simple_animal/hostile/holoparasite/update_holoparasite_verbs()
	return

/mob/living/proc/holoparasite_recall()
	set name = "Recall Holoparasite"
	set category = "Holoparasite"
	set desc = "Forcibly recall your holoparasite."

	for(var/mob/living/simple_animal/hostile/holoparasite/holopara as() in holoparasites())
		to_chat(holopara, "<span class='danger holoparasite'>Your summoner has forcefully recalled you!</span>")
		holopara.balloon_alert(holopara, "force recalled", show_in_chat = FALSE)
		holopara.recall(forced = TRUE)

/**
 * Allows the player to reset their holoparasites
 */
/mob/living/proc/holoparasite_reset()
	set name = "Reset Holoparasite Player"
	set category = "Holoparasite"
	set desc = "Re-rolls which ghost will control your holoparasite."

	var/list/holoparas = holoparasites()
	if(!holoparas)
		to_chat(src, "<span class='warning'>Somehow, you have no holoparasites to reset. This is probably a bug.</span>")
		update_holoparasite_verbs()
		return
	var/mob/living/simple_animal/hostile/holoparasite/holopara = tgui_input_list(src, "Which holoparasite would you like to reset?", "Holoparasite Reset", holoparas)
	if(!holopara)
		return
	if(holopara.being_reset)
		to_chat(src, "<span class='holoparasite bold'>You are already attempting to reset [holopara.color_name]! Wait a bit!</span>")
		return
	var/check_cooldown = !holopara.eligible_for_reset()
	if(!COOLDOWN_FINISHED(holopara, reset_cooldown) && check_cooldown)
		to_chat(src, "<span class='holoparasite bold'>You must wait [COOLDOWN_TIMELEFT_TEXT(holopara, reset_cooldown)] before attempting to reset [holopara.color_name] again.</span>")
		return
	if(tgui_alert(src, "Are you sure you want to reset [holopara.real_name]? This will re-roll the player controlling them!", "Confirm Holoparasite Reset", list("Yes", "No")) != "Yes")
		return
	to_chat(src, "<span class='holoparasite bold'>Attempting to reset [holopara.color_name]...</span>")
	holopara.reset(cooldown = check_cooldown)

/mob/living/proc/holoparasite_communicate()
	set name = "Communicate"
	set category = "Holoparasite"
	set desc = "Communicate telepathically with your holoparasites."

	var/message = tgui_input_text(src, "What do you want to say to your holoparasites?", "Holoparasite Telepathy")
	if(!message)
		return
	// Trimming, chat filters, treating, etc is handled by the telepathy proc.
	// Note: tgui_input_text sanitizes for us, so we pass sanitize = FALSE
	holoparasite_telepathy(message, sanitize = FALSE)

/mob/living/proc/holoparasite_set_notes()
	set name = "Set Holoparasite Notes"
	set category = "Holoparasite"
	set desc = "Set the notes for your holoparasites."

	var/list/holoparas = holoparasites()
	var/holopara_amt = length(holoparas)
	if(!holopara_amt)
		return
	var/target_holopara = holopara_amt > 1 ? tgui_input_list(src, "Which holoparasite would you like to set notes for?", "Holoparasite Notes", holoparas + "(All)") : holoparas[1]
	if(!target_holopara)
		return
	var/list/holoparas_to_set = target_holopara == "(All)" ? holoparas : list(target_holopara)
	if(!length(holoparas_to_set))
		return
	var/new_notes = tgui_input_text(src, "What notes do you write for your holoparasites?", "Holoparasite Notes", max_length = MAX_PAPER_LENGTH, multiline = TRUE, encode = FALSE)
	if(!new_notes)
		return
	if(OOC_FILTER_CHECK(new_notes))
		to_chat(src, "<span class='warning'>The provided notes contain forbidden words.</span>")
		return
	for(var/mob/living/simple_animal/hostile/holoparasite/holopara as() in holoparas_to_set)
		to_chat(holopara, EXAMINE_BLOCK("<span class='holoparasite'><span class='big bold'>Your summoner has changed your notes:</span><br>[sanitize(new_notes)]</span>"))
		holopara.notes = new_notes

/mob/living/proc/holoparasite_lock()
	set name = "Toggle Holoparasite Lock"
	set category = "Holoparasite"
	set desc = "Toggle whether your holoparasites are allowed to manifest or not."

	var/datum/holoparasite_holder/holder = mind?.holoparasite_holder()
	if(!holder)
		return
	holder.locked = !holder.locked
	var/t_s = length(holder.holoparasites) > 1 ? "s" : ""
	if(holder.locked)
		to_chat(src, "<span class='notice holoparasite'>You <b>lock</b> your holoparasite[t_s], preventing them from manifesting.</span>")
		balloon_alert(src, "locked holoparasite[t_s]", show_in_chat = FALSE)
		for(var/mob/living/simple_animal/hostile/holoparasite/holopara as() in holder.holoparasites)
			to_chat(holopara, "<span class='warning holoparasite'>Your summoner has <b>locked</b> you, preventing you from manifesting!</span>")
			holopara.recall(forced = TRUE)
			holopara.balloon_alert(holopara, "locked", show_in_chat = FALSE)
	else
		to_chat(src, "<span class='notice holoparasite'>You <b>unlock</b> your holoparasite[t_s], allowing them to freely manifest once more.</span>")
		balloon_alert(src, "unlocked holoparasite[t_s]", show_in_chat = FALSE)
		for(var/mob/living/simple_animal/hostile/holoparasite/holopara as() in holder.holoparasites)
			to_chat(holopara, "<span class='notice holoparasite'>Your summoner has <b>unlocked</b> you, allowing you to manifest freely again.</span>")
			holopara.balloon_alert(holopara, "unlocked", show_in_chat = FALSE)
			if(holopara.hud_used)
				var/atom/movable/screen/holoparasite/manifest_recall/mr_hud = locate() in holopara.hud_used.static_inventory
				mr_hud?.update_appearance()
