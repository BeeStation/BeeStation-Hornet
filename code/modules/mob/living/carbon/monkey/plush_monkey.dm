#define PLUSH_MONKEY_TRAIT "plush_monkey"
#define PLUSH_MONKEY_FORM_TRAIT "plush_monkey_form"
#define PLUSH_KING_CHANT_TRAIT "plush_king_chant"

// - Da OBJECTIVEZ -

/datum/objective/plush_monkey_mischief
	name = "Secure Plush Interests"
	explanation_text = "Ensure the plush species' welfare and prosperity by any reasonable means."

/datum/objective/plush_monkey_mischief/check_completion()
	return TRUE

/datum/objective/plush_monkey_subterfuge
	name = "Unite Under the Crown"
	explanation_text = "Help the Plush Emperor restore the Plush Kingdom, or champion an alternative that better serves the species."

/datum/objective/plush_monkey_subterfuge/check_completion()
	return TRUE

/datum/objective/plush_king_sovereignty
	name = "Rebuild The Kingdom"
	explanation_text = "The old kingdom has fallen. Lead plushkind toward a new way of life."

/datum/objective/plush_king_sovereignty/check_completion()
	return TRUE

/datum/objective/plush_king_stewardship
	name = "Guide Plushkind"
	explanation_text = "Lead those loyal to the crown, and ensure the wellbeing of all of plushkind."

/datum/objective/plush_king_stewardship/check_completion()
	return TRUE

// - Regular Peasant Team Data! -

/datum/team/plush_monkey
	name = "Plush Kingdom Survivors"
	member_name = "survivor"
	var/obj/structure/royal_sanctuary/team_sanctuary
	var/peak_tiles = 0 // Tracts the MAX tiles, area and population for roundend report
	var/peak_areas = 0
	var/peak_population = 0

/datum/team/plush_monkey/proc/update_peak_stats()
	if(!team_sanctuary || QDELETED(team_sanctuary))
		return
	peak_tiles = max(peak_tiles, length(team_sanctuary.claimed_turfs))
	peak_areas = max(peak_areas, team_sanctuary.count_claimed_areas())
	var/current_pop = 0
	for(var/mob/living/carbon/monkey/plush/P in GLOB.player_list)
		if(!QDELETED(P) && P.stat != DEAD)
			current_pop++
	peak_population = max(peak_population, current_pop)

/datum/team/plush_monkey/roundend_report()
	var/list/parts = list()

	parts += span_header("The Plush Kingdom:")
	parts += printplayerlist(members)

	if(objectives.len)
		parts += span_header("Team had the following objectives:")
		var/win = TRUE
		var/objective_count = 1
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				win = FALSE
			parts += "<B>Objective #[objective_count]</B>: [objective.get_completion_message()]"
			objective_count++
		if(win)
			parts += span_greentext("The Plush Kingdom was successful!")
		else
			parts += span_redtext("The Plush Kingdom has failed!")

	parts += "<br>[span_header("Kingdom Statistics:")]"

	// Stats from their PEAK era
	parts += "<b>Peak Territory:</b> [peak_tiles] tile[peak_tiles == 1 ? "" : "s"] across [peak_areas] area[peak_areas == 1 ? "" : "s"]"
	parts += "<b>Peak Population:</b> [peak_population] plush [peak_population == 1 ? "subject" : "subjects"] alive"

	// Stats of how they ended... unless the seal is destroyed then THEY GET NOTHING WOMP WOMP
	if(team_sanctuary && !QDELETED(team_sanctuary))
		var/final_tiles = length(team_sanctuary.claimed_turfs)
		var/final_areas = team_sanctuary.count_claimed_areas()
		var/final_pop = 0
		for(var/mob/living/carbon/monkey/plush/P in GLOB.player_list)
			if(!QDELETED(P) && P.stat != DEAD)
				final_pop++
		parts += "<b>Final Territory:</b> [final_tiles] tile[final_tiles == 1 ? "" : "s"] across [final_areas] area[final_areas == 1 ? "" : "s"]"
		parts += "<b>Final Population:</b> [final_pop] plush [final_pop == 1 ? "subject" : "subjects"] alive"
	else
		parts += "<i>The royal court fell before the round ended and the plush kingdom was lost...</i>"

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/plush_monkey/proc/setup_objectives()
	if(length(objectives))
		return

	var/datum/objective/plush_monkey_mischief/mischief_objective = new
	mischief_objective.team = src
	objectives += mischief_objective

	var/datum/objective/plush_monkey_subterfuge/subterfuge_objective = new
	subterfuge_objective.team = src
	objectives += subterfuge_objective

	var/datum/objective/survive/survive_objective = new
	survive_objective.team = src
	objectives += survive_objective

// - Antagonist Upon Yee -

/datum/antagonist/plush_monkey
	name = "Plush Kingdom Survivor"
	banning_key = ROLE_TRAITOR
	roundend_category = "Plush Kingdom Survivors"
	antagpanel_category = "Plush Kingdom Survivors"
	show_to_ghosts = TRUE
	var/datum/team/plush_monkey/plush_team

/datum/antagonist/plush_monkey/on_gain()
	if(plush_team)
		sync_team_objectives()
	. = ..()

/// - Team Objective Accomodation Stuff -
/datum/antagonist/plush_monkey/proc/sync_team_objectives()
	if(!plush_team)
		return
	objectives.Cut()
	objectives |= plush_team.objectives

/datum/antagonist/plush_monkey/get_team()
	return plush_team

/datum/antagonist/plush_monkey/create_team(datum/team/plush_monkey/new_team)
	if(!new_team)
		plush_team = new /datum/team/plush_monkey
		plush_team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
		return
	plush_team = new_team
	plush_team.setup_objectives()

// - Ye Royal Highness Data -

/datum/antagonist/plush_king
	name = "Plush Emperor"
	banning_key = ROLE_TRAITOR
	roundend_category = "Plush Kingdom Royalty"
	antagpanel_category = "Plush Kingdom Royalty"
	show_to_ghosts = TRUE
	var/datum/team/plush_monkey/plush_team

/datum/antagonist/plush_king/on_gain()
	if(plush_team)
		copy_team_objectives(plush_team)
	. = ..()

// - Objectives and Ensuring Team Generation Stuffs! -

/datum/antagonist/plush_king/proc/copy_team_objectives(datum/team/plush_monkey/team)
	plush_team = team
	for(var/datum/objective/existing in objectives)
		qdel(existing)
	objectives.Cut()

	var/datum/objective/plush_king_sovereignty/sovereignty_objective = new
	sovereignty_objective.team = team
	objectives += sovereignty_objective

	var/datum/objective/plush_king_stewardship/stewardship_objective = new
	stewardship_objective.team = team
	objectives += stewardship_objective

	var/datum/objective/survive/survive_objective = new
	survive_objective.team = team
	objectives += survive_objective

/datum/antagonist/plush_king/get_team()
	return null

/datum/antagonist/plush_king/create_team(datum/team/plush_monkey/new_team)
	if(!new_team)
		plush_team = new /datum/team/plush_monkey
		plush_team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
		return
	plush_team = new_team
	plush_team.setup_objectives()

// - le Active Actions -

/datum/action/innate/plush_monkey_toggle // Turns the Player into a Immortal/Unmoving Plushie with no Medhud
	name = "Toggle Plush Form"
	desc = "Disguise yourself as a regular plushie, or return to normal on a small cooldown."
	button_icon = 'icons/obj/plushes.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "renaultplush"
	toggleable = TRUE
	cooldown_time = 3 SECONDS

/datum/action/innate/plush_monkey_toggle/on_activate(mob/user, atom/target, trigger_flags)
	var/mob/living/carbon/monkey/plush/plush_mob = owner
	if(!istype(plush_mob))
		qdel(src)
		return FALSE
	plush_mob.set_plush_mode(TRUE)
	start_cooldown()
	return TRUE

/datum/action/innate/plush_monkey_toggle/on_deactivate(mob/user, atom/target)
	var/mob/living/carbon/monkey/plush/plush_mob = owner
	if(!istype(plush_mob))
		qdel(src)
		return
	plush_mob.set_plush_mode(FALSE)
	start_cooldown()

/datum/action/innate/plush_monkey_access_item // Stores an ID inside da player, and works with Airlocks since theres no ID slot inherently on the mob
	name = "Stash Access ID"
	desc = "Store a held ID Card item inside your plush body."
	button_icon = 'icons/obj/card.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "id"
	check_flags = AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	cooldown_time = 2 SECONDS

/datum/action/innate/plush_monkey_access_item/on_activate(mob/user, atom/target, trigger_flags)
	var/mob/living/carbon/monkey/plush/plush_mob = owner
	if(!istype(plush_mob))
		qdel(src)
		return FALSE
	. = plush_mob.toggle_access_item()
	if(.)
		start_cooldown()

/datum/action/innate/plush_monkey_comms // Group Communication Ability!!
	name = "Plushlink"
	desc = "Send a psychic message to other plush kingdom survivors."
	button_icon = 'icons/hud/actions/action_generic.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "commune"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 1 SECONDS

/datum/action/innate/plush_monkey_comms/on_activate(mob/user, atom/target, trigger_flags)
	var/mob/living/carbon/monkey/plush/plush_mob = owner
	if(!istype(plush_mob))
		qdel(src)
		return FALSE

	var/message = tgui_input_text(user, "Send a message to the plush network.", "Plushlink", "", max_length = MAX_MESSAGE_LEN)
	if(!message || !is_available())
		return FALSE
	if(CHAT_FILTER_CHECK(message))
		to_chat(user, span_warning("You cannot send a message that contains a word prohibited in IC chat!"))
		return FALSE

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!length(message))
		return FALSE

	plush_mob.broadcast_plushlink(message)
	start_cooldown()
	return TRUE

/datum/action/innate/plush_monkey_summon_explosion // When in plush form, Players can make a small explosion of Plush TOYS, some runs around but its great decoy stuff!
	name = "Summon Plush Swarm"
	desc = "Summon a cluster of plushies around you for cover and chaos."
	button_icon = 'icons/obj/plushes.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "debug"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 10 SECONDS

/datum/action/innate/plush_monkey_summon_explosion/on_activate(mob/user, atom/target, trigger_flags)
	var/mob/living/carbon/monkey/plush/plush_mob = owner
	if(!istype(plush_mob))
		qdel(src)
		return FALSE
	if(!plush_mob.plush_form)
		plush_mob.balloon_alert(plush_mob, "Can only be used while in plush form!")
		return FALSE

	plush_mob.summon_plush_explosion()
	start_cooldown()
	return TRUE

//  - Le ROYAL Active Actions -

/datum/action/innate/plush_monkey_return_to_seal // TP's Ruler back to da court seal (only shows after seal is placed)
	name = "Return to Court Seal"
	desc = "Begin a brief royal chant to bring yourself back to the Court Seal."
	button_icon = 'icons/obj/clothing/head/costume.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "crown"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 25 SECONDS

/datum/action/innate/plush_monkey_return_to_seal/on_activate(mob/user, atom/target, trigger_flags)
	var/mob/living/carbon/monkey/plush/king/king_mob = owner
	if(!istype(king_mob))
		qdel(src)
		return FALSE
	if(!king_mob.return_to_court_seal())
		return FALSE
	start_cooldown()
	return TRUE

/datum/action/innate/plush_monkey_knighthood // Grants a nearby Plush Mob a Custom Title
	name = "Bestow Knighthood"
	desc = "Knight a nearby plush subject, granting them a royal title and marking their Plushlink messages with honor."
	button_icon = 'icons/obj/items_and_weapons.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "claymore"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 12 SECONDS

/datum/action/innate/plush_monkey_knighthood/on_activate(mob/user, atom/target, trigger_flags)
	var/mob/living/carbon/monkey/plush/king/king_mob = owner
	if(!istype(king_mob))
		qdel(src)
		return FALSE
	if(!king_mob.bestow_knighthood())
		return FALSE
	start_cooldown()
	return TRUE

/datum/action/innate/plush_monkey_sanctuary // Ritual to place the Court Seal!
	name = "Establish Court"
	desc = "Establish your current location as the Royal Court. Plush survivors within the Court's borders heal passively, and the area is visually distinct. The Court can be attacked and dismantled by non-Plush entities, but can only be established once."
	button_icon = 'icons/obj/clothing/head/costume.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "fancycrown"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/plush_monkey_sanctuary/on_activate(mob/user, atom/target, trigger_flags)
	var/mob/living/carbon/monkey/plush/king/king_mob = owner
	if(!istype(king_mob))
		qdel(src)
		return FALSE
	if(!king_mob.use_royal_sanctuary())
		return FALSE
	qdel(src)
	return TRUE

/datum/action/innate/plush_monkey_expand_court // Claims the area the Player is in to the court
	name = "Expand Borders"
	desc = "Channel a royal decree to lay claim to a nearby adjacent area as part of the Royal Court. Use the Court Seal directly to manage or relinquish claimed territory. Growing too large will draw unwanted attention from Central Command, so use this power wisely."
	button_icon = 'icons/obj/clothing/head/costume.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "fancycrown"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 30 SECONDS
