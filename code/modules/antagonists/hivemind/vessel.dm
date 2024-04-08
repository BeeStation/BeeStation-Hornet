

/datum/antagonist/hivevessel
	name = "Awoken Vessel"
	banning_key = ROLE_HIVE_VESSEL
	roundend_category = "awoken vessels"
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	var/hiveID = "Hivemind"
	var/datum/antagonist/hivemind/master
	var/mutable_appearance/glow
	var/obj/effect/proc_holder/spell/targeted/touch/hive_fist/fist = new
	show_in_roundend = FALSE


/mob/living/proc/hive_weak_awaken(directive)
	var/mob/living/user = src
	if(!mind)
		return
	if(!HAS_TRAIT(user, TRAIT_MINDSHIELD))
		to_chat(user, "<span class='assimilator'>Foreign energies force themselves upon your thoughts!</span>")
		flash_color(user, flash_color="#800080", flash_time=10)
		var/objective = brainwash(user, directive, "hivemind compel")
		to_chat(user, "<span class='assimilator'>A figment of your subconscious stays firm, you would be incapable of killing yourself if ordered!</span>")
		user.overlay_fullscreen("hive_mc", /atom/movable/screen/fullscreen/hive_mc)
		addtimer(CALLBACK(user, PROC_REF(hive_weak_clear), objective), 1800, TIMER_STOPPABLE)

/mob/living/proc/hive_weak_clear(objective)
	if(!mind || !objective)
		return
	var/mob/living/user = mind.current
	to_chat(user, "<span class='assimilator'>Our subconscious fights back the invasive forces, our will is once again our own!</span>")
	flash_color(user, flash_color="#800080", flash_time=10)
	user.clear_fullscreen("hive_mc")
	unbrainwash(user, objective)

/datum/antagonist/hivevessel/on_gain()
	owner.special_role = ROLE_HIVE_VESSEL
	owner.AddSpell(fist)
	..()

/datum/antagonist/hivevessel/on_removal()
	remove_innate_effects()
	owner.RemoveSpell(fist)
	if(master)
		to_chat(master.owner, "<span class='assimilator'>A figment of our consciousness snaps out, we have lost an awakened vessel!</span>")
	if(owner?.current && glow)
		owner.current.cut_overlay(glow)
	owner.special_role = null
	master.avessels -= owner
	master = null
	..()

/datum/antagonist/hivevessel/apply_innate_effects()
	handle_clown_mutation(owner.current, "Our newfound powers allow us to overcome our clownish nature, allowing us to wield weapons with impunity.")
	master.update_hivemind_hud(owner.current)

/datum/antagonist/hivevessel/remove_innate_effects()
	handle_clown_mutation(owner.current, removing=FALSE)
	master.update_hivemind_hud_removed(owner.current)

/datum/antagonist/hivevessel/greet()
	to_chat(owner, "<span class='assimilator'>Your mind is suddenly opened, as you see the pinnacle of evolution...</span>")
	to_chat(owner, "<big><span class='warning'><b>Complete the orders of your host, no matter what!</b></span></big>")

/datum/antagonist/hivevessel/farewell()
	to_chat(owner, "<span class='assimilator'>Your mind closes up once more...</span>")
	to_chat(owner, "<big><span class='warning'><b>You feel the weight of your objectives disappear! You no longer have to obey them.</b></span></big>")

