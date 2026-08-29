/**
 * Cortical borers
 *
 * A borer is a normal simple animal while loose.  When it infests a human it
 * lives inside a borer cyst organ.  The organ is deliberately zone-aware:
 * Bee's bodypart code already moves organs into a severed limb and inserts
 * them again when that limb is reattached, so no bespoke dismemberment hooks
 * are necessary.
 */

/datum/antagonist/borer
	name = "Cortical Borer"
	roundend_category = "cortical borers"
	antagpanel_category = "Cortical Borer"
	show_to_ghosts = TRUE
	banning_key = ROLE_BORER
	required_living_playtime = 4
	give_objectives = FALSE
	leave_behaviour = ANTAGONIST_LEAVE_KEEP

/datum/antagonist/borer/greet()
	owner?.show_memory(owner.current)
	to_chat(owner.current, span_boldnotice("You are a cortical borer. Infest humans, grow within a host, and survive."))

/obj/item/organ/borer_cyst
	name = "cortical cyst"
	desc = "A fibrous cyst threaded through the surrounding tissue."
	icon_state = "appendix"
	organ_flags = ORGAN_ORGANIC
	/// The borer hidden within this cyst.
	var/mob/living/simple_animal/borer/borer

/obj/item/organ/borer_cyst/proc/configure(mob/living/simple_animal/borer/new_borer, new_zone)
	borer = new_borer
	zone = check_zone(new_zone)
	// Organ slots must be unique.  Making the slot from the selected zone keeps
	// this a single organ type while allowing one borer in each normal bodypart.
	slot = "borer_cyst_[zone]"

/obj/item/organ/borer_cyst/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	borer?.bind_to_host(organ_owner, src)

/obj/item/organ/borer_cyst/on_remove(mob/living/carbon/organ_owner, special)
	if(!special)
		// Surgical removal is a successful extraction, not a borer death.
		borer?.detach(get_turf(organ_owner))
	. = ..()

/obj/item/organ/borer_cyst/transfer_to_limb(obj/item/bodypart/limb, mob/living/carbon/carbon_owner)
	. = ..()
	borer?.on_limb_severed(limb)

/mob/living/carbon/human/proc/get_cortical_borers()
	var/list/borers = list()
	for(var/obj/item/organ/borer_cyst/cyst as anything in internal_organs)
		if(cyst.borer)
			borers += cyst.borer
	return borers

/mob/living/carbon/human/proc/get_cortical_borer(zone)
	zone = check_zone(zone)
	for(var/obj/item/organ/borer_cyst/cyst as anything in internal_organs)
		if(cyst.zone == zone)
			return cyst.borer

/mob/living/simple_animal/borer
	name = "cortical borer"
	real_name = "cortical borer"
	desc = "A small, unsettling parasite with far too many legs."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	gender = NEUTER
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	health = 20
	maxHealth = 20
	melee_damage = 0
	obj_damage = 0
	response_help_continuous = "pets"
	response_disarm_continuous = "brushes against"
	response_harm_continuous = "swats"
	speak_emote = list("clicks")
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	/// The human currently hosting us. Null while loose or in a severed limb.
	var/mob/living/carbon/human/host
	/// The physical anchor which carries us through surgery and limb transfer.
	var/obj/item/organ/borer_cyst/cyst
	/// The limb currently carrying us after it has been severed.
	var/obj/item/bodypart/severed_limb
	/// Chemical reserve. Evolution abilities will spend this rather than host reagents.
	var/chemicals = 0
	var/max_chemicals = 100
	/// Progress is deliberately independent of chemicals; it is awarded only while hosted.
	var/evolution_points = 0
	var/next_evolution_point = 0
	var/chemical_regen_bonus = 0
	/// Secretion definitions available to this borer. Availability depends on
	/// the cyst location and any learned chemical evolutions.
	var/list/datum/borer_secretion/available_secretions = list()
	var/list/datum/borer_evolution/available_evolutions = list()
	var/datum/borer_evolution_menu/evolution_menu
	var/datum/action/innate/borer_evolution/evolution_action
	/// True only while this borer's player is operating its host's body.
	var/controlling_host = FALSE