/datum/action/innate/plush_monkey_expand_court/on_activate(mob/user, atom/target, trigger_flags)
	var/mob/living/carbon/monkey/plush/king/king_mob = owner
	if(!istype(king_mob))
		qdel(src)
		return FALSE
	if(!king_mob.expand_royal_sanctuary())
		return FALSE
	start_cooldown()
	return TRUE

// - Slowdown for Exiting Plush Form & Custom ID for the Plush Mobs -

/datum/movespeed_modifier/plush_exit_slowdown
	id = "plush_exit_slowdown"
	variable = TRUE
	multiplicative_slowdown = 0.35

/obj/item/card/id/plush_kingdom
	name = "makeshift plush credential"
	desc = "This card was not issued, or approved by Nanotrasen. It somehow accesses Nanotrasen maintenance tunnels regardless."
	assignment = null
	hud_state = JOB_HUD_UNKNOWN
	electric = FALSE
	access = list(ACCESS_MAINT_TUNNELS)
	icon_state = "data_3"

// ---- Generic Plush Mob path: (/mob/living/carbon/monkey/plush) ----

/mob/living/carbon/monkey/plush
	name = "sentient plush"
	desc = "A plushie with surprising dexterity."
	initial_language_holder = /datum/language_holder/atom_basic
	verb_say = "squeaks"
	verb_ask = "squeaks inquisitively"
	verb_exclaim = "squeaks loudly"
	verb_yell = "squeaks loudly"
	death_message = "lets out a faint squeak as it collapses and stops moving"
	death_sound = 'sound/items/toysqueak1.ogg'
	maxHealth = 80
	icon = 'icons/obj/plushes.dmi'
	icon_state = "renaultplush"
	ai_controller = null
	var/plush_form = FALSE
	var/plush_form_type = /obj/item/toy/plush/renault
	var/normal_name
	var/normal_real_name
	var/normal_desc
	var/normal_density = TRUE
	var/plush_item_name = "renault plushie"
	var/plush_item_desc = "AWOOOO!"
	var/static/datum/team/plush_monkey/admin_spawn_team
	var/obj/item/access_item
	var/spawn_loadout_granted = FALSE
	var/datum/action/innate/plush_monkey_toggle/plush_toggle_action
	var/datum/action/innate/plush_monkey_access_item/access_item_action
	var/datum/action/innate/plush_monkey_comms/plush_comms_action
	var/datum/action/innate/plush_monkey_summon_explosion/plush_explosion_action
	var/knighted = FALSE
	var/knight_title = ""
	var/base_identity_name
	var/list/hidden_data_huds = list()
	var/static/list/plush_squeak_sounds = list(
		'sound/items/toysqueak1.ogg' = 1,
		'sound/items/toysqueak2.ogg' = 1,
		'sound/items/toysqueak3.ogg' = 1,
	)
	var/static/list/non_moth_plush_form_types = list(
		/obj/item/toy/plush/renault,
		/obj/item/toy/plush/lisa,
		/obj/item/toy/plush/runtime,
		/obj/item/toy/plush/lizard_plushie,
		/obj/item/toy/plush/lizard_plushie/space,
		/obj/item/toy/plush/slimeplushie,
		/obj/item/toy/plush/slimeplushie/pink,
		/obj/item/toy/plush/slimeplushie/green,
		/obj/item/toy/plush/slimeplushie/blue,
		/obj/item/toy/plush/slimeplushie/red,
		/obj/item/toy/plush/slimeplushie/rainbow,
	)
	var/static/list/moth_plush_form_types = list(
		/obj/item/toy/plush/moth,
		/obj/item/toy/plush/moth/monarch,
		/obj/item/toy/plush/moth/luna,
		/obj/item/toy/plush/moth/atlas,
		/obj/item/toy/plush/moth/redish,
		/obj/item/toy/plush/moth/royal,
		/obj/item/toy/plush/moth/gothic,
		/obj/item/toy/plush/moth/lovers,
		/obj/item/toy/plush/moth/whitefly,
		/obj/item/toy/plush/moth/punished,
		/obj/item/toy/plush/moth/firewatch,
		/obj/item/toy/plush/moth/deadhead,
		/obj/item/toy/plush/moth/poison,
		/obj/item/toy/plush/moth/ragged,
		/obj/item/toy/plush/moth/snow,
		/obj/item/toy/plush/moth/clockwork,
		/obj/item/toy/plush/moth/moonfly,
		/obj/item/toy/plush/moth/witchwing,
		/obj/item/toy/plush/moth/bluespace,
		/obj/item/toy/plush/moth/plasmafire,
		/obj/item/toy/plush/moth/brown,
		/obj/item/toy/plush/moth/rosy,
		/obj/item/toy/plush/moth/rainbow,
	)

/mob/living/carbon/monkey/plush/Initialize(mapload, cubespawned=FALSE, mob/spawner)
	. = ..()
	health = maxHealth
	ADD_TRAIT(src, TRAIT_NOHUNGER, PLUSH_MONKEY_TRAIT)
	set_safe_hunger_level()
	ADD_TRAIT(src, TRAIT_RESISTLOWPRESSURE, PLUSH_MONKEY_TRAIT)
	ADD_TRAIT(src, TRAIT_RESISTHIGHPRESSURE, PLUSH_MONKEY_TRAIT)
	ADD_TRAIT(src, TRAIT_RESISTCOLD, PLUSH_MONKEY_TRAIT)
	ADD_TRAIT(src, TRAIT_RESISTHEAT, PLUSH_MONKEY_TRAIT)
	ADD_TRAIT(src, TRAIT_NIGHT_VISION_WEAK, PLUSH_MONKEY_TRAIT)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, PLUSH_MONKEY_TRAIT)
	RegisterSignal(src, COMSIG_MOB_TRIED_ACCESS, PROC_REF(on_tried_access))
	normal_name = name
	normal_real_name = real_name
	base_identity_name = real_name
	normal_desc = desc
	normal_density = density
	apply_plush_form(pick_random_plush_form_type())
	remove_overlay(BODYPARTS_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	plush_toggle_action = new()
	plush_toggle_action.Grant(src)
	access_item_action = new()
	access_item_action.Grant(src)
	plush_comms_action = new()
	plush_comms_action.Grant(src)
	plush_explosion_action = new()
	sync_plush_action_icons()
	sync_plush_explosion_action()
	sync_access_item_action()
	grant_inherent_access_id()
	grant_spawn_loadout()
	purge_incompatible_equipment()

/mob/living/carbon/monkey/plush/Login()
	. = ..()
	ensure_plush_antag_datum()
	hide_incompatible_inventory_slots()


/mob/living/carbon/monkey/plush/mind_initialize()
	. = ..()
	ensure_plush_antag_datum()

/mob/living/carbon/monkey/plush/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(slot == ITEM_SLOT_HEAD || slot == ITEM_SLOT_ICLOTHING)
		return FALSE
	return ..()

/mob/living/carbon/monkey/plush/toggle_internals(obj/item/tank) // Makes Oxygen Tanks work with Plush Mobs
	var/obj/item/existing_tank = internal
	if(tank == existing_tank)
		return toggle_close_internals()
	if(can_breathe_tube())
		return toggle_open_internals(tank)
	if(isclothing(wear_mask) && ((wear_mask.visor_flags & MASKINTERNALS) || (wear_mask.clothing_flags & MASKINTERNALS)))
		return toggle_open_internals(tank)
	if(wear_mask)
		to_chat(src, span_warning("[wear_mask] can't use [tank]!"))
	else
		to_chat(src, span_warning("You need a mask!"))

/mob/living/carbon/monkey/plush/proc/purge_incompatible_equipment()
	if(head)
		doUnEquip(head, force = TRUE, newloc = drop_location(), silent = TRUE)
	if(w_uniform)
		doUnEquip(w_uniform, force = TRUE, newloc = drop_location(), silent = TRUE)

/mob/living/carbon/monkey/plush/proc/hide_incompatible_inventory_slots() // Disables Head/Clothing slot since Plush Icons arent meant for it and it made a runtime xd
	if(!client || !hud_used)
		return
	var/list/hidden_slots = list(ITEM_SLOT_HEAD, ITEM_SLOT_ICLOTHING)
	for(var/slot in hidden_slots)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(slot) + 1]
		if(!inv)
			continue
		inv.alpha = 0
		inv.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// Forces The antagonist upon the mobs, and grants starting items

/mob/living/carbon/monkey/plush/proc/ensure_plush_antag_datum()
	if(QDELETED(src) || !mind)
		return
	if(!mind.has_antag_datum(/datum/antagonist/plush_monkey))
		var/datum/antagonist/plush_monkey/antag_datum = mind.add_antag_datum(/datum/antagonist/plush_monkey, admin_spawn_team)
		if(antag_datum && !admin_spawn_team)
			admin_spawn_team = antag_datum.plush_team

/mob/living/carbon/monkey/plush/king/ensure_plush_antag_datum()
	if(QDELETED(src) || !mind)
		return
	if(!mind.has_antag_datum(/datum/antagonist/plush_king))
		var/datum/antagonist/plush_king/antag_datum = mind.add_antag_datum(/datum/antagonist/plush_king, admin_spawn_team)
		if(antag_datum && !admin_spawn_team)
			admin_spawn_team = antag_datum.plush_team

/mob/living/carbon/monkey/plush/proc/grant_spawn_loadout()
	if(spawn_loadout_granted)
		return
	spawn_loadout_granted = TRUE

	grant_spawn_item(/obj/item/clothing/mask/breath, ITEM_SLOT_MASK)
	grant_spawn_item(/obj/item/storage/backpack/satchel/flat, ITEM_SLOT_BACK)
	grant_spawn_item(/obj/item/tank/internals/oxygen, ITEM_SLOT_HANDS)

/mob/living/carbon/monkey/plush/proc/grant_inherent_access_id()
	if(access_item)
		return
	var/obj/item/card/id/plush_kingdom/inherent_id = new(src)
	access_item = inherent_id
	sync_access_item_action()

/mob/living/carbon/monkey/plush/proc/grant_spawn_item(obj/item/item_path, slot)
	var/obj/item/new_item = new item_path(src)
	if(equip_to_slot_if_possible(new_item, slot))
		return
	if(put_in_hands(new_item))
		return
	new_item.forceMove(drop_location())

/mob/living/carbon/monkey/plush/Destroy()
	if(access_item)
		access_item.forceMove(drop_location())
		access_item = null
	UnregisterSignal(src, COMSIG_MOB_TRIED_ACCESS)
	QDEL_NULL(plush_explosion_action)
	QDEL_NULL(plush_comms_action)
	QDEL_NULL(access_item_action)
	QDEL_NULL(plush_toggle_action)
	return ..()

/mob/living/carbon/monkey/plush/proc/apply_plush_form(obj/item/toy/plush/new_form_type) // Makes Plush Form Work as Intended
	plush_form_type = new_form_type
	var/obj/item/toy/plush/template = new plush_form_type()
	plush_item_name = template.name
	plush_item_desc = template.desc
	icon = template.icon
	icon_state = template.icon_state
	gender = template.gender
	sync_plush_action_icons()
	qdel(template)

/mob/living/carbon/monkey/plush/proc/sync_plush_action_icons()
	if(plush_toggle_action)
		plush_toggle_action.button_icon_state = icon_state
		plush_toggle_action.update_buttons()

/mob/living/carbon/monkey/plush/proc/sync_plush_explosion_action()
	if(!plush_explosion_action)
		return
	if(plush_form)
		if(plush_explosion_action.owner != src)
			plush_explosion_action.Grant(src)
		plush_explosion_action.update_buttons()
		return
	if(plush_explosion_action.owner == src)
		plush_explosion_action.Remove(src)

/mob/living/carbon/monkey/plush/proc/pick_random_plush_form_type()
	if(prob(40)) // Moths are their own list otherwise they are the only roll.... :(
		return pick(moth_plush_form_types)
	return pick(non_moth_plush_form_types)

/mob/living/carbon/monkey/plush/proc/pick_runaway_count(total_plushes) // Figuring out how many spawned decoy plushes should run
	if(total_plushes <= 0)
		return 0

	var/runaway_count
	switch(rand(1, 100))
		if(1 to 20)
			runaway_count = 0
		if(21 to 80)
			runaway_count = 1
		if(81 to 95)
			runaway_count = 2
		else
			runaway_count = 3

	return min(runaway_count, total_plushes)

