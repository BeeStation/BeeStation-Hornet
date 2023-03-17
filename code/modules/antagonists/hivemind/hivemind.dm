/datum/antagonist/hivemind
	name = "Hivemind Host"
	roundend_category = "hiveminds"
	antagpanel_category = "Hivemind Host"
	job_rank = ROLE_HIVE
	antag_moodlet = /datum/mood_event/hivehost
	var/special_role = ROLE_HIVE
	var/list/hivemembers = list()
	var/list/avessels = list()
	var/hive_size = 0
	var/size_mod = 0 // Bonus size for using integrate
	var/unlocked_dominance = FALSE
	var/dominant = FALSE
	var/mutable_appearance/glow
	var/isintegrating = 0
	var/hiveID = "Hivemind"
	var/searchcharge = 0
	var/datum/psychic_plane/psychic_plane
	var/datum/action/innate/psychic_plane/plane_action
	var/avessel_limit = 2
	var/descriptor = "Hivemind"
	var/hud_entry_num

	var/list/upgrade_tiers = list(
		//Tier 1 - Roundstart powers
		/obj/effect/proc_holder/spell/targeted/hive_add = 0,
		/obj/effect/proc_holder/spell/target_hive/hive_see = 0,
		/obj/effect/proc_holder/spell/target_hive/hive_shock = 0,
		//Tier 2 - Host vs Host
		/obj/effect/proc_holder/spell/targeted/hive_integrate = 5,
		/obj/effect/proc_holder/spell/targeted/hive_hack = 5,
		/obj/effect/proc_holder/spell/targeted/hive_probe = 5,
		//Tier 3 - Crew manipulation powers
		/obj/effect/proc_holder/spell/target_hive/hive_compell = 10,
		/obj/effect/proc_holder/spell/self/hive_loyal = 10,
		/obj/effect/proc_holder/spell/targeted/hive_thrall = 10,
		//Tier 4 - Combat powers
		/obj/effect/proc_holder/spell/self/hive_drain = 15,
		/obj/effect/proc_holder/spell/targeted/forcewall/hive = 15,
		/obj/effect/proc_holder/spell/targeted/induce_panic = 15,
		//Tier 5 - Finishers
		/obj/effect/proc_holder/spell/target_hive/hive_shatter = 20,
		/obj/effect/proc_holder/spell/targeted/hive_rally = 20,
	)


/datum/antagonist/hivemind/proc/calc_size()
	listclearnulls(hivemembers)
	var/temp = 0
	for(var/datum/mind/M in hivemembers)
		if(M.current && M.current.stat != DEAD)
			temp++
	if(hive_size != temp)
		hive_size = temp
		check_powers()

/datum/antagonist/hivemind/proc/get_carbon_members()
	var/list/carbon_members = list()
	for(var/datum/mind/M in hivemembers)
		if(!M.current || !iscarbon(M.current))
			continue
		carbon_members += M.current
	return carbon_members

/datum/antagonist/hivemind/proc/check_powers()
	for(var/power in upgrade_tiers)
		var/level = upgrade_tiers[power]
		if(hive_size+size_mod >= level && !(locate(power) in owner.spell_list))
			var/obj/effect/proc_holder/spell/the_spell = new power(null)
			owner.AddSpell(the_spell)
			if(hive_size > 0)
				to_chat(owner, "<span class='assimilator'>We have unlocked [the_spell.name].</span><span class='bold'> [the_spell.desc]</span>")
	if(!unlocked_dominance && hive_size >= 20)
		var/lead = TRUE
		for(var/datum/antagonist/hivemind/enemy in GLOB.hivehosts)
			if(enemy == src)
				continue
			if(!enemy.unlocked_dominance && enemy.hive_size <= hive_size + size_mod - 15)
				continue
			if(enemy.size_mod <= size_mod)
				continue
			lead = FALSE
			break
		if(lead)
			unlocked_dominance = TRUE
			owner.AddSpell(new /obj/effect/proc_holder/spell/self/hive_dominance)
			to_chat(owner, "<span class='assimilator'>Our strength overflowing and our competitors left in the dust, we can proclaim our Dominance and enter a heightened state.</span>")