/mob/living/simple_animal/borer/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	var/static/list/evolution_types = list(
		/datum/borer_evolution/neural_domination,
		/datum/borer_evolution/head/night_vision,
		/datum/borer_evolution/head/thermal_vision,
		/datum/borer_evolution/chest/thermal_regulation,
		/datum/borer_evolution/chest/metabolic_purge,
		/datum/borer_evolution/arm/shock_dampening,
		/datum/borer_evolution/arm/regenerative_tissue,
		/datum/borer_evolution/leg/motile_fibers,
		/datum/borer_evolution/leg/grounding_tendrils,
		/datum/borer_evolution/leg/zero_g_tendons,
		/datum/borer_evolution/expanded_glands,
		/datum/borer_evolution/efficient_glands,
		/datum/borer_evolution/chemical/head/genetic_restoration,
		/datum/borer_evolution/chemical/head/neurochemical_control,
		/datum/borer_evolution/chemical/chest/respiratory_radiation_care,
		/datum/borer_evolution/chemical/chest/metabolic_disruption,
		/datum/borer_evolution/chemical/chest/advanced_critical_care,
	)
	var/static/list/secretion_types = list(
		/datum/borer_secretion/bicaridine, /datum/borer_secretion/kelotane,
		/datum/borer_secretion/charcoal, /datum/borer_secretion/epinephrine,
		/datum/borer_secretion/head/mannitol, /datum/borer_secretion/head/oculine,
		/datum/borer_secretion/head/inacusiate, /datum/borer_secretion/chest/blood,
		/datum/borer_secretion/chest/dexalin, /datum/borer_secretion/chest/leporazine,
		/datum/borer_secretion/chest/nutriment, /datum/borer_secretion/arm/iron,
		/datum/borer_secretion/leg/ephedrine, /datum/borer_secretion/head/mutadone,
		/datum/borer_secretion/head/rezadone, /datum/borer_secretion/head/morphine,
		/datum/borer_secretion/head/space_drugs, /datum/borer_secretion/head/synaptizine,
		/datum/borer_secretion/chest/dexalinp, /datum/borer_secretion/chest/potass_iodide,
		/datum/borer_secretion/chest/capsaicin, /datum/borer_secretion/chest/frostoil,
		/datum/borer_secretion/chest/lipolicide, /datum/borer_secretion/chest/omnizine,
		/datum/borer_secretion/chest/stabilizing_nanites, /datum/borer_secretion/chest/atropine,
	)
	for(var/evolution_type in evolution_types)
		available_evolutions += new evolution_type
	for(var/secretion_type in secretion_types)
		available_secretions += new secretion_type
	evolution_menu = new(src)
	evolution_action = new(evolution_menu)
	evolution_action.Grant(src)

/mob/living/simple_animal/borer/mind_initialize()
	. = ..()
	if(mind && !mind.has_antag_datum(/datum/antagonist/borer))
		mind.add_antag_datum(/datum/antagonist/borer)

/mob/living/simple_animal/borer/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(!host)
		return
	if(host.stat == DEAD && controlling_host)
		release_host_control()
	if(host.stat != DEAD)
		chemicals = min(max_chemicals, chemicals + delta_time * (1 + chemical_regen_bonus))
		for(var/datum/borer_evolution/evolution as anything in available_evolutions)
			if(evolution.purchased && evolution.is_active(src))
				evolution.on_life(src, delta_time)
		if(world.time >= next_evolution_point)
			evolution_points++
			next_evolution_point = world.time + 2 MINUTES

/mob/living/simple_animal/borer/Destroy()
	deactivate_evolutions(host)
	QDEL_NULL(evolution_action)
	QDEL_NULL(evolution_menu)
	if(cyst?.borer == src)
		cyst.borer = null
	return ..()

/mob/living/simple_animal/borer/death(gibbed)
	deactivate_evolutions(host)
	return ..()