/mob/living/carbon/monkey/plush/proc/set_plush_mode(enabled) // Plush mode code, gets them traits goin!
	if(plush_form == enabled)
		return

	plush_form = enabled
	if(enabled)
		name = plush_item_name
		real_name = plush_item_name
		desc = plush_item_desc
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, PLUSH_MONKEY_FORM_TRAIT)
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, PLUSH_MONKEY_FORM_TRAIT)
		ADD_TRAIT(src, TRAIT_GODMODE, PLUSH_MONKEY_FORM_TRAIT)
		set_density(FALSE)
		balloon_alert(src, "plush form")
		set_plush_data_hud_hidden(TRUE)
		if(client)
			create_plush_overlay()
	else
		name = normal_name
		real_name = normal_real_name
		desc = normal_desc
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, PLUSH_MONKEY_FORM_TRAIT)
		REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, PLUSH_MONKEY_FORM_TRAIT)
		REMOVE_TRAIT(src, TRAIT_GODMODE, PLUSH_MONKEY_FORM_TRAIT)
		set_density(normal_density)
		balloon_alert(src, "mobile again")
		set_plush_data_hud_hidden(FALSE)
		apply_plush_exit_slowdown()
		if(client)
			remove_plush_overlay()

	sync_plush_explosion_action()

/mob/living/carbon/monkey/plush/proc/set_plush_data_hud_hidden(hidden) // Hides from HUDs, damn things reveal all!
	var/static/list/tracked_data_huds = list(
		DATA_HUD_SECURITY_BASIC,
		DATA_HUD_SECURITY_ADVANCED,
		DATA_HUD_MEDICAL_BASIC,
		DATA_HUD_MEDICAL_ADVANCED,
	)

	if(hidden)
		hidden_data_huds = list()
		for(var/hud_type in tracked_data_huds)
			var/datum/atom_hud/data/hud = GLOB.huds[hud_type]
			if(!hud)
				continue
			if(src in hud.hudatoms)
				hud.remove_from_hud(src)
				hidden_data_huds += hud_type
		return

	if(!length(hidden_data_huds))
		return

	for(var/hud_type in hidden_data_huds)
		var/datum/atom_hud/data/hud = GLOB.huds[hud_type]
		hud?.add_to_hud(src)
	hidden_data_huds.Cut()

/mob/living/carbon/monkey/plush/proc/apply_plush_exit_slowdown() // Gives a small fading slowdown on exiting plush mode
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/plush_exit_slowdown, TRUE, 0.35)
	addtimer(CALLBACK(src, PROC_REF(fade_plush_slowdown_step1)), 1 SECONDS)

/mob/living/carbon/monkey/plush/proc/fade_plush_slowdown_step1()
	if(QDELETED(src))
		return
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/plush_exit_slowdown, TRUE, 0.20)
	addtimer(CALLBACK(src, PROC_REF(fade_plush_slowdown_step2)), 1 SECONDS)

/mob/living/carbon/monkey/plush/proc/fade_plush_slowdown_step2()
	if(QDELETED(src))
		return
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/plush_exit_slowdown, TRUE, 0.08)
	addtimer(CALLBACK(src, PROC_REF(clear_plush_slowdown)), 1 SECONDS)

/mob/living/carbon/monkey/plush/proc/clear_plush_slowdown()
	if(QDELETED(src))
		return
	remove_movespeed_modifier(/datum/movespeed_modifier/plush_exit_slowdown, TRUE)

/mob/living/carbon/monkey/plush/proc/on_tried_access(mob/accessor, obj/locked_thing)
	SIGNAL_HANDLER
	var/obj/item/card/id/id_card = access_item?.GetID()
	return locked_thing?.check_access(id_card) ? ACCESS_ALLOWED : ACCESS_DISALLOWED

/mob/living/carbon/monkey/plush/proc/get_plush_display_name() // Including Titles in their names
	var/display_name = plush_form ? normal_real_name : real_name
	if(!display_name)
		display_name = normal_real_name || real_name || base_identity_name || name
	if(knighted && length(knight_title))
		var/title_prefix = "([knight_title]) "
		if(findtext(display_name, title_prefix) != 1)
			var/identity_name = base_identity_name || normal_real_name || real_name || name
			return "[title_prefix][identity_name]"
	return display_name

/mob/living/carbon/monkey/plush/proc/broadcast_plushlink(message)
	var/header
	var/body = "<span style='color:#ffd9f2;'>[message]</span>"
	if(knighted)
		header = "<span style='color:#ff8c00;'><b>&lt;&lt; PLUSHLINK &gt;&gt; [get_plush_display_name()]:</b></span>"
	else
		header = "<span style='color:#ff5abf;'><b>&lt;&lt; PLUSHLINK &gt;&gt; [get_plush_display_name()]:</b></span>"
	var/rendered_message = span_boldnotice("[header] [body]")
	for(var/mob/living/carbon/monkey/plush/recipient in GLOB.player_list)
		if(QDELETED(recipient) || !recipient.client)
			continue
		to_chat(recipient, rendered_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = recipient == src)
		if(recipient != src)
			playsound(recipient, pick_weight(plush_squeak_sounds), 30, TRUE)
	log_talk(message, LOG_SAY, tag = "plushlink")

/mob/living/carbon/monkey/plush/proc/summon_plush_explosion() // PLUSH EXPLOSION!!! Spawns plushes around the player, does the decoy and all that jazz
	var/turf/origin_turf = get_turf(src)
	var/list/preferred_spawn_turfs = list()
	var/list/fallback_spawn_turfs = list()
	for(var/turf/open/possible_turf in range(2, origin_turf))
		if(possible_turf == origin_turf)
			continue
		if(possible_turf.density || possible_turf.is_blocked_turf())
			continue
		if(locate(/obj/item/toy/plush) in possible_turf)
			fallback_spawn_turfs += possible_turf
		else
			preferred_spawn_turfs += possible_turf

	if(!length(preferred_spawn_turfs) && !length(fallback_spawn_turfs))
		fallback_spawn_turfs = get_adjacent_open_turfs(origin_turf)

	if(length(preferred_spawn_turfs) || length(fallback_spawn_turfs))
		var/list/displace_pool = length(preferred_spawn_turfs) ? preferred_spawn_turfs : fallback_spawn_turfs
		var/turf/displace_turf = pick(displace_pool)
		var/old_glide_size = glide_size
		set_glide_size(0)
		src.forceMove(displace_turf)
		set_glide_size(old_glide_size)

	var/total_available_spawn_turfs = length(preferred_spawn_turfs) + length(fallback_spawn_turfs)
	if(!total_available_spawn_turfs)
		return

	playsound(src, pick_weight(plush_squeak_sounds), 50, TRUE)
	var/spawn_count = min(rand(6, 8), total_available_spawn_turfs)
	var/matching_plush_spawns_remaining = min(rand(2, 3), spawn_count)
	var/list/spawned_plushes = list()
	for(var/i in 1 to spawn_count)
		var/turf/spawn_turf
		if(length(preferred_spawn_turfs))
			spawn_turf = pick_n_take(preferred_spawn_turfs)
		else
			spawn_turf = pick_n_take(fallback_spawn_turfs)
		if(!spawn_turf)
			break
		var/plushie_type
		if(matching_plush_spawns_remaining > 0)
			plushie_type = plush_form_type
			matching_plush_spawns_remaining--
		else
			plushie_type = pick_random_plush_form_type()
		var/obj/item/toy/plush/spawned_plush = new plushie_type(spawn_turf)
		spawned_plush.anchored = FALSE
		spawned_plushes += spawned_plush
		playsound(spawned_plush, pick_weight(plush_squeak_sounds), 40, TRUE)

	if(!length(spawned_plushes))
		return

	var/runaway_count = pick_runaway_count(length(spawned_plushes))
	if(!runaway_count)
		return

	var/list/runaway_pool = spawned_plushes.Copy()
	for(var/i in 1 to runaway_count)
		var/obj/item/toy/plush/decoy = pick_n_take(runaway_pool)
		if(!decoy)
			continue
		INVOKE_ASYNC(src, PROC_REF(runaway_plush_decoy), decoy, origin_turf, rand(12, 18))

/mob/living/carbon/monkey/plush/proc/runaway_plush_decoy(obj/item/toy/plush/decoy, turf/origin_turf, max_steps = 12)
	if(QDELETED(src) || QDELETED(decoy) || !origin_turf)
		return

	for(var/i in 1 to max(1, max_steps))
		if(QDELETED(decoy))
			return
		if(decoy.anchored)
			return

		var/turf/current_turf = get_turf(decoy)
		if(!current_turf)
			return
		if(decoy.loc != current_turf)
			return

		var/turf/next_turf = get_step_away(decoy, origin_turf)
		if(!istype(next_turf, /turf/open) || next_turf.density || next_turf.is_blocked_turf())
			var/list/preferred_steps = list()
			var/list/fallback_steps = list()
			var/current_dist = get_dist(current_turf, origin_turf)
			for(var/direction in GLOB.alldirs)
				var/turf/open/candidate_turf = get_step(current_turf, direction)
				if(!candidate_turf || candidate_turf.density || candidate_turf.is_blocked_turf())
					continue
				if(get_dist(candidate_turf, origin_turf) >= current_dist)
					preferred_steps += candidate_turf
				else
					fallback_steps += candidate_turf

			next_turf = length(preferred_steps) ? pick(preferred_steps) : pick(fallback_steps)
			if(!next_turf)
				return

		decoy.forceMove(next_turf)
		if(prob(30))
			playsound(decoy, pick_weight(plush_squeak_sounds), 25, TRUE)
		sleep(rand(2, 4))

/mob/living/carbon/monkey/plush/proc/sync_access_item_action() // ID store ability code, makes the desc and whatnot update depending on context of use
	if(!access_item_action)
		return
	access_item_action.button_icon = 'icons/obj/card.dmi'
	access_item_action.button_icon_state = "id"
	if(access_item)
		access_item_action.name = "Retrieve ID Card"
		access_item_action.desc = "Pull the stored ID Card back out of your plush body."
	else
		access_item_action.name = "Stash ID Card"
		access_item_action.desc = "Store a held ID Card inside your plush body."
	access_item_action.update_buttons()

/mob/living/carbon/monkey/plush/proc/toggle_access_item()
	if(access_item)
		return eject_access_item()

	var/obj/item/held_item = get_active_held_item()
	if(!held_item)
		held_item = get_inactive_held_item()
	if(!held_item)
		balloon_alert(src, "hold ID Card")
		return FALSE
	if(!held_item.GetID())
		balloon_alert(src, "not an ID Card")
		return FALSE
	if(!transferItemToLoc(held_item, src))
		balloon_alert(src, "couldn't stash it")
		return FALSE

	access_item = held_item
	sync_access_item_action()
	balloon_alert(src, "ID stashed")
	return TRUE

/mob/living/carbon/monkey/plush/proc/eject_access_item()
	if(!access_item)
		balloon_alert(src, "no ID Card")
		return FALSE

	var/obj/item/stored_item = access_item
	access_item = null
	sync_access_item_action()
	if(put_in_hands(stored_item))
		balloon_alert(src, "ID retrieved")
		return TRUE

	stored_item.forceMove(drop_location())
	balloon_alert(src, "ID dropped")
	return TRUE

/mob/living/carbon/monkey/plush/examine(mob/user)
	if(plush_form)
		. = list()
		if(desc)
			. += "<i>[desc]</i>"
	else
		. = ..()

	return .

/mob/living/carbon/monkey/plush/ZImpactDamage(turf/impacted_turf, levels) // Prevents FALL DAMAGE, useful for planned event entry method... not much else
	visible_message(span_notice("[src] bounces off [impacted_turf] with a soft squeak, completely unharmed!"), \
					span_notice("You hit [impacted_turf] and bounce harmlessly. Being made of stuffing has its perks."))
	playsound(src, pick_weight(plush_squeak_sounds), 50, TRUE)

/mob/living/carbon/monkey/plush/update_body_parts(update_limb_data) // Removes dat head icon and stuff!
	remove_overlay(BODYPARTS_LAYER)
	overlays_standing[BODYPARTS_LAYER] = null
	return

/mob/living/carbon/monkey/plush/update_clothing_icons(c_layer) // Does more removal of the clothing icon and slot!
	..()
	remove_overlay(c_layer)
	overlays_standing[c_layer] = null
	return

/mob/living/carbon/monkey/plush/proc/create_plush_overlay() // Applies visual on plush mode to make it noticible
	overlay_fullscreen("plush_form", /atom/movable/screen/fullscreen/impaired/plush_monkey, 1)

/mob/living/carbon/monkey/plush/proc/remove_plush_overlay() // Deletes plush mode visual when exiting the mode
	clear_fullscreen("plush_form", 0)

/atom/movable/screen/fullscreen/impaired/plush_monkey // Plush Mode visual ALPHA setting
	alpha = 55

/obj/effect/royal_sanctuary_aura // Golden Shimmer on claimed tiles
	name = "royal warmth"
	desc = "The air shimmers faintly gold."
	icon = 'icons/effects/effects.dmi'
	icon_state = "blessed"
	color = "#FFD700"
	alpha = 35
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_NORMAL_TURF_LAYER

// - Stat e us  Effects -

/datum/status_effect/royal_court_regen // Heals Plushes inside claimed territory
	id = "Royal Court Regeneration"
	status_type = STATUS_EFFECT_REFRESH
	duration = 4 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/royal_court_regen