/datum/antagonist/hivemind/proc/add_to_hive(mob/living/carbon/C)
	if(!C)
		return
	var/datum/mind/M = C.mind
	if(M)
		hivemembers |= M
		RegisterSignal(M, COMSIG_PARENT_QDELETING, PROC_REF(handle_mind_deletion))
		add_hive_overlay(C)
		calc_size()

	var/user_warning = "<span class='userdanger'>We have detected an enemy hivemind using our physical form as a vessel and have begun ejecting their mind! They will be alerted of our disappearance once we succeed!</span>"
	if(IS_HIVEHOST(C))
		var/eject_time = rand(1400,1600) //2.5 minutes +- 10 seconds
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), C, user_warning), rand(500,1300)) // If the host has assimilated an enemy hive host, alert the enemy before booting them from the hive after a short while
		addtimer(CALLBACK(src, PROC_REF(handle_ejection), C), eject_time)

/datum/antagonist/hivemind/proc/handle_mind_deletion(datum/mind/M)
	SIGNAL_HANDLER
	remove_from_hive(M.current)

/datum/antagonist/hivemind/proc/is_carbon_member(mob/living/carbon/C)
	if(!hivemembers || !C || !iscarbon(C))
		return FALSE
	var/datum/mind/M = C.mind
	if(!M || !hivemembers.Find(M))
		return FALSE
	return TRUE

/datum/antagonist/hivemind/proc/remove_from_hive(mob/living/carbon/C)
	SIGNAL_HANDLER
	var/datum/mind/M = C.mind
	if(M)
		remove_hive_overlay(C)
		hivemembers -= M
		calc_size()

/datum/antagonist/hivemind/proc/handle_ejection(mob/living/carbon/C) //C is the one being ejected from C2s hive
	if(!C || !owner)
		return
	var/mob/living/carbon/C2 = owner.current
	if(!C2)
		return
	if(IS_HIVEHOST(C) && IS_HIVEHOST(C2))
		remove_from_hive(C)
		to_chat(C2, "<span class='assimilator'>We detect a surge of psionic energy from a far away vessel before they disappear from the hive. Whatever happened, there's a good chance they're after us now.</span>")
		to_chat(C, "<span class='warning'>The enemy host has been ejected from our mind.</span>" )

/datum/antagonist/hivemind/proc/handle_implant()
	var/mob/living/carbon/human/self = owner.current
	if(HAS_TRAIT(self, TRAIT_MINDSHIELD))
		for(var/obj/item/implant/mindshield/M in self.implants)
			to_chat(self, "<span class='notice'>Our latent psychic power destroys our mindshield implant!</span>")
			qdel(M)

/datum/antagonist/hivemind/proc/destroy_hive()
	hivemembers = list()
	for(var/datum/mind/mind in avessels)
		mind.remove_antag_datum(/datum/antagonist/hivevessel)
	avessels = list()
	calc_size()
	for(var/power in upgrade_tiers)
		if(!upgrade_tiers[power])
			continue
		owner.RemoveSpell(power)

/datum/antagonist/hivemind/antag_panel_data()
	return "Vessels Assimilated: [hive_size] (+[size_mod])"


/datum/antagonist/hivemind/on_gain()
	owner.special_role = special_role
	GLOB.hivehosts += src
	generate_flavour()
	create_actions()
	check_powers()
	forge_objectives()
	..()

/datum/antagonist/hivemind/apply_innate_effects()
	handle_clown_mutation(owner.current, "The great psionic powers of the Hive lets you overcome your clownish nature, allowing you to wield weapons with impunity.")
	update_hivemind_hud(owner.current)

/datum/antagonist/hivemind/proc/update_hivemind_hud(mob/living/M)
	var/datum/atom_hud/antag/hivehud = GLOB.huds[hud_entry_num]
	if(!hivehud)
		hivehud = new/datum/atom_hud/antag()
		hud_entry_num = GLOB.huds.len+1 // this is the index the hivemind hud will be added at
		GLOB.huds += hivehud
	hivehud.join_hud(M)
	if(IS_HIVEHOST(M))
		set_antag_hud(M,"hivemind")
	else
		set_antag_hud(M,"hivevessel")