/mob/living/simple_animal/borer/proc/bind_to_host(mob/living/carbon/new_host, obj/item/organ/borer_cyst/new_cyst)
	if(!ishuman(new_host))
		return FALSE
	host = new_host
	cyst = new_cyst
	severed_limb = null
	if(!next_evolution_point)
		next_evolution_point = world.time + 2 MINUTES
	forceMove(cyst)
	activate_evolutions()
	to_chat(src, span_notice("You settle into [host]'s [parse_zone(cyst.zone)]."))
	return TRUE

/mob/living/simple_animal/borer/proc/on_limb_severed(obj/item/bodypart/limb)
	if(controlling_host)
		release_host_control()
	severed_limb = limb
	deactivate_evolutions(host)
	host = null
	to_chat(src, span_warning("Your host's limb has been severed. You remain hidden in it until it is reattached or surgically opened."))

/mob/living/simple_animal/borer/proc/detach(atom/drop_location)
	if(controlling_host)
		release_host_control()
	var/mob/living/carbon/human/old_host = host
	var/obj/item/organ/borer_cyst/old_cyst = cyst
	host = null
	deactivate_evolutions(old_host)
	cyst = null
	severed_limb = null
	if(old_cyst?.borer == src)
		old_cyst.borer = null
	forceMove(drop_location || get_turf(old_host) || get_turf(old_cyst))
	if(old_host)
		old_host.visible_message(span_warning("Something wriggles free from [old_host]'s flesh!"), span_userdanger("A cortical borer tears free from your flesh!"))

/mob/living/simple_animal/borer/proc/infest_human(mob/living/carbon/human/target, target_zone)
	if(host || !target || target.stat == DEAD)
		return FALSE
	target_zone = check_zone(target_zone)
	if(target.get_cortical_borer(target_zone))
		to_chat(src, span_warning("Another borer already occupies that bodypart."))
		return FALSE
	// This is intentionally the same non-piercing check used by a normal
	// syringe: only the chosen bodypart's clothing and pierce immunity matter.
	if(!target.can_inject(src, target_zone, INJECT_TRY_SHOW_ERROR_MESSAGE))
		return FALSE
	var/obj/item/organ/borer_cyst/new_cyst = new
	new_cyst.configure(src, target_zone)
	if(!new_cyst.Insert(target))
		qdel(new_cyst)
		return FALSE
	bind_to_host(target, new_cyst)
	target.visible_message(span_warning("[src] burrows into [target]'s [parse_zone(target_zone)]!"), span_userdanger("Something painfully burrows into your [parse_zone(target_zone)]!"))
	return TRUE

/mob/living/simple_animal/borer/proc/release_host_control()
	if(!controlling_host || !host)
		controlling_host = FALSE
		return FALSE
	// This mirrors split-personality's two-way body/backseat handoff.  The
	// host's mind stays with the borer while the borer player drives the host.
	var/host_ckey = host.ckey
	var/datum/mind/host_mind = host.mind
	host.ckey = ckey
	host.mind = mind
	ckey = host_ckey
	mind = host_mind
	controlling_host = FALSE
	to_chat(src, span_notice("You release control of your host."))
	to_chat(host, span_notice("You regain control of your body."))
	return TRUE

/mob/living/simple_animal/borer/proc/take_host_control()
	if(controlling_host || !host || cyst?.zone != BODY_ZONE_HEAD || host.stat == DEAD || !has_evolution(/datum/borer_evolution/neural_domination))
		return FALSE
	if(!client || !host.client)
		to_chat(src, span_warning("Both you and your host must be conscious players to exchange control."))
		return FALSE
	var/host_ckey = host.ckey
	var/datum/mind/host_mind = host.mind
	host.ckey = ckey
	host.mind = mind
	ckey = host_ckey
	mind = host_mind
	controlling_host = TRUE
	to_chat(src, span_userdanger("You seize control of your host's body."))
	to_chat(host, span_userdanger("Your cortical borer has seized control of your body!"))
	return TRUE