/atom/movable/screen/alert/status_effect/royal_court_regen
	name = "Court's Protection"
	desc = "The Royal Seal stitches your form back together."
	icon_state = "template"

/atom/movable/screen/alert/status_effect/royal_court_regen/Initialize(mapload) // Little uh- trick to make the icon look like a crown...
	. = ..()
	add_overlay(icon('icons/obj/clothing/head/costume.dmi', "crown"))

/datum/movespeed_modifier/status_effect/royal_court_hostile // DEBUFF to non-plush mobs in claimed territory DURING WARTIME TOGGLE, get out bozos
	id = "royal_court_hostile"
	multiplicative_slowdown = 0.24 // Wartime Slowndown

/datum/status_effect/royal_court_hostile
	id = "Royal Court Hostility"
	status_type = STATUS_EFFECT_REFRESH
	duration = 4 SECONDS
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/royal_court_hostile

/datum/status_effect/royal_court_hostile/tick(seconds_between_ticks) // Death upon tresspassers Stamina
	if(isliving(owner))
		owner.adjustStaminaLoss(7 * seconds_between_ticks) // Wartime Stamina Drain
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/royal_court_hostile)

/datum/status_effect/royal_court_hostile/on_remove()
	if(isliving(owner))
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/royal_court_hostile)

/atom/movable/screen/alert/status_effect/royal_court_hostile // Wartime Debuff Alert
	name = "Hostile Conditions"
	desc = "Local conditions are hostile to crew. Movement and stamina are impaired."
	icon_state = "weaken"

/atom/movable/screen/alert/status_effect/royal_court_hostile/Initialize(mapload)
	return ..()

/datum/movespeed_modifier/status_effect/royal_court_trespass // NON WARTIME debuff, just a mild slowdown stam drain, no big cheese
	id = "royal_court_trespass"
	multiplicative_slowdown = 0.12 // NON Wartime Slowndown

/datum/status_effect/royal_court_trespass
	id = "Royal Court Trespass"
	status_type = STATUS_EFFECT_REFRESH
	duration = 4 SECONDS
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/royal_court_trespass

/datum/status_effect/royal_court_trespass/tick(seconds_between_ticks)
	if(isliving(owner))
		owner.adjustStaminaLoss(1.5 * seconds_between_ticks) // NON WARTIME Stamina Drain
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/royal_court_trespass)

/datum/status_effect/royal_court_trespass/on_remove()
	if(isliving(owner))
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/royal_court_trespass)

/atom/movable/screen/alert/status_effect/royal_court_trespass
	name = "Unstable Territory"
	desc = "Local conditions feel wrong and unfavorable to crew operations."
	icon_state = "high"

// - Royal Seal, the IMPORTANT THING -

/obj/structure/royal_sanctuary
	name = "Royal Plush Seal"
	desc = "A small golden seal pressed into the floor. The air nearby feels unusually still."
	icon = 'icons/obj/clothing/head/costume.dmi'
	icon_state = "fancycrown"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_OBJ_LAYER
	max_integrity = INFINITY
	var/mob/living/carbon/monkey/plush/king/king_owner
	var/list/aura_effects = list()
	var/list/claimed_turfs = list()
	var/regen_active = FALSE
	var/command_notification_sent = FALSE // If CC has been notified about the Court Size growing beyond a set limit
	var/war_hazard_notification_sent = FALSE // If Wartime has been toggled CC gets notified
	var/command_notification_area_threshold = 6 // Size Threshold for cc to be notified
	var/next_regen_pulse = 0
	var/regen_tick_rate = 2 SECONDS // How often Healing Happens - Heals ALL types
	var/inner_regen_range = 7 // Range for INCREASED healing (Seeing the Seal Boosts Its Regen)
	var/outer_plush_heal = 5 // How much a PLUSH MOB heals beyond outer_regen_range
	var/inner_plush_heal = 7 // How much a PLUSH MOB heals within inner_regen_range
	var/outer_king_heal = 3 // How much the KING MOB heals beyond outer_regen_range
	var/inner_king_heal = 4 // How much the KING MOB heals within inner_regen_range
	var/peace_heal_multiplier = 1 // Peacetime Healing Modifier, 1=None
	var/war_heal_multiplier = 1.3 // WARTIME healing Modifier, 1.3=30% increase
	var/manual_relocation_active = FALSE
	var/manual_relocation_end_time = 0
	var/manual_relocation_duration = 30 SECONDS // How long the seal can remain unanchored for when the king uses the Relocate ability
	var/dismantle_in_progress = FALSE
	var/mob/living/current_dismantler
	var/dismantle_start_time = 0
	var/dismantle_duration = 45 SECONDS // how LONG it takes to dismantle the seal
	var/next_royal_summons = 0
	var/royal_summons_cooldown = 45 SECONDS // Cooldown duration for Royal Summons in seal menu
	var/war_mode_active = FALSE
	var/next_war_toggle = 0
	var/war_toggle_cooldown = 30 SECONDS // Cooldown to toggle Wartime on & off
	var/war_protocol_alert_sound = 'sound/magic/staff_chaos.ogg' // Plays a sound when its wartime... i couldnt find a better sound
	var/war_entry_alert_sound = 'sound/magic/voidblink.ogg' // Plays a sound when you ENTER the area during wartime, on cooldown!
	var/war_entry_alert_volume = 26
	var/list/war_entry_warning_cooldown = list()
	var/list/claimed_turf_presence = list()
	var/list/plush_turf_presence = list()
	var/war_entry_warning_interval = 8 SECONDS // Delay between message/audio cues for tresspassing for spam prevention

/obj/structure/royal_sanctuary/Initialize(mapload)
	. = ..()
	color = "#FFD700"
	start_hover_animation()

/obj/structure/royal_sanctuary/proc/start_hover_animation()
	pixel_y = 0
	animate(src, pixel_y = 5, time = 8, loop = -1)
	animate(pixel_y = 0, time = 8)

/obj/structure/royal_sanctuary/proc/stop_hover_animation()
	animate(src, pixel_y = 0, time = 2)

/obj/structure/royal_sanctuary/ex_act(severity)
	return

/obj/structure/royal_sanctuary/Destroy()
	current_dismantler = null
	clear_war_effects()
	dismiss_aura()
	regen_active = FALSE
	STOP_PROCESSING(SSfastprocess, src)
	claimed_turfs.Cut()
	war_entry_warning_cooldown.Cut()
	claimed_turf_presence.Cut()
	plush_turf_presence.Cut()
	if(king_owner && !QDELETED(king_owner))
		if(king_owner.return_to_seal_action?.owner == king_owner)
			king_owner.return_to_seal_action.Remove(king_owner)
		king_owner.active_sanctuary = null
	king_owner = null
	return ..()

/obj/structure/royal_sanctuary/examine(mob/user)
	. = ..()
	if(manual_relocation_active)
		var/time_left = max(0, round((manual_relocation_end_time - world.time) / 10, 0.1))
		. += span_warning("The seal is temporarily unanchored and can be pulled ([time_left]s remaining).")
	if(istype(user, /mob/living/carbon/monkey/plush/king) && user == king_owner)
		. += span_notice("Your court. Your kingdom. Even in a place like this.")
		. += span_notice("Click the seal to manage your court.")
		var/area_count = count_claimed_areas()
		. += span_notice("Your kingdom spans [length(claimed_turfs)] tiles across [area_count] area[area_count == 1 ? "" : "s"].")
	else if(HAS_TRAIT(user, PLUSH_MONKEY_TRAIT))
		. += span_notice("The royal seal, representing the endurance of the Empire. It smells faintly of lavender and safety.")
		if(dismantle_in_progress)
			. += span_warning("It's trembling... someone is trying to destroy it!")
	else
		. += span_notice("You're not sure what this is, but it doesn't seem meant for you.")
		if(!dismantle_in_progress)
			. += span_notice("<b>Dismantle</b>: Click it to begin dismantling this seal.")

/obj/structure/royal_sanctuary/attack_hand(mob/living/user, list/modifiers)
	if(user == king_owner)
		if(!istype(user, /mob/living/carbon/monkey/plush/king))
			return
		open_management_console(user)
		return
	if(!user.client || istype(user, /mob/living/carbon/monkey/plush))
		return ..()
	if(dismantle_in_progress)
		balloon_alert(user, "already being dismantled")
		return
	dismantle_in_progress = TRUE
	current_dismantler = user
	dismantle_start_time = world.time
	to_chat(user, span_warning("You brace both hands against the Royal Seal and start tearing it apart. Stay adjacent and keep your hands on it!"))
	balloon_alert(user, "dismantling royal seal...")
	visible_message(span_warning("[user] braces against [src], trying to rip it apart!"))
	dismantle_feedback_tick()
	var/warning = span_boldnotice("<span style='color:#ff4444;'><b>&lt;&lt; PLUSHLINK &gt;&gt; ROYAL SEAL UNDER ATTACK:</b></span> <span style='color:#ffaaaa;'>Someone is tearing apart the seal! You don't have long to defend it!</span>")
	for(var/mob/living/carbon/monkey/plush/recipient in GLOB.player_list)
		if(QDELETED(recipient) || !recipient.client)
			continue
		to_chat(recipient, warning, type = MESSAGE_TYPE_RADIO)
	log_talk("[user.real_name] ([user.key]) is dismantling the Royal Plush Seal", LOG_GAME)
	if(!do_after(user, dismantle_duration, target = src, extra_checks = CALLBACK(src, PROC_REF(check_dismantle_valid), user)))
		dismantle_in_progress = FALSE
		current_dismantler = null
		dismantle_start_time = 0
		animate(src, color = "#FFD700", time = 1)
		balloon_alert(user, "Royal Seal Dismantling Interrupted!")
		to_chat(user, span_notice("You lose your grip on the seal and the dismantling stops."))
		var/interrupt_msg = span_boldnotice("<span style='color:#ffff88;'><b>&lt;&lt; PLUSHLINK &gt;&gt; SEAL THREAT ENDED:</b></span> <span style='color:#ffff88;'>The seal's attacker has been forced away or given up!</span>")
		for(var/mob/living/carbon/monkey/plush/recipient in GLOB.player_list)
			if(QDELETED(recipient) || !recipient.client)
				continue
			to_chat(recipient, interrupt_msg, type = MESSAGE_TYPE_RADIO)
		return
	complete_dismantle(user)

/obj/structure/royal_sanctuary/attack_paw(mob/living/user, list/modifiers)
	if(user == king_owner)
		if(!istype(user, /mob/living/carbon/monkey/plush/king))
			return ..()
		open_management_console(user)
		return
	return attack_hand(user, modifiers)

/obj/structure/royal_sanctuary/attackby(obj/item/weapon, mob/living/user, params)
	if(user == king_owner)
		if(!istype(user, /mob/living/carbon/monkey/plush/king))
			return ..()
		open_management_console(user)
		return
	return ..()

/obj/structure/royal_sanctuary/proc/check_dismantle_valid(mob/living/user)
	// Check if user is still adjacent and conscious
	if(!user || QDELETED(user) || user.stat != CONSCIOUS)
		return FALSE
	if(get_dist(user, src) > 1)
		return FALSE
	return TRUE

/obj/structure/royal_sanctuary/proc/dismantle_feedback_tick() // Adds some effects to the dismantling to INCREASE IMMERSION!!
	if(QDELETED(src) || !dismantle_in_progress)
		return

	var/elapsed = world.time - dismantle_start_time
	var/progress = clamp(elapsed / dismantle_duration, 0, 1)
	var/shake_force = 2 + round(progress * 6)

	Shake(shake_force, 1 + round(progress * 2), 4 + round(progress * 6))
	if(prob(25 + round(progress * 45)))
		do_sparks(1 + (progress >= 0.5 ? 1 : 0), FALSE, src)
		playsound(src, "sparks", 25, TRUE) // Spark effect
	animate(src, color = "#ffb3b3", time = 2)
	animate(src, color = "#FFD700", time = 2)

	if(current_dismantler && !QDELETED(current_dismantler)) // Text lines
		if(progress >= 0.75)
			balloon_alert(current_dismantler, "seal almost gone!")
		else if(progress >= 0.40)
			balloon_alert(current_dismantler, "keep going...")
		else
			balloon_alert(current_dismantler, "tearing at the seal...")

	addtimer(CALLBACK(src, PROC_REF(dismantle_feedback_tick)), 5 SECONDS)

