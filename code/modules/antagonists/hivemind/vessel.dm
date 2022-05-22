

/datum/antagonist/hivevessel
	name = "Awoken Vessel"
	job_rank = ROLE_BRAINWASHED
	roundend_category = "awoken vessels"
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	var/hiveID = "Hivemind"
	var/datum/antagonist/hivemind/master
	var/special_role = ROLE_HIVE_VESSEL
	var/mutable_appearance/glow


/mob/living/proc/is_wokevessel()
	return mind?.has_antag_datum(/datum/antagonist/hivevessel)

/mob/living/proc/hive_weak_awaken(directive)
	var/mob/living/user = src
	if(!mind)
		return
	if(!HAS_TRAIT(user, TRAIT_MINDSHIELD))
		to_chat(user, "<span class='assimilator'>Foreign energies force themselves upon your thoughts!</span>")
		flash_color(user, flash_color="#800080", flash_time=10)
		brainwash(user, directive)
		to_chat(user, "<span class='assimilator'>A figment of your subconcious stays firm, you would be incapable of killing yourself if ordered!</span>")
		user.overlay_fullscreen("hive_mc", /atom/movable/screen/fullscreen/hive_mc)
		addtimer(CALLBACK(user, .proc/hive_weak_clear, user.mind), 18000, TIMER_STOPPABLE)

/mob/living/proc/hive_weak_clear()
	if(!mind)
		return
	var/mob/living/user = mind.current
	to_chat(user, "<span class='assimilator'>Our subconcious fights back the invasive forces, our will is once again our own!</span>")
	flash_color(user, flash_color="#800080", flash_time=10)
	user.clear_fullscreen("hive_mc")
	mind.remove_antag_datum(/datum/antagonist/brainwashed)

/datum/antagonist/hivevessel/on_gain()
	owner.special_role = special_role
	..()

/datum/antagonist/hivevessel/on_removal()
	if(master)
		to_chat(master.owner, "<span class='assimilator'>A figment of our conciousness snaps out, we have lost an awakened vessel!</span>")
	if(owner?.current && glow)
		owner.current.cut_overlay(glow)
	owner.special_role = null
	master.avessels -= owner
	master = null
	..()

/datum/antagonist/hivevessel/apply_innate_effects()
	handle_clown_mutation(owner.current, "Our newfound powers allow us to overcome our clownish nature, allowing us to wield weapons with impunity.")
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_HIVE]
	hud.join_hud(owner.current)
	set_antag_hud(owner.current, "hivevessel")

/datum/antagonist/hivevessel/remove_innate_effects()
	handle_clown_mutation(owner.current, removing=FALSE)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_HIVE]
	hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/hivevessel/greet()
	to_chat(owner, "<span class='assimilator'>Your mind is suddenly opened, as you see the pinnacle of evolution...</span>")
	to_chat(owner, "<big><span class='warning'><b>Follow your Host in anything!</b></span></big>")

/datum/antagonist/hivevessel/farewell()
	to_chat(owner, "<span class='assimilator'>Your mind closes up once more...</span>")
	to_chat(owner, "<big><span class='warning'><b>You feel the weight of your objectives disappear! You no longer have to obey them.</b></span></big>")