/mob/living/simple_animal/borer/proc/has_evolution(evolution_type)
	for(var/datum/borer_evolution/evolution as anything in available_evolutions)
		if(istype(evolution, evolution_type))
			return evolution.purchased
	return FALSE

/mob/living/simple_animal/borer/proc/has_active_evolution(evolution_type)
	for(var/datum/borer_evolution/evolution as anything in available_evolutions)
		if(istype(evolution, evolution_type))
			return evolution.purchased && evolution.is_active(src)
	return FALSE

/mob/living/simple_animal/borer/proc/purchase_evolution(evolution_type)
	for(var/datum/borer_evolution/evolution as anything in available_evolutions)
		if(!istype(evolution, evolution_type))
			continue
		if(!evolution.can_purchase(src))
			return FALSE
		evolution_points -= evolution.cost
		evolution.on_purchase(src)
		to_chat(src, span_notice("You evolve [evolution.name]."))
		return TRUE
	return FALSE

/mob/living/simple_animal/borer/proc/activate_evolutions()
	for(var/datum/borer_evolution/evolution as anything in available_evolutions)
		if(evolution.purchased && evolution.is_active(src))
			evolution.on_attached(src, host)

/mob/living/simple_animal/borer/proc/deactivate_evolutions(mob/living/carbon/human/old_host)
	if(!old_host)
		return
	for(var/datum/borer_evolution/evolution as anything in available_evolutions)
		if(evolution.purchased && evolution.is_active_in_zone(cyst?.zone))
			evolution.on_detached(src, old_host)

/mob/living/simple_animal/borer/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced, filterproof = FALSE, message_range = 7, datum/saymode/saymode, list/message_mods = list())
	if(!host)
		return ..()
	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return
	if(findtext(message, ":&") == 1)
		var/linked_message = trim(copytext_char(message, 3))
		if(!linked_message)
			return
		for(var/mob/living/simple_animal/borer/other_borer as anything in GLOB.mob_living_list)
			to_chat(other_borer, span_notice("<b>Cortical Link:</b> [real_name] says, \"[linked_message]\""))
		return
	to_chat(host, span_notice("<b>A voice in your mind:</b> \"[message]\""))
	for(var/mob/living/simple_animal/borer/other_borer in host.get_cortical_borers())
		if(other_borer != src)
			to_chat(other_borer, span_notice("<b>[real_name]</b> speaks within [host]: \"[message]\""))
	to_chat(src, span_notice("You speak within [host]: \"[message]\""))
	return TRUE