/obj/structure/royal_sanctuary/proc/complete_dismantle(mob/living/dismantler) // Makes the seal go BOOM, and everyone go SHAKE when dismatled, CC also go THANKE!
	if(QDELETED(src))
		return
	dismantle_in_progress = FALSE
	current_dismantler = null
	dismantle_start_time = 0
	var/turf/seal_turf = get_turf(src)
	var/seal_z = null
	if(seal_turf)
		seal_z = seal_turf.z
	explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 3, flash_range = 5, adminlog = FALSE)
	playsound(seal_turf, 'sound/effects/explosion1.ogg', 100, TRUE, -1)
	for(var/mob/M in GLOB.player_list)
		if(!M || !M.client)
			continue
		var/turf/mob_turf = get_turf(M)
		if(mob_turf && mob_turf.z == seal_z)
			shake_camera(M, 8, 2)
	priority_announce(
		"Central Command confirms unauthorized territorial takeover activity aboard [station_name()] has abruptly ceased. Corporate assets are once again under Nanotrasen control. Command commends the crew for the restoration of station assets.",
		"NT Asset Protection Alert",
		SSstation.announcer.get_rand_alert_sound(),
		ANNOUNCEMENT_TYPE_PRIORITY,
	)
	var/final_warning = span_boldnotice("<span style='color:#ff4444;'><b>&lt;&lt; PLUSHLINK &gt;&gt; SEAL DESTROYED:</b></span> <span style='color:#ffaaaa;'>The Royal Seal has been destroyed, the empire with it... </span>")
	for(var/mob/living/carbon/monkey/plush/recipient in GLOB.player_list)
		if(QDELETED(recipient) || !recipient.client)
			continue
		to_chat(recipient, final_warning, type = MESSAGE_TYPE_RADIO)
	if(dismantler)
		log_talk("[dismantler.real_name] ([dismantler.key]) successfully dismantled the Royal Plush Seal", LOG_GAME)
	qdel(src)

/obj/structure/royal_sanctuary/proc/count_claimed_areas()
	return length(get_claimed_areas())

/obj/structure/royal_sanctuary/proc/get_claimed_areas()
	var/list/areas = list()
	for(var/turf/T in claimed_turfs)
		var/area/A = get_area(T)
		if(A && !(A in areas))
			areas += A
	return areas

/obj/structure/royal_sanctuary/proc/open_management_console(mob/living/carbon/monkey/plush/king/user)
	if(QDELETED(src) || QDELETED(user) || user != king_owner)
		return

	var/summons_state = "ready"
	if(world.time < next_royal_summons)
		var/time_left = round((next_royal_summons - world.time) / 10, 0.1)
		summons_state = "[time_left]s"
	var/summons_option = "Royal Summons ([summons_state])"
	var/manual_relocation_option = manual_relocation_option_text()

	var/list/options = list( // Seal menu options
		war_mode_option_text(),
		"Relocate Seal to Claimed Area",
		manual_relocation_option,
		summons_option,
		"Remove Claimed Area",
		"Dismantle Entire Court",
		"View Court Summary",
		"Cancel"
	)
	var/choice = tgui_input_list(user, "Issue a command for your Royal Court.", "Court Seal", options)
	if(!choice || QDELETED(src) || QDELETED(user) || user != king_owner)
		return

	if(choice == "Relocate Seal to Claimed Area")
		relocate_seal_to_claimed_area(user)
		return
	if(choice == manual_relocation_option)
		toggle_manual_relocation(user)
		return
	if(choice == war_mode_option_text())
		toggle_war_mode(user)
		return
	if(choice == summons_option)
		trigger_royal_summons(user)
		return
	if(choice == "Remove Claimed Area")
		remove_claimed_area_menu(user)
		return
	if(choice == "Dismantle Entire Court") // THE RULER HAS SPOKEN, DOWN WITH THE COURT!!
		if(tgui_alert(user, "Dismantle your Royal Court? This removes all claimed territory and deletes the seal.", "Dismantle Court", list("Yes", "No")) == "Yes")
			user.broadcast_plushlink("By royal decree, the Court is withdrawn. Let every thread stand down.")
			qdel(src)
		return
	if(choice == "View Court Summary") // Displays claimed tiles, claimed areas, and living plush totals, then the wellbeing of every individual plush
		var/list/claimed_areas = get_claimed_areas()
		var/living_plush_count = 0
		for(var/mob/living/carbon/monkey/plush/plush_subject in GLOB.player_list)
			if(QDELETED(plush_subject) || plush_subject.stat == DEAD)
				continue
			living_plush_count++
		to_chat(user, "<span style='color:#FFD700;'><b>— Court Summary —</b></span>")
		to_chat(user, span_notice("Territory: <b>[length(claimed_turfs)]</b> tiles across <b>[length(claimed_areas)]</b> area[length(claimed_areas) == 1 ? "" : "s"]"))
		to_chat(user, span_notice("Subjects: <b>[living_plush_count]</b> plush [living_plush_count == 1 ? "subject" : "subjects"] alive"))
		user.broadcast_census()
		return
	return

/obj/structure/royal_sanctuary/proc/trigger_royal_summons(mob/living/carbon/monkey/plush/king/user)
	if(QDELETED(src) || QDELETED(user) || user != king_owner)
		return
	if(world.time < next_royal_summons)
		var/time_left = round((next_royal_summons - world.time) / 10, 0.1)
		balloon_alert(user, "summons cooling down")
		to_chat(user, span_warning("Royal Summons will be ready in [time_left] seconds."))
		return
	if(!user.summon_subject_to_seal())
		return
	next_royal_summons = world.time + royal_summons_cooldown

/obj/structure/royal_sanctuary/proc/war_mode_option_text()
	var/state_label = war_mode_active ? "active" : "inactive"
	if(world.time < next_war_toggle)
		var/time_left = round((next_war_toggle - world.time) / 10, 0.1)
		return "Declare War Protocol ([state_label], [time_left]s cd)"
	return "Declare War Protocol ([state_label], ready)"

/obj/structure/royal_sanctuary/proc/play_war_protocol_alert_sound()
	if(!war_protocol_alert_sound)
		return
	for(var/mob/player in GLOB.player_list)
		if(QDELETED(player) || !player.client)
			continue
		SEND_SOUND(player, sound(war_protocol_alert_sound, volume = 40))

/obj/structure/royal_sanctuary/proc/toggle_war_mode(mob/living/carbon/monkey/plush/king/user)
	if(QDELETED(src) || QDELETED(user) || user != king_owner)
		return
	if(world.time < next_war_toggle)
		var/time_left = round((next_war_toggle - world.time) / 10, 0.1)
		balloon_alert(user, "war protocol cooling down")
		to_chat(user, span_warning("War protocol can be toggled again in [time_left] seconds."))
		return

	war_mode_active = !war_mode_active
	next_war_toggle = world.time + war_toggle_cooldown
	refresh_aura()
	if(war_mode_active)
		stop_hover_animation()
		animate(src, color = "#ff6666", time = 2)
		user.broadcast_plushlink("By order of the Emperor, war is declared! Let those who oppose the cotton tremble!") // Wartime start message
		play_war_protocol_alert_sound()
		check_war_hazard_notification()
	else
		animate(src, color = "#FFD700", time = 2)
		addtimer(CALLBACK(src, PROC_REF(start_hover_animation)), 2 SECONDS)
		clear_war_effects()
		user.broadcast_plushlink("By order of the Emperor, hostilities are lifted, and the war is over. Hold the Court, but stay vigilant.") // wartime end message
	balloon_alert(user, war_mode_active ? "war protocol active" : "war protocol inactive")

/obj/structure/royal_sanctuary/proc/check_war_hazard_notification()
	if(war_hazard_notification_sent)
		return

	war_hazard_notification_sent = TRUE
	minor_announce("Readings from [station_name()] indicate dangerous territorial signals. Crew entering the affected zone may experience severe physical impairment. Ensure all commands from Heads of Staff are followed.", "Central Command Hazard Alert")

/obj/structure/royal_sanctuary/proc/clear_war_effects()
	for(var/mob/living/carbon/intruder in GLOB.player_list)
		if(QDELETED(intruder))
			continue
		intruder.remove_status_effect(/datum/status_effect/royal_court_trespass)
		intruder.remove_status_effect(/datum/status_effect/royal_court_hostile)
		intruder.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/royal_court_trespass)
		intruder.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/royal_court_hostile)
	war_entry_warning_cooldown.Cut()
	claimed_turf_presence.Cut()
	plush_turf_presence.Cut()

/obj/structure/royal_sanctuary/proc/manual_relocation_option_text()
	if(!manual_relocation_active)
		return "Temporarily Unanchor Seal"
	var/time_left = max(0, round((manual_relocation_end_time - world.time) / 10, 0.1))
	return "Finish Manual Reposition ([time_left]s)"

/obj/structure/royal_sanctuary/proc/is_valid_seal_anchor_turf(turf/T)
	if(!istype(T, /turf/open))
		return FALSE
	if(!(T in claimed_turfs))
		return FALSE
	if(T.density || T.is_blocked_turf())
		return FALSE
	return TRUE

/obj/structure/royal_sanctuary/proc/find_best_seal_anchor_turf(area/preferred_area = null, turf/reference_turf = null)
	var/turf/best_anchor
	var/best_dist = INFINITY
	for(var/turf/T in claimed_turfs)
		if(preferred_area && get_area(T) != preferred_area)
			continue
		if(!is_valid_seal_anchor_turf(T))
			continue
		var/d = reference_turf ? get_dist(T, reference_turf) : 0
		if(d < best_dist)
			best_dist = d
			best_anchor = T
	return best_anchor

/obj/structure/royal_sanctuary/proc/toggle_manual_relocation(mob/living/carbon/monkey/plush/king/user)
	if(QDELETED(src) || QDELETED(user) || user != king_owner)
		return
	if(manual_relocation_active)
		finish_manual_relocation(user)
		return
	manual_relocation_active = TRUE
	manual_relocation_end_time = world.time + manual_relocation_duration
	anchored = FALSE
	balloon_alert(user, "seal unanchored")
	to_chat(user, span_notice("The Court Seal can now be pulled for [round(manual_relocation_duration / 10)] seconds. Use the seal menu again to lock it in early."))
	addtimer(CALLBACK(src, PROC_REF(finish_manual_relocation)), manual_relocation_duration)

/obj/structure/royal_sanctuary/proc/finish_manual_relocation(mob/living/carbon/monkey/plush/king/user) // Manually Moving the seal stuff
	if(QDELETED(src) || !manual_relocation_active)
		return
	manual_relocation_active = FALSE
	manual_relocation_end_time = 0

	var/turf/current_turf = get_turf(src)
	var/area/current_area = current_turf ? get_area(current_turf) : null
	var/turf/final_anchor = find_best_seal_anchor_turf(current_area, current_turf)
	if(!final_anchor)
		final_anchor = find_best_seal_anchor_turf(null, current_turf)
	if(final_anchor && final_anchor != current_turf)
		forceMove(final_anchor)
	anchored = TRUE
	if(user && !QDELETED(user))
		if(final_anchor)
			balloon_alert(user, "seal position locked")
		else
			balloon_alert(user, "no valid turf found")

/obj/structure/royal_sanctuary/proc/relocate_seal_to_claimed_area(mob/living/carbon/monkey/plush/king/user) // Relocate Seal Stuff
	if(QDELETED(src) || QDELETED(user) || user != king_owner)
		return

	var/list/claimed_areas = get_claimed_areas()
	if(!length(claimed_areas))
		balloon_alert(user, "no claimed areas")
		return

	var/area/current_seal_area = get_area(src)
	var/list/area_options = list()
	var/list/option_to_area = list()
	var/index = 1
	for(var/area/A in claimed_areas)
		if(A == current_seal_area)
			continue
		var/option_label = "#[index] [A.name]"
		area_options += option_label
		option_to_area[option_label] = A
		index++

	if(!length(area_options))
		balloon_alert(user, "no alternate area")
		to_chat(user, span_warning("You need at least one other claimed area to relocate the seal."))
		return

	var/chosen_option = tgui_input_list(user, "Select a claimed area to move the Court Seal into.", "Relocate Seal", area_options)
	if(!chosen_option || QDELETED(src) || QDELETED(user) || user != king_owner)
		return

	var/area/chosen_area = option_to_area[chosen_option]
	if(!chosen_area)
		return

	var/turf/user_turf = get_turf(user)
	var/turf/new_anchor = find_best_seal_anchor_turf(chosen_area, user_turf)

	if(!new_anchor)
		balloon_alert(user, "no valid anchor turf")
		to_chat(user, span_warning("That claimed area lacks an open floor for the seal. Use the manual reposition option if you need to pull it into place."))
		return

	balloon_alert(user, "relocating seal...")
	user.start_royal_chant_effects()
	user.emit_royal_claim_chant("By royal decree, the Court's heart shall now move.") // Chant done when relocating
	if(!do_after(user, 6 SECONDS, target = user))
		user.end_royal_chant_effects()
		balloon_alert(user, "relocation interrupted")
		return
	user.end_royal_chant_effects()

	if(QDELETED(src) || QDELETED(user) || user != king_owner)
		return
	if(!is_valid_seal_anchor_turf(new_anchor))
		balloon_alert(user, "target no longer claimed")
		return

	var/area/old_area = get_area(src)
	var/area/new_area = get_area(new_anchor)
	forceMove(new_anchor)
	refresh_aura()
	user.broadcast_plushlink("By royal decree, the Court Seal is reassigned from [old_area?.name || "unknown"] to [new_area?.name || "unknown"].") // Plushlink broadcast mentioning new seal location
	balloon_alert(user, "seal relocated")