/datum/antagonist/hivemind/proc/update_hivemind_hud_removed(mob/living/M)
	var/datum/atom_hud/antag/hivehud = GLOB.huds[hud_entry_num]
	if(hivehud)
		hivehud.leave_hud(M)
		set_antag_hud(M, null)

/datum/antagonist/hivemind/remove_innate_effects()
	handle_clown_mutation(owner.current, removing=FALSE)
	update_hivemind_hud_removed(owner.current)

/datum/antagonist/hivemind/on_removal()
	//Remove all hive powers here
	GLOB.hivehosts -= src
	for(var/power in upgrade_tiers)
		owner.RemoveSpell(power)

	if(!silent && owner.current)
		to_chat(owner.current,"<span class='userdanger'> Your psionic powers fade, you are no longer the hivemind's host! </span>")
	owner.special_role = null
	..()

/datum/antagonist/hivemind/proc/forge_objectives()
	if(prob(50))  //One hive size objective
		var/datum/objective/hivemind/hivesize/size_objective = new
		size_objective.owner = owner
		objectives += size_objective
		log_objective(owner, size_objective.explanation_text)
	else if(prob(70))
		var/datum/objective/hivemind/hiveescape/hive_escape_objective = new
		hive_escape_objective.owner = owner
		objectives += hive_escape_objective
		log_objective(owner, hive_escape_objective.explanation_text)
	else
		var/datum/objective/hivemind/biggest/biggest_objective = new
		biggest_objective.owner = owner
		objectives += biggest_objective
		log_objective(owner, biggest_objective.explanation_text)

	if(prob(40)) //One medium difficulty objective
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = owner
		steal_objective.find_target()
		objectives += steal_objective
		log_objective(owner, steal_objective.explanation_text)
	else
		var/datum/objective/hivemind/awaken/awaken_objective = new
		awaken_objective.owner = owner
		awaken_objective.find_target(null,GLOB.hivehosts)
		objectives += awaken_objective
		log_objective(owner, awaken_objective.explanation_text)

	if(prob(30))
		var/datum/objective/hivemind/dominance/assert_dominance = new
		assert_dominance.owner = owner
		objectives += assert_dominance
		log_objective(owner, assert_dominance.explanation_text)
	else if(prob(50))
		var/datum/objective/hivemind/integrate/integrate_objective = new
		integrate_objective.owner = owner
		objectives += integrate_objective
		log_objective(owner, integrate_objective.explanation_text)

	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	objectives += escape_objective
	log_objective(owner, escape_objective.explanation_text)

	return

/datum/antagonist/hivemind/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are the host of a powerful Hivemind.</font></B>")
	to_chat(owner.current, "<b>Your psionic powers will grow by assimilating the crew into your hive. Use the Assimilate Vessel spell on a stationary \
		target, and after ten seconds he will be one of the hive. This is completely silent and safe to use, and failing will reset the cooldown. As \
		you assimilate the crew, you will gain more powers to use. Most are silent and won't help you in a fight, but grant you great power over your \
		vessels. Hover your mouse over a power's action icon for an extended description on what it does. There are other hiveminds onboard the station, \
		collaboration is possible, but a strong enough hivemind can reap many rewards from a well planned betrayal.</b>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/assimilation.ogg', 100, FALSE, pressure_affected = FALSE)

	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Hivemind",
		"Your psionic powers will grow by assimilating the crew into your hive. Use the Assimilate Vessel spell on a stationary \
		target, and after ten seconds he will be one of the hive. This is completely silent and safe to use, and failing will reset the cooldown. As \
		you assimilate the crew, you will gain more powers to use. Most are silent and won't help you in a fight, but grant you great power over your \
		vessels. Hover your mouse over a power's action icon for an extended description on what it does. There are other hiveminds onboard the station, \
		our powers will grow if we integrate them with our own consciousness.")
	to_chat(owner.current,"<span class='assimilator'>We are hive [hiveID]!</span>")