/mob/living/simple_animal/borer/verb/infest()
	set name = "Infest"
	set category = "Borer"
	if(host)
		to_chat(src, span_warning("You are already inside a host."))
		return
	var/list/candidates = list()
	for(var/mob/living/carbon/human/candidate in oview(1, src))
		if(candidate.stat != DEAD)
			candidates += candidate
	var/mob/living/carbon/human/target = tgui_input_list(src, "Choose a human to infest", "Infest", candidates)
	if(!target || !Adjacent(target))
		return
	var/target_zone = tgui_input_list(src, "Choose an entry point", "Infest", list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	if(!target_zone || !do_after(src, 3 SECONDS, target))
		return
	infest_human(target, target_zone)

/mob/living/simple_animal/borer/verb/leave_host()
	set name = "Leave Host"
	set category = "Borer"
	if(!cyst)
		return
	detach(get_turf(host) || get_turf(severed_limb))

/mob/living/simple_animal/borer/verb/assume_host_control()
	set name = "Assume Host Control"
	set category = "Borer"
	if(!host || cyst?.zone != BODY_ZONE_HEAD)
		to_chat(src, span_warning("Only a borer in a host's head can take control."))
		return
	if(controlling_host)
		release_host_control()
		return
	if(do_after(src, 5 SECONDS, host))
		take_host_control()

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set name = "Secrete Chemicals"
	set category = "Borer"
	if(!host || !host.reagents)
		to_chat(src, span_warning("You need a living host to secrete chemicals."))
		return
	var/list/secretions = list()
	for(var/datum/borer_secretion/secretion as anything in available_secretions)
		if(secretion.can_secrete(src))
			secretions[secretion.name] = secretion
	if(!length(secretions))
		to_chat(src, span_warning("Your current cyst location cannot produce any secretions."))
		return
	var/choice = tgui_input_list(src, "Choose a chemical to release into [host]", "Secrete Chemicals", secretions)
	var/datum/borer_secretion/secretion = secretions[choice]
	if(!secretion || !host || !secretion.can_secrete(src))
		return
	if(chemicals < secretion.chemical_cost)
		to_chat(src, span_warning("You need [secretion.chemical_cost] chemicals in reserve to produce [secretion.name]."))
		return
	host.reagents.add_reagent(secretion.reagent_type, secretion.dose_size)
	chemicals -= secretion.chemical_cost
	to_chat(src, span_notice("You release [secretion.dose_size] units of [secretion.name] into [host]."))

/mob/living/simple_animal/borer/verb/reproduce()
	set name = "Reproduce"
	set category = "Borer"
	if(chemicals < max_chemicals)
		to_chat(src, span_warning("You need a full chemical reserve to reproduce."))
		return
	if(!do_after(src, 5 SECONDS, src))
		return
	chemicals = 0
	var/turf/egg_turf = get_turf(host) || get_turf(src)
	new /obj/item/food/borer_egg(egg_turf)
	visible_message(span_warning("[src] expels a small, gelatinous egg!"))

/obj/item/food/borer_egg
	name = "borer egg"
	desc = "A small, gelatinous egg. It twitches faintly."
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "egg"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4)
	foodtypes = MEAT | RAW
	/// It first matures, then waits for the same plasma-and-oxygen environment
	/// used by the /vg/ egg before inviting one ghost to hatch it.
	var/grown = FALSE
	var/hatching = FALSE

/obj/item/food/borer_egg/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(ripen)), rand(2 MINUTES, 2 MINUTES + 30 SECONDS))

/obj/item/food/borer_egg/proc/ripen()
	if(QDELETED(src))
		return
	grown = TRUE
	desc = "A swollen, gelatinous egg. It looks ready to hatch."
	START_PROCESSING(SSobj, src)

/obj/item/food/borer_egg/process(delta_time)
	if(!isturf(loc))
		return
	var/turf/egg_turf = get_turf(src)
	var/datum/gas_mixture/air = egg_turf.return_air()
	if(!hatching && air?.molar_density(GAS_PLASMA) >= 0.1 && air.molar_density(GAS_O2) >= 0.1)
		hatch()

/obj/item/food/borer_egg/proc/hatch()
	if(hatching || !grown)
		return
	hatching = TRUE
	STOP_PROCESSING(SSobj, src)
	visible_message(span_notice("[src] pulsates and quivers!"))
	request_borer()

/obj/item/food/borer_egg/proc/request_borer()
	set waitfor = FALSE
	var/datum/poll_config/config = new(
		check_jobban = ROLE_BORER,
		poll_time = 10 SECONDS,
		jump_target = src,
		role_name_text = "a cortical borer",
		alert_pic = src,
		amount_to_pick = 1,
	)
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_for_target(config, src)
	if(QDELETED(src))
		return
	if(!candidate)
		hatching = FALSE
		addtimer(CALLBACK(src, PROC_REF(retry_hatching)), 5 MINUTES)
		return
	var/turf/egg_turf = get_turf(src)
	var/mob/living/simple_animal/borer/new_borer = new(egg_turf)
	new_borer.key = candidate.key
	visible_message(span_notice("[src] bursts open, releasing [new_borer]!"))
	qdel(src)

/obj/item/food/borer_egg/proc/retry_hatching()
	if(QDELETED(src))
		return
	START_PROCESSING(SSobj, src)

/obj/item/food/borer_egg/attack_ghost(mob/user)
	. = ..()
	if(grown && !hatching)
		hatch()