/obj/structure/royal_sanctuary/proc/remove_claimed_area_menu(mob/living/carbon/monkey/plush/king/user) // Remove area stuff
	if(QDELETED(src) || QDELETED(user) || user != king_owner)
		return

	var/list/claimed_areas = get_claimed_areas()
	if(!length(claimed_areas))
		balloon_alert(user, "no claimed areas")
		return

	var/list/area_options = list()
	var/list/option_to_area = list()
	var/index = 1
	for(var/area/A in claimed_areas)
		var/option_label = "#[index] [A.name]"
		area_options += option_label
		option_to_area[option_label] = A
		index++

	var/chosen_option = tgui_input_list(user, "Select an area to remove from the Royal Court.", "Remove Claimed Area", area_options)
	if(!chosen_option || QDELETED(src) || QDELETED(user) || user != king_owner)
		return

	var/area/chosen_area = option_to_area[chosen_option]
	if(!chosen_area)
		return

	var/turf/seal_turf = get_turf(src)
	var/area/seal_area = seal_turf ? get_area(seal_turf) : null
	if(chosen_area == seal_area)
		balloon_alert(user, "cannot remove seal area")
		to_chat(user, span_warning("The Court Seal must remain anchored to claimed territory. Dismantle and re-establish the court to move its anchor room."))
		return

	if(tgui_alert(user, "Remove [chosen_area.name] from your claimed court?", "Confirm Area Removal", list("Remove", "Cancel")) != "Remove")
		return

	for(var/turf/T in claimed_turfs.Copy())
		if(get_area(T) == chosen_area)
			claimed_turfs -= T

	refresh_aura()
	user.broadcast_plushlink("By royal decree, [chosen_area.name] is released from the Court's claim.")
	balloon_alert(user, "area removed")

/obj/structure/royal_sanctuary/proc/check_command_notification() // CC Message Code for when Court Size is too big
	if(command_notification_sent)
		return
	if(count_claimed_areas() < command_notification_area_threshold)
		return

	command_notification_sent = TRUE
	minor_announce("Automated sensors have flagged unauthorized territorial takeover activity aboard [station_name()]. Central Command has been notified of corporate asset devaluation.", "NT Asset Protection Alert")

/obj/structure/royal_sanctuary/proc/start_regen_loop() // Healing for the Plush People!!
	if(regen_active)
		return
	regen_active = TRUE
	next_regen_pulse = world.time
	START_PROCESSING(SSfastprocess, src)

/obj/structure/royal_sanctuary/process(delta_time)
	if(!regen_active)
		return PROCESS_KILL
	if(QDELETED(king_owner) || king_owner.stat == DEAD)
		qdel(src)
		return PROCESS_KILL
	if(world.time < next_regen_pulse)
		return

	next_regen_pulse = world.time + regen_tick_rate

	var/turf/seal_turf = get_turf(src)
	for(var/mob/living/carbon/monkey/plush/plush_mob in GLOB.player_list)
		if(QDELETED(plush_mob) || !plush_mob.client)
			continue
		if(plush_mob.stat == DEAD)
			continue

		var/turf/plush_turf = get_turf(plush_mob)
		var/in_claimed_plush_turf = plush_turf && (plush_turf in claimed_turfs)
		var/plush_notified_key = plush_mob.ckey
		var/plush_was_in_claimed_turf = plush_notified_key ? !!plush_turf_presence[plush_notified_key] : FALSE
		if(plush_notified_key)
			if(in_claimed_plush_turf)
				plush_turf_presence[plush_notified_key] = TRUE
			else
				plush_turf_presence -= plush_notified_key
		if(in_claimed_plush_turf && plush_notified_key && !plush_was_in_claimed_turf)
			to_chat(plush_mob, span_notice("You feel at home here. The Court welcomes you.")) //message plush get when entering claimed areas

		if(plush_mob.plush_form)
			continue

		if(!plush_turf || !(plush_turf in claimed_turfs))
			continue
		if(!plush_mob.getBruteLoss() && !plush_mob.getFireLoss() && !plush_mob.getToxLoss() && !plush_mob.getOxyLoss() \
			&& !(istype(plush_mob, /mob/living/carbon) && plush_mob.is_bleeding()) \
			&& !(istype(plush_mob, /mob/living/carbon) && plush_mob.blood_volume < BLOOD_VOLUME_NORMAL))
			continue
		if(istype(plush_mob, /mob/living/carbon/monkey/plush/king) && plush_mob:cocoon_active)
			continue

		var/heal_amount
		var/is_emperor = istype(plush_mob, /mob/living/carbon/monkey/plush/king)
		var/is_inner_range = seal_turf && get_dist(plush_turf, seal_turf) <= inner_regen_range
		if(is_emperor)
			heal_amount = is_inner_range ? inner_king_heal : outer_king_heal
		else
			heal_amount = is_inner_range ? inner_plush_heal : outer_plush_heal
		var/heal_multiplier = peace_heal_multiplier
		if(war_mode_active && !is_emperor)
			heal_multiplier = war_heal_multiplier
		heal_amount = round(heal_amount * heal_multiplier, 0.1)

		var/need_mob_update = FALSE
		need_mob_update += plush_mob.adjustBruteLoss(-heal_amount, updating_health = FALSE)
		need_mob_update += plush_mob.adjustFireLoss(-heal_amount, updating_health = FALSE)
		need_mob_update += plush_mob.adjustToxLoss(-heal_amount, updating_health = FALSE)
		need_mob_update += plush_mob.adjustOxyLoss(-heal_amount, updating_health = FALSE)
		if(istype(plush_mob, /mob/living/carbon) && plush_mob.is_bleeding()) // Stops Bleeding!
			plush_mob.cauterise_wounds(heal_amount * 0.5)
			need_mob_update = TRUE
		if(istype(plush_mob, /mob/living/carbon) && plush_mob.blood_volume < BLOOD_VOLUME_NORMAL) // Restores Blood!
			plush_mob.blood_volume = min(plush_mob.blood_volume + heal_amount, BLOOD_VOLUME_NORMAL)
			need_mob_update = TRUE
		if(need_mob_update)
			plush_mob.updatehealth()
			plush_mob.apply_status_effect(/datum/status_effect/royal_court_regen)
		if(war_mode_active)
			plush_mob.adjustStaminaLoss(-2)

	for(var/mob/living/carbon/intruder in GLOB.player_list)
		if(QDELETED(intruder) || !intruder.client || intruder.stat == DEAD)
			continue
		if(istype(intruder, /mob/living/carbon/monkey/plush))
			continue

		var/turf/intruder_turf = get_turf(intruder)
		var/in_claimed_turf = intruder_turf && (intruder_turf in claimed_turfs)
		var/notified_key = intruder.ckey
		var/was_in_claimed_turf = notified_key ? !!claimed_turf_presence[notified_key] : FALSE
		if(notified_key)
			if(in_claimed_turf)
				claimed_turf_presence[notified_key] = TRUE
			else
				claimed_turf_presence -= notified_key

		if(war_mode_active && in_claimed_turf) // TREASONIST ON THE ROYAL GROUNDS!!
			if(notified_key && !was_in_claimed_turf)
				var/next_warning_time = war_entry_warning_cooldown[notified_key] || 0
				if(world.time >= next_warning_time)
					war_entry_warning_cooldown[notified_key] = world.time + war_entry_warning_interval
					to_chat(intruder, span_userdanger("The air turns hostile. Your body feels heavy and your movements are suppressed.")) // Message non-plush get when entering claimed areas during WARTIME!!
					if(war_entry_alert_sound)
						SEND_SOUND(intruder, sound(war_entry_alert_sound, volume = war_entry_alert_volume))
			intruder.remove_status_effect(/datum/status_effect/royal_court_trespass)
			intruder.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/royal_court_trespass)
			intruder.apply_status_effect(/datum/status_effect/royal_court_hostile)
			continue

		if(in_claimed_turf) // Peaceful tresspassing
			if(notified_key && !was_in_claimed_turf)
				var/next_peace_warning_time = war_entry_warning_cooldown[notified_key] || 0
				if(world.time >= next_peace_warning_time)
					war_entry_warning_cooldown[notified_key] = world.time + war_entry_warning_interval
					to_chat(intruder, span_warning("You feel out of place here. This land no longer belongs to you.")) // Message non-plush get when entering claimed area during PEACE time!
			intruder.remove_status_effect(/datum/status_effect/royal_court_hostile)
			intruder.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/royal_court_hostile)
			intruder.remove_status_effect(/datum/status_effect/royal_court_trespass)
			intruder.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/royal_court_trespass)
			continue

		intruder.remove_status_effect(/datum/status_effect/royal_court_trespass)
		intruder.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/royal_court_trespass)
		intruder.remove_status_effect(/datum/status_effect/royal_court_hostile)
		intruder.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/royal_court_hostile)

/obj/structure/royal_sanctuary/proc/refresh_aura() // Makes the claimed area glow BOLDER, and ANGIER when Wartime is a go!
	// Update peak stats on the team whenever territory changes
	if(king_owner?.mind)
		var/datum/antagonist/plush_monkey/antag_datum = king_owner.mind.has_antag_datum(/datum/antagonist/plush_monkey)
		if(!antag_datum)
			var/datum/antagonist/plush_king/king_datum = king_owner.mind.has_antag_datum(/datum/antagonist/plush_king)
			if(king_datum?.plush_team)
				king_datum.plush_team.update_peak_stats()
		else if(antag_datum?.plush_team)
			antag_datum.plush_team.update_peak_stats()
	dismiss_aura()
	var/turf/seal_turf = get_turf(src)
	var/aura_color = war_mode_active ? "#ff6666" : "#FFD700"
	var/aura_alpha = war_mode_active ? 75 : 35
	for(var/turf/T in claimed_turfs)
		if(T == seal_turf)
			continue
		var/obj/effect/royal_sanctuary_aura/aura = new(T)
		aura.color = aura_color
		aura.alpha = aura_alpha
		aura_effects += aura

/obj/structure/royal_sanctuary/proc/dismiss_aura() // aura goes with the seal
	for(var/obj/effect/royal_sanctuary_aura/aura in aura_effects)
		if(!QDELETED(aura))
			qdel(aura)
	aura_effects.Cut()

// - SubSpecies for the ROYAL EMPEROR BOW BEFORE THEIR COTTON PRESENCE!!! -

/mob/living/carbon/monkey/plush/king
	name = "Plush Emperor"
	desc = "A plushie with an unmistakably regal bearing."
	chat_color = "#FFD700"
	var/obj/structure/royal_sanctuary/active_sanctuary
	var/cocoon_active = FALSE // Upon getting lethal damage they enter a cocoon state that revies them over time with this var tracking it
	var/cocoon_end_time = 0
	var/cocoon_duration = 30 SECONDS // Duration for the resurrection cocoon
	var/mutable_appearance/cocoon_overlay // Overlay for their healing cocoon!
	var/mutable_appearance/royal_chant_glow // Overlay for their royal chants!
	var/datum/action/innate/plush_monkey_return_to_seal/return_to_seal_action // Teleport back to seal!
	var/datum/action/innate/plush_monkey_knighthood/knighthood_action // Grants knighthood to a nearby subject
	var/datum/action/innate/plush_monkey_sanctuary/sanctuary_action // Creates THE ROYAL SEAL!!!!!!!
	var/datum/action/innate/plush_monkey_expand_court/expand_court_action // Appears after the seal is placed- And claims an area the ruler occupies!

/mob/living/carbon/monkey/plush/king/Initialize(mapload, cubespawned, mob/spawner)
	. = ..()
	knighted = TRUE // uses the knighthood title system for their royal status, but is BORN WITH ROYAL THREAD IN THEIR SEAMS!
	knight_title = "EMPEROR" // The Royal Title!
	if(findtext(real_name, "(EMPEROR) ") != 1)
		real_name = "(EMPEROR) [real_name]"
		name = real_name
		normal_name = name
		normal_real_name = real_name
	apply_plush_form(/obj/item/toy/plush/ian) // The royal form is EXCLUSIVELY the ian plush but could be changed to anything!
	return_to_seal_action = new()
	knighthood_action = new()
	knighthood_action.Grant(src)
	sanctuary_action = new()
	sanctuary_action.Grant(src)
	expand_court_action = new()

/mob/living/carbon/monkey/plush/king/update_damage_hud()
	if(cocoon_active)
		if(!client)
			return
		clear_fullscreen("crit", 0)
		clear_fullscreen("critvision", 0)
		clear_fullscreen("oxy", 0)
		clear_fullscreen("brute", 0)
		overlay_fullscreen("plush_cocoon", /atom/movable/screen/fullscreen/crit, 1)
		return

	clear_fullscreen("plush_cocoon", 0)
	return ..()

/mob/living/carbon/monkey/plush/king/set_health(new_value)
	. = ..()
	if(. > hardcrit_threshold && health <= hardcrit_threshold && !cocoon_active && stat != DEAD)
		try_enter_cocoon()