/datum/antagonist/hivemind/roundend_report()
	var/list/result = list()
	result += "<span class='header'>Hive [hiveID]:</span>"
	var/greentext = TRUE
	if(objectives)
		result += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				greentext = FALSE
				break

	if(objectives.len == 0 || greentext)
		result += "<span class='greentext big'>The [name] was successful!</span>"
	else
		result += "<span class='redtext big'>The [name] has failed!</span>"
	result += "The Hivemind Host was:"
	result += printplayer(owner)
	result += "The Awakened Vessels were:"
	for(var/datum/mind/mind in avessels)
		result += printplayer(mind)
	return result.Join("<br>")

/datum/antagonist/hivemind/is_gamemode_hero()
	return SSticker.mode.name == "Assimilation"

/datum/antagonist/hivemind/proc/generate_flavour()
	var/static/list/prefix = list("Azure","Crimson","Silver","Verdant","Ivory","Sepia","Gold","Canary","Rust","Cider","Scarlet","Rose","Magenta","Navy","Lapis","Emerald")
	var/static/list/postfix = list("Flame","Presence","Maw","Revelation","Consciousness","Blanket","Structure","Command","Hierarchy","Aristocrat","Zealotry","Fascination")
	hiveID = pick_n_take(prefix) + " " + pick_n_take(postfix)
	var/static/list/types = list(
		"Domineering and opressive, not a pawn out of place, not a step out of line and ruthless with the oposition.",
		"Crashing waves of assimilation, no subtlety, just the primal instinct to expand.",
		"In one hand, the olive branch in the other; a knife.",
		"Opulent and Aristocratic with ambitions to expand their fiefdom.",
		"Seething with Rage and teeming with Anger, the former dominant personality amongst all, returning for its throne.",
		"A Trickster with a preference for chaos, unpredictable, the emboddiment of mischief.",
		"Benevolent to their own eyes, seeks to free living beings of the burden of free will.",
		"Caring for their vessels and ruthless against those that would attack them, seeks to expand their protective embrace.",
		"Diplomatic and calm mannered, may seek alliances of convenience to further their own gain.",
		"Vulture-like and opportunistic, eager to pounce in a moment of weakness.",
		"Pawns are mere Pawns, and they are expendable, crush our foes in a wave of meat."
		)
	descriptor = pick_n_take(types)

/datum/antagonist/hivemind/proc/create_actions()
	psychic_plane = new(src)
	plane_action = new(psychic_plane)
	plane_action.Grant(owner.current)

/datum/antagonist/hivemind/Destroy()
	GLOB.hivehosts -= src
	destroy_hive()
	QDEL_NULL(psychic_plane)
	QDEL_NULL(plane_action)
	return ..()

/datum/antagonist/hivemind/proc/dominance()
	dominant = TRUE
	if(!owner?.current)
		return
	var/mob/living/carbon/C = owner.current
	if(!C)
		return
	to_chat(C, "<span class='assimilator'>With our psyche unleashed we will be able to sustain an unlimited ammount of awakened vessels!</span>")
	ADD_TRAIT(C, TRAIT_STUNIMMUNE, HIVEMIND_TRAIT)
	ADD_TRAIT(C, TRAIT_SLEEPIMMUNE, HIVEMIND_TRAIT)
	ADD_TRAIT(C, TRAIT_VIRUSIMMUNE, HIVEMIND_TRAIT)
	ADD_TRAIT(C, TRAIT_NOLIMBDISABLE, HIVEMIND_TRAIT)
	ADD_TRAIT(C, TRAIT_NOHUNGER, HIVEMIND_TRAIT)
	ADD_TRAIT(C, TRAIT_NODISMEMBER, HIVEMIND_TRAIT)
	ADD_TRAIT(C, TRAIT_NOSOFTCRIT, HIVEMIND_TRAIT)
	ADD_TRAIT(C, TRAIT_NOHARDCRIT, HIVEMIND_TRAIT)