/mob/living/carbon/monkey/plush/king/Destroy() // rip the royal
	QDEL_NULL(return_to_seal_action)
	QDEL_NULL(knighthood_action)
	QDEL_NULL(sanctuary_action)
	QDEL_NULL(expand_court_action)
	clear_fullscreen("plush_cocoon", 0)
	if(cocoon_overlay)
		cut_overlay(cocoon_overlay)
		cocoon_overlay = null
	REMOVE_TRAIT(src, TRAIT_GODMODE, "plush_king_cocoon")
	REMOVE_TRAIT(src, TRAIT_NODEATH, "plush_king_cocoon")
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "plush_king_cocoon")
	REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, "plush_king_cocoon")
	cocoon_active = FALSE
	cocoon_end_time = 0
	if(active_sanctuary && !QDELETED(active_sanctuary))
		qdel(active_sanctuary)
	active_sanctuary = null
	return ..()

/mob/living/carbon/monkey/plush/king/death(gibbed)
	if(try_enter_cocoon())
		return FALSE
	return ..()

/mob/living/carbon/monkey/plush/king/gib(no_brain, no_organs, no_bodyparts)
	if(try_enter_cocoon())
		return
	return ..()

/mob/living/carbon/monkey/plush/king/dust(just_ash, drop_items, force)
	if(try_enter_cocoon())
		return
	return ..()

/mob/living/carbon/monkey/plush/king/proc/has_active_court_seal()
	return active_sanctuary && !QDELETED(active_sanctuary)

/mob/living/carbon/monkey/plush/king/proc/try_enter_cocoon()
	if(cocoon_active || stat == DEAD)
		return FALSE
	if(!has_active_court_seal())
		return FALSE

	cocoon_active = TRUE
	cocoon_end_time = world.time + cocoon_duration

	if(!cocoon_overlay)
		cocoon_overlay = mutable_appearance('icons/obj/storage/wrapping.dmi', "giftdeliverypackage5") // The icon for the cocoon overlay
	add_overlay(cocoon_overlay)

	ADD_TRAIT(src, TRAIT_GODMODE, "plush_king_cocoon")
	ADD_TRAIT(src, TRAIT_NODEATH, "plush_king_cocoon")
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, "plush_king_cocoon")
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, "plush_king_cocoon")

	set_stat(UNCONSCIOUS)
	updatehealth()

	broadcast_plushlink("The Emperor is under attack and has entered a regenerative state, protect the court seal so they can re-emerge!") // Plushlink message when the king enters a cocoon state
	to_chat(src, span_boldnotice("You are protected by the Court Seal. Remain cocooned until you're sewn back together.")) // Message for the royal when they enter the cocoon state
	addtimer(CALLBACK(src, PROC_REF(resolve_cocoon_state)), cocoon_duration)
	return TRUE

/mob/living/carbon/monkey/plush/king/proc/resolve_cocoon_state()
	if(QDELETED(src) || !cocoon_active)
		return

	cocoon_active = FALSE
	cocoon_end_time = 0
	if(cocoon_overlay)
		cut_overlay(cocoon_overlay)

	REMOVE_TRAIT(src, TRAIT_GODMODE, "plush_king_cocoon")
	REMOVE_TRAIT(src, TRAIT_NODEATH, "plush_king_cocoon")
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "plush_king_cocoon")
	REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, "plush_king_cocoon")
	update_damage_hud()

	if(has_active_court_seal())
		fully_heal(HEAL_ALL)
		set_stat(CONSCIOUS)
		updatehealth()
		broadcast_plushlink("Stitched back together! The Emperor emerges from the cocoon, fully restored and ready to rule once more!") // Message to alleviate the concern of the subjects, letting them know the ruler is reborn
		to_chat(src, span_notice("The cocoon opens and your body is fully restored.")) // Royals message for when they exit da cocoon
		return

	to_chat(src, span_userdanger("Your cocoon unravels without a Court Seal to sustain it!")) // Without a seal they cannot revive and as such...
	death(FALSE)

/mob/living/carbon/monkey/plush/king/proc/summon_subject_to_seal() // Code for the royal to summon peasants to the seal
	if(!active_sanctuary || QDELETED(active_sanctuary))
		active_sanctuary = null
		balloon_alert(src, "no court established")
		return FALSE

	var/turf/seal_turf = get_turf(active_sanctuary)
	if(!seal_turf)
		balloon_alert(src, "seal location invalid")
		return FALSE

	var/list/subject_options = list()
	var/list/option_to_subject = list()
	var/index = 1
	for(var/mob/living/carbon/monkey/plush/subject in GLOB.player_list)
		if(QDELETED(subject) || !subject.client || subject.stat == DEAD || subject == src)
			continue
		var/area/subject_area = get_area(subject)
		var/area_name = subject_area ? subject_area.name : "unknown area"
		var/option_label = "#[index] [subject.get_plush_display_name()] ([area_name])"
		subject_options += option_label
		option_to_subject[option_label] = subject
		index++

	if(!length(subject_options))
		balloon_alert(src, "no subjects to summon")
		return FALSE

	var/chosen_option = tgui_input_list(src, "Select a plush subject to summon to the Court Seal.", "Royal Summons", subject_options)
	if(!chosen_option || stat != CONSCIOUS)
		return FALSE

	var/mob/living/carbon/monkey/plush/chosen_subject = option_to_subject[chosen_option]
	if(!istype(chosen_subject) || QDELETED(chosen_subject) || chosen_subject.stat == DEAD)
		balloon_alert(src, "subject unavailable")
		return FALSE

	chosen_subject.forceMove(seal_turf)
	playsound(chosen_subject, pick_weight(plush_squeak_sounds), 40, TRUE)
	to_chat(chosen_subject, span_boldnotice("A royal summons pulls you to the Court Seal!"))
	broadcast_plushlink("By royal decree, [chosen_subject.get_plush_display_name()] has been summoned to the Royal Court.")
	balloon_alert(src, "subject summoned")
	return TRUE

/mob/living/carbon/monkey/plush/king/proc/return_to_court_seal() // Return to royal seal code stuff
	if(!active_sanctuary || QDELETED(active_sanctuary))
		active_sanctuary = null
		balloon_alert(src, "no court established")
		return FALSE

	var/turf/seal_turf = get_turf(active_sanctuary)
	if(!seal_turf)
		balloon_alert(src, "seal location invalid")
		return FALSE

	if(get_turf(src) == seal_turf)
		balloon_alert(src, "already at seal")
		return FALSE

	balloon_alert(src, "chanting return")
	start_royal_chant_effects()
	emit_royal_claim_chant(pick(
		"By power vested within my royal cotton, the court summons me.",
		"The throne calls, and I answer. The court will have its sovereign.",
		"Where the court rests, the throne endures. I am summoned by my own decree.",
		"By royal will and royal thread, I am called to where I belong.",
		"Distance bows to the crown. I begin my return.",
	))
	if(!do_after(src, 5 SECONDS, target = src))
		end_royal_chant_effects()
		balloon_alert(src, "chant interrupted")
		return FALSE
	end_royal_chant_effects()

	if(!active_sanctuary || QDELETED(active_sanctuary))
		active_sanctuary = null
		balloon_alert(src, "court lost")
		return FALSE

	seal_turf = get_turf(active_sanctuary)
	if(!seal_turf)
		balloon_alert(src, "seal location invalid")
		return FALSE

	forceMove(seal_turf)
	to_chat(src, span_notice("Royal thread weaves around you, returning you to the Royal Court."))
	balloon_alert(src, "returned to court")
	return TRUE

/mob/living/carbon/monkey/plush/king/broadcast_plushlink(message) // Different message for the royal
	var/header = "<span style='color:#FFD700;'><b>&lt;&lt; ROYAL DECREE &gt;&gt; [get_plush_display_name()]:</b></span>"
	var/body = "<span style='color:#fff0a0;'>[message]</span>"
	var/rendered_message = span_boldnotice("[header] [body]")
	for(var/mob/living/carbon/monkey/plush/recipient in GLOB.player_list)
		if(QDELETED(recipient) || !recipient.client)
			continue
		to_chat(recipient, rendered_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = recipient == src)
		if(recipient != src)
			playsound(recipient, pick_weight(plush_squeak_sounds), 30, TRUE)
	log_talk(message, LOG_SAY, tag = "plushlink")

/mob/living/carbon/monkey/plush/king/proc/broadcast_census() // Creates a census of the royal subjects their wellbeing, and location
	if(!mind)
		balloon_alert(src, "no kingdom found")
		return
	var/datum/antagonist/plush_monkey/antag_datum = mind.has_antag_datum(/datum/antagonist/plush_monkey)
	var/datum/team/plush_monkey/team = antag_datum?.plush_team
	if(!team)
		var/datum/antagonist/plush_king/king_antag = mind.has_antag_datum(/datum/antagonist/plush_king)
		team = king_antag?.plush_team
	if(!team)
		balloon_alert(src, "no kingdom found")
		return
	var/list/report_lines = list("<b>&lt;&lt; IMPERIAL CENSUS &gt;&gt;</b>") // Header for the census detailing the plush species wellbeing

	for(var/datum/mind/member in team.members)
		var/mob/living/carbon/monkey/plush/subject = member.current
		if(!istype(subject))
			report_lines += "<span style='color:#999;'>• [member.name] — whereabouts unknown</span>"
			continue
		var/hp_pct = round((subject.health / subject.maxHealth) * 100)
		var/area/subject_area = get_area(subject)
		var/area_name = subject_area ? subject_area.name : "unknown area"
		var/hp_color = hp_pct >= 75 ? "#88ff88" : (hp_pct >= 35 ? "#ffdd55" : "#ff6666")
		report_lines += "<span style='color:[hp_color];'>• [subject.get_plush_display_name()] — [hp_pct]% HP, [area_name]</span>"

	to_chat(src, jointext(report_lines, "\n"), type = MESSAGE_TYPE_RADIO)

/mob/living/carbon/monkey/plush/king/proc/bestow_knighthood() // Knighthood ability code
	var/list/candidates = list()
	for(var/mob/living/carbon/monkey/plush/nearby in range(2, src)) // Only subjects within this range are eligble to be knighted
		if(nearby == src || nearby.knighted)
			continue
		candidates += nearby

	if(!length(candidates))
		balloon_alert(src, "no eligible subjects nearby") // No one nearby or eligble message
		return FALSE

	var/list/candidate_names = list()
	var/list/candidate_map = list()
	for(var/mob/living/carbon/monkey/plush/candidate in candidates)
		candidate_names += candidate.real_name
		candidate_map[candidate.real_name] = candidate

	var/chosen_name = tgui_input_list(src, "Who do you wish to knight?", "Bestow Knighthood", candidate_names)
	if(!chosen_name || stat != CONSCIOUS)
		return FALSE

	var/mob/living/carbon/monkey/plush/subject = candidate_map[chosen_name]
	if(!subject || QDELETED(subject) || subject.knighted)
		balloon_alert(src, "no longer eligible")
		return FALSE

	var/title = tgui_input_text(src, "What title do you bestow upon [subject.real_name]?", "Knighthood Title", "KNIGHT", max_length = 30) // Input for the royal, they can choose any title with KNIGHT being the default
	if(!title || stat != CONSCIOUS)
		return FALSE
	title = sanitize(uppertext(title))
	if(!length(title))
		return FALSE
	var/original_name = subject.real_name
	var/titled_name = "([title]) [original_name]" // Places a title before the name

	subject.knighted = TRUE
	subject.knight_title = title
	subject.normal_name = titled_name
	subject.normal_real_name = titled_name
	if(!subject.plush_form)
		subject.name = titled_name
		subject.real_name = titled_name

	var/announcement_header = "<span style='color:#FFD700;'><b>&lt;&lt; ROYAL DECREE &gt;&gt; [real_name]:</b></span>"
	var/announcement_body = "<span style='color:#fff0a0;'>Let it be known, by royal decree — [original_name] is hereby bestowed the title of [title]!</span>" // Knighthood announcement
	var/announcement = span_boldnotice("[announcement_header] [announcement_body]")
	for(var/mob/living/carbon/monkey/plush/recipient in GLOB.player_list)
		if(QDELETED(recipient) || !recipient.client)
			continue
		to_chat(recipient, announcement, type = MESSAGE_TYPE_RADIO)
		if(recipient != src)
			playsound(recipient, pick_weight(plush_squeak_sounds), 30, TRUE)
	log_talk("Knighted [original_name] as [title]", LOG_SAY, tag = "plushlink")
	return TRUE

// - Court Placement -
/mob/living/carbon/monkey/plush/king/proc/use_royal_sanctuary()
	if(active_sanctuary && !QDELETED(active_sanctuary))
		balloon_alert(src, "court already established")
		return FALSE
	var/turf/T = get_turf(src)
	if(!T)
		balloon_alert(src, "no valid location")
		return FALSE

	balloon_alert(src, "establishing court...") // Chant- and Chant lines for establishing the court
	var/list/establishment_chants = list(
		"Here, in this space, I plant my crown.",
		"By the ancient thread of plush tradition, this court shall be founded.",
		"Let all of plushkind know — that this is OUR kingdom."
	)

	start_royal_chant_effects()
	emit_royal_claim_chant(establishment_chants[1])
	addtimer(CALLBACK(src, PROC_REF(emit_royal_claim_chant), establishment_chants[2]), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(emit_royal_claim_chant), establishment_chants[3]), 5 SECONDS)

	if(!do_after(src, 8 SECONDS, target = src))
		end_royal_chant_effects()
		balloon_alert(src, "court establishment interrupted")
		return FALSE
	end_royal_chant_effects()

	active_sanctuary = new /obj/structure/royal_sanctuary(T)
	active_sanctuary.king_owner = src
	// Register the sanctuary on the team for round-end reporting
	var/datum/antagonist/plush_king/king_datum = mind?.has_antag_datum(/datum/antagonist/plush_king)
	if(king_datum?.plush_team)
		king_datum.plush_team.team_sanctuary = active_sanctuary
	var/area/starting_area = get_area(src)
	if(starting_area && !istype(starting_area, /area/misc/space))
		for(var/turf/room_turf in starting_area)
			active_sanctuary.claimed_turfs += room_turf
	else
		active_sanctuary.claimed_turfs += T
	active_sanctuary.start_regen_loop()
	active_sanctuary.refresh_aura()
	var/area/court_area = get_area(T)
	active_sanctuary.check_command_notification()
	if(court_area && !istype(court_area, /area/misc/space))
		broadcast_plushlink("By royal decree, the Court Seal has been established in [court_area.name]!")
	else
		broadcast_plushlink("By royal decree, the Court Seal has been established!")
	if(return_to_seal_action?.owner != src)
		return_to_seal_action.Grant(src)
	if(expand_court_action?.owner != src)
		expand_court_action.Grant(src)
	balloon_alert(src, "court established")
	playsound(src, pick_weight(plush_squeak_sounds), 60, TRUE) // squeak
	return TRUE

/mob/living/carbon/monkey/plush/king/proc/emit_royal_claim_chant(line)
	if(QDELETED(src) || stat != CONSCIOUS || !HAS_TRAIT(src, PLUSH_KING_CHANT_TRAIT))
		return
	say(line, forced = "royal decree")

/mob/living/carbon/monkey/plush/king/proc/start_royal_chant_effects() // Chant overlay! Makes the royal glowy and floaty
	ADD_TRAIT(src, PLUSH_KING_CHANT_TRAIT, PLUSH_KING_CHANT_TRAIT)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, PLUSH_KING_CHANT_TRAIT)
	ADD_TRAIT(src, TRAIT_MOVE_FLOATING, PLUSH_KING_CHANT_TRAIT)
	if(!royal_chant_glow)
		royal_chant_glow = mutable_appearance('icons/effects/genetics.dmi', "fire")
		royal_chant_glow.color = "#FFD700"
		royal_chant_glow.alpha = 180
	add_overlay(royal_chant_glow)

/mob/living/carbon/monkey/plush/king/proc/end_royal_chant_effects()
	REMOVE_TRAIT(src, PLUSH_KING_CHANT_TRAIT, PLUSH_KING_CHANT_TRAIT)
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, PLUSH_KING_CHANT_TRAIT)
	REMOVE_TRAIT(src, TRAIT_MOVE_FLOATING, PLUSH_KING_CHANT_TRAIT)
	if(royal_chant_glow)
		cut_overlay(royal_chant_glow)

/mob/living/carbon/monkey/plush/king/proc/expand_royal_sanctuary()
	if(!active_sanctuary || QDELETED(active_sanctuary))
		active_sanctuary = null
		balloon_alert(src, "no court established")
		return FALSE

	var/list/claimed_areas = list()
	for(var/turf/T in active_sanctuary.claimed_turfs)
		var/area/A = get_area(T)
		if(A && !(A in claimed_areas))
			claimed_areas += A

	var/list/candidate_areas = list() // Gets a list of adjacent areas to currently claimed ones, for allowing/preventing areas to be claimed
	for(var/turf/claimed in active_sanctuary.claimed_turfs)
		for(var/dir in GLOB.cardinals)
			var/turf/neighbor = get_step(claimed, dir)
			if(!neighbor)
				continue
			var/area/neighbor_area = get_area(neighbor)
			if(!neighbor_area || istype(neighbor_area, /area/misc/space))
				continue
			if(neighbor_area in claimed_areas)
				continue
			if(!(neighbor_area in candidate_areas))
				candidate_areas += neighbor_area

	if(!length(candidate_areas))
		balloon_alert(src, "no adjacent rooms to claim")
		return FALSE

	var/area/current_area = get_area(src)
	if(!current_area || !(current_area in candidate_areas))
		balloon_alert(src, "stand in adjacent room")
		to_chat(src, span_warning("Expand Borders only claims the room you are standing in if it borders your current territory."))
		return FALSE

	var/area/best_area = current_area

	balloon_alert(src, "targeting [best_area.name]")

	var/list/pending_claim_turfs = list()
	for(var/turf/T in best_area)
		if(!(T in active_sanctuary.claimed_turfs))
			pending_claim_turfs += T
	if(!length(pending_claim_turfs))
		balloon_alert(src, "room already claimed")
		return FALSE

	var/list/chant_lines = list( // Chant lines for claiming a new area, chosen randomly
		"Threads remember. Stuffing endures.",
		"By plush decree, this place will be under our dominion.",
		"Let cotton, and devotion bind this space to the crown.",
		"By needle and thread, our kingdom takes root here.",
		"Let every seam in this room learn its ruler."
	)
	var/list/available_chants = chant_lines.Copy()
	var/chant_count = rand(1, length(chant_lines))
	var/second_chant_delay = rand(2, 5)
	var/third_chant_delay = rand(second_chant_delay + 2, 10)
	balloon_alert(src, "chanting royal decree...")
	start_royal_chant_effects()
	emit_royal_claim_chant(pick_n_take(available_chants))
	if(chant_count >= 2)
		addtimer(CALLBACK(src, PROC_REF(emit_royal_claim_chant), pick_n_take(available_chants)), second_chant_delay SECONDS)
	if(chant_count >= 3)
		addtimer(CALLBACK(src, PROC_REF(emit_royal_claim_chant), pick_n_take(available_chants)), third_chant_delay SECONDS)
	if(!do_after(src, 12 SECONDS, target = src))
		end_royal_chant_effects()
		balloon_alert(src, "decree interrupted")
		return FALSE
	end_royal_chant_effects()

	if(!active_sanctuary || QDELETED(active_sanctuary))
		active_sanctuary = null
		balloon_alert(src, "court lost")
		return FALSE

	active_sanctuary.claimed_turfs |= pending_claim_turfs
	active_sanctuary.refresh_aura()
	active_sanctuary.check_command_notification()
	broadcast_plushlink("By royal decree, [best_area.name] is now under the dominion of the Plush Kingdom!") // let the plush kind know of the domain expansion
	playsound(src, pick_weight(plush_squeak_sounds), 60, TRUE)
	return TRUE

// - Ghost Role Spawns and Spawners -

/obj/effect/mob_spawn/plush_monkey // Generic Plush Spawner but BETTER NOT USED SINCE THERES AN ITEM FOR THIS, OR MOB PATHS CAN BE SPAWNED DIRECTLY
	name = "strange plush"
	icon = 'icons/obj/plushes.dmi'
	icon_state = "renaultplush"
	mob_type = /mob/living/carbon/monkey/plush
	mob_name = "a strange plush"
	short_desc = "You are a living plush survivor."
	flavour_text = "You are a sentient plushie, a survivor of a destroyed world and near extinct species. Work toward the betterment of plushkind, stay memorable, and avoid betraying your fellow plushies."
	assignedrole = "Plush Kingdom Survivor"
	death = FALSE
	roundstart = FALSE
	use_cooldown = TRUE
	var/datum/team/plush_monkey/plush_team
	var/obj/structure/plush_spawner/chest

/obj/effect/mob_spawn/plush_monkey/special(mob/living/new_spawn)
	if(!new_spawn?.mind)
		return
	var/datum/antagonist/plush_monkey/antag_datum = new_spawn.mind.add_antag_datum(/datum/antagonist/plush_monkey, plush_team)
	if(antag_datum && !plush_team)
		plush_team = antag_datum.plush_team
	chest?.on_plush_spawned()
	to_chat(new_spawn, span_bigbold("You have a generic name by default! Ahelp to request a custom name!"))

/obj/effect/mob_spawn/plush_monkey/king // Similar but Different because this one is ROYAL!
	name = "strange royal plush"
	icon_state = "moffplush_royal"
	mob_type = /mob/living/carbon/monkey/plush/king
	mob_name = "the Plush Emperor"
	short_desc = "You are the Plush Emperor."
	flavour_text = "You are the Plush Emperor. Lead your subjects, claim your court, and ensure the Plush Kingdom's success."
	assignedrole = "Plush Emperor"

/obj/effect/mob_spawn/plush_monkey/king/special(mob/living/new_spawn)
	if(!new_spawn?.mind)
		return
	to_chat(new_spawn, span_bigbold("You are a sentient plushie. Ahelp to request a custom name for your plush!"))
	var/datum/antagonist/plush_king/antag_datum = new_spawn.mind.add_antag_datum(/datum/antagonist/plush_king, plush_team)
	if(antag_datum && !plush_team)
		plush_team = antag_datum.plush_team
	chest?.on_plush_spawned()

// - THE REAL SPAWNER! ITS WRAPPED IN GIFT PAPER !

/obj/structure/plush_spawner
	name = "royal toy chest"
	desc = "An ornate chest sealed with a golden ribbon. It's shaking slightly. Something is very much alive inside."
	icon = 'icons/obj/storage/wrapping.dmi'
	icon_state = "giftdeliverypackage1"
	anchored = TRUE
	density = TRUE
	layer = OBJ_LAYER
	var/obj/effect/mob_spawn/plush_monkey/spawner // shhh
	var/chest_variant = 1 // Inherent varient but vv so it can change after each spawn!
	var/static/list/chest_squeak_sounds = list( // Chest go SQUEAK when someone spawns
		'sound/items/toysqueak1.ogg' = 1,
		'sound/items/toysqueak2.ogg' = 1,
		'sound/items/toysqueak3.ogg' = 1,
	)

/obj/structure/plush_spawner/Initialize(mapload)
	. = ..()
	chest_variant = rand(1, 5) // Random wrapping varient!
	icon_state = "giftdeliverypackage[chest_variant]"
	spawner = new /obj/effect/mob_spawn/plush_monkey(get_turf(src))
	spawner.permanent = TRUE
	spawner.uses = -1 // INFINITE SPAWNING!
	spawner.chest = src
	spawner.alpha = 0 // makes the spawner INVISIBLE since the gift wrap is the wanted spawner
	notify_ghosts(
		"A royal toy chest has appeared. Plush survivors may emerge from it!", // ghost notification for the chest spawn
		source = src,
		action = NOTIFY_ATTACK,
		flashwindow = FALSE,
		ignore_key = POLL_IGNORE_PLUSH_MONKEY,
	)
	INVOKE_ASYNC(src, PROC_REF(schedule_wiggle))

/obj/structure/plush_spawner/Destroy() // :(
	QDEL_NULL(spawner)
	return ..()

/obj/structure/plush_spawner/attack_hand(mob/user, list/params) // On click make it go shakey shake
	. = ..()
	if(.)
		return
	Shake(3, 2, 8)
	to_chat(user, span_notice("The chest rattles. Something is waiting inside."))

/obj/structure/plush_spawner/attack_ghost(mob/dead/observer/user)
	if(QDELETED(src) || !user)

		return
	Shake(3, 2, 8)
	if(!spawner || QDELETED(spawner))
		to_chat(user, span_warning("This chest no longer contains plush kind.")) // message for the rare off chance
		return
	spawner.attack_ghost(user)

/obj/structure/plush_spawner/proc/schedule_wiggle() // Makes the spawner WIGGLE and SHAKE
	if(QDELETED(src))
		return
	addtimer(CALLBACK(src, PROC_REF(do_wiggle)), rand(5 SECONDS, 15 SECONDS), TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/structure/plush_spawner/proc/do_wiggle() // shakey shake
	if(QDELETED(src))
		return
	Shake(3, 2, 8)
	schedule_wiggle()

/obj/structure/plush_spawner/proc/on_plush_spawned() // Plays the sound, and actually swaps the chest varient on use
	playsound(src, pick_weight(chest_squeak_sounds), 60, TRUE)
	var/new_variant = rand(1, 4)
	if(new_variant >= chest_variant)
		new_variant++
	chest_variant = new_variant
	icon_state = "giftdeliverypackage[chest_variant]"

#undef PLUSH_MONKEY_TRAIT
#undef PLUSH_MONKEY_FORM_TRAIT
#undef PLUSH_KING_CHANT_TRAIT

// moth was here
