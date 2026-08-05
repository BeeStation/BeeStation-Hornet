/datum/holoparasite_ability/weapon/dextrous
	name = "Dextrous"
	desc = "The $theme gains two fully functional hands capable of wielding items, along with a storage slot for a single item. It is completely incapable of firing guns by default, and it will drop any items held in its hands whenever it is recalled."
	ui_icon = "hands"
	cost = 3
	thresholds = list(
		list(
			"stat" = "Range",
			"minimum" = 3,
			"desc" = "The $theme is capable of wielding and firing firearms that aren't lethally chambered, albeit inaccurately."
		),
		list(
			"stat" = "Damage",
			"minimum" = 4,
			"desc" = "The $theme is capable of wielding two-handed weapons."
		),
		list(
			"stats" = list(
				list(
					"name" = "Damage",
					"minimum" = 5
				),
				list(
					"name" = "Range",
					"minimum" = 5
				)
			),
			"desc" = "The $theme is capable of firing most small-to-average firearms, with average accuracy."
		),
		list(
			"stat" = "Potential",
			"minimum" = 1,
			"desc" = "The internal storage slot can only store a tiny item (e.g. playing cards, lighter, scalpel, coins/holochips)"
		),
		list(
			"stat" = "Potential",
			"minimum" = 2,
			"desc" = "The internal storage slot can store up to a small-sized item (e.g. flashlight, multitool, grenades, GPS)"
		),
		list(
			"stat" = "Potential",
			"minimum" = 3,
			"desc" = "The internal storage slot can store up to a normal-sized item (e.g. fire extinguisher, stun baton, gas mask, iron sheets)"
		),
		list(
			"stat" = "Potential",
			"minimum" = 5,
			"desc" = "The internal storage slot can store up to a bulky-sized item (e.g. defibrillator, backpack, space suits)"
		)
	)
	/// The item held in the holoparasite's internal storage.
	var/obj/item/internal_storage
	/// The maximum weight class that can be stored in the internal storage.
	var/max_w_class = WEIGHT_CLASS_BULKY
	/// Whether the holoparasite can wield two-handed weapons or not.
	var/can_wield = TRUE
	/// Whether the holoparasite can fire non-lethal guns or not.
	var/can_use_nonlethal_guns = TRUE
	/// Whether the holoparasite can fire most guns or not.
	var/can_use_most_guns = TRUE
	/// The drop screen item
	var/atom/movable/screen/drop/disappearing/drop
	/// A typecache of guns that the holoparasite is NEVER allowed to fire.
	var/static/list/forbidden_guns

/datum/holoparasite_ability/weapon/dextrous/New(datum/holoparasite_stats/master_stats)
	. = ..()
	if(!forbidden_guns)
		forbidden_guns = zebra_typecacheof(list(
			/obj/item/gun/ballistic/automatic/ar = TRUE,
			/obj/item/gun/ballistic/automatic/c20r = TRUE,
			/obj/item/gun/ballistic/automatic/gyropistol = TRUE,
			/obj/item/gun/ballistic/automatic/l6_saw = TRUE,
			/obj/item/gun/ballistic/automatic/m90 = TRUE,
			/obj/item/gun/ballistic/automatic/mini_uzi = TRUE,
			/obj/item/gun/ballistic/automatic/proto = TRUE,
			/obj/item/gun/ballistic/automatic/tommygun = TRUE,
			/obj/item/gun/ballistic/automatic/wt550 = TRUE,
			/obj/item/gun/ballistic/rocketlauncher,
			/obj/item/gun/ballistic/shotgun = TRUE,
			/obj/item/gun/ballistic/sniper_rifle = TRUE,
			/obj/item/gun/blastcannon = TRUE,
			/obj/item/gun/energy/beam_rifle = TRUE,
			/obj/item/gun/energy/gravity_gun = TRUE,
			/obj/item/gun/energy/lasercannon = TRUE,
			/obj/item/gun/energy/pulse = TRUE,
			/obj/item/gun/grenadelauncher = TRUE,
			/obj/item/gun/magic = TRUE,
			// honestly holopara with honk staff just sounds kinda funny, so I'm just gonna let it happen, until proven otherwise I guess.
			/obj/item/gun/magic/staff/honk = FALSE,
		))

/datum/holoparasite_ability/weapon/dextrous/apply()
	max_w_class = master_stats.potential >= 5 ? WEIGHT_CLASS_BULKY : clamp(master_stats.potential, WEIGHT_CLASS_TINY, WEIGHT_CLASS_NORMAL)
	can_use_nonlethal_guns = master_stats.range >= 3
	can_wield = master_stats.damage >= 4
	can_use_most_guns = master_stats.damage >= 5 && master_stats.range >= 5
	if(!can_use_most_guns)
		add_owner_trait(TRAIT_POOR_AIM)
	owner.dextrous = TRUE
	owner.combat_mode = FALSE
	owner.LoadComponent(/datum/component/personal_crafting)
	if(!length(owner.held_items))
		owner.held_items = list(null, null)
	owner.melee_damage = 6 + round((master_stats.damage - 1) * 0.8) // approximately the same as an average human's punch
	owner.obj_damage = 0
	owner.armour_penetration = 0
	owner.ranged = FALSE
	if(isnull(owner.theme.mob_info[HOLOPARA_THEME_ATTACK_SOUND]))
		owner.attack_sound = "punch"
	owner.response_harm_continuous = "weakly punches"
	owner.response_harm_simple = "weakly punch"
	owner.attack_verb_continuous = "weakly punches"
	owner.attack_verb_simple = "weakly punch"
	owner.environment_smash = NONE
	. = ..()

/datum/holoparasite_ability/weapon/dextrous/remove()
	owner.unequip_everything()
	owner.dextrous = FALSE
	owner.combat_mode = initial(owner.combat_mode)
	var/datum/component/personal_crafting/crafting = owner.GetComponent(/datum/component/personal_crafting)
	crafting?.ClearFromParent()
	owner.melee_damage = initial(owner.melee_damage)
	owner.obj_damage = initial(owner.obj_damage)
	owner.armour_penetration = initial(owner.armour_penetration)
	owner.ranged = initial(owner.ranged)
	if(isnull(owner.theme.mob_info[HOLOPARA_THEME_ATTACK_SOUND]))
		owner.attack_sound = initial(owner.attack_sound)
	owner.response_harm_continuous = initial(owner.response_harm_continuous)
	owner.response_harm_simple = initial(owner.response_harm_simple)
	owner.attack_verb_continuous = initial(owner.attack_verb_continuous)
	owner.attack_verb_simple = initial(owner.attack_verb_simple)
	owner.environment_smash = initial(owner.environment_smash)
	. = ..()

/datum/holoparasite_ability/weapon/dextrous/register_signals()
	..()
	RegisterSignal(owner, COMSIG_HOLOPARA_SETUP_HUD, PROC_REF(on_hud_setup))
	RegisterSignals(owner, list(COMSIG_HOLOPARA_PRE_SNAPBACK, COMSIG_HOLOPARA_PRE_RECALL), PROC_REF(drop_items))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(owner, COMSIG_TWOHANDED_WIELD, PROC_REF(on_wield))
	RegisterSignal(owner, COMSIG_HOLOPARA_CAN_FIRE_GUN, PROC_REF(can_fire_gun))
	RegisterSignal(owner, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/holoparasite_ability/weapon/dextrous/unregister_signals()
	..()
	UnregisterSignal(owner, list(COMSIG_HOLOPARA_SETUP_HUD, COMSIG_HOLOPARA_PRE_SNAPBACK, COMSIG_HOLOPARA_PRE_RECALL, COMSIG_LIVING_DEATH, COMSIG_TWOHANDED_WIELD, COMSIG_HOLOPARA_CAN_FIRE_GUN, COMSIG_ATOM_EXAMINE))

/datum/holoparasite_ability/weapon/dextrous/proc/on_hud_setup(datum/_source, datum/hud/holoparasite/hud, list/huds_to_add)
	SIGNAL_HANDLER
	create_storage_hud(hud)
	create_misc_hud(hud, huds_to_add)

/datum/holoparasite_ability/weapon/dextrous/proc/create_storage_hud(datum/hud/holoparasite/hud)
	var/atom/movable/screen/inventory/inv_box = new /atom/movable/screen/inventory(null, hud)
	inv_box.name = "internal storage"
	inv_box.icon = hud.ui_style
	inv_box.icon_state = "suit_storage"
	inv_box.screen_loc = ui_inventory
	inv_box.slot_id = ITEM_SLOT_DEX_STORAGE
	hud.static_inventory |= inv_box

/datum/holoparasite_ability/weapon/dextrous/proc/create_misc_hud(datum/hud/holoparasite/hud, list/huds_to_add)
	hud.action_intent = new /atom/movable/screen/combattoggle/flashy()
	hud.action_intent.icon = hud.ui_style
	hud.action_intent.screen_loc = ui_combat_toggle
	huds_to_add += hud.action_intent

	hud.zone_select = new /atom/movable/screen/zone_sel
	hud.zone_select.icon = hud.ui_style
	hud.zone_select.update_icon()
	huds_to_add += hud.zone_select

	drop = new(null, hud)
	drop.icon = hud.ui_style
	drop.screen_loc = "CENTER-1:9,SOUTH+1:4"
	drop.update_icon()
	hud.static_inventory += drop

/**
 * Forces the holoparasite to drop all held items when it recalls.
 */
/datum/holoparasite_ability/weapon/dextrous/proc/drop_items()
	SIGNAL_HANDLER
	owner.drop_all_held_items()

/**
 * Forces the holoparasite to drop everything it's carrying whenever it dies.
 */
/datum/holoparasite_ability/weapon/dextrous/proc/on_death()
	SIGNAL_HANDLER
	owner.unequip_everything()

/**
 * Blocks the holoparasite from wielding two-handed items when the threshold is not met.
 */
/datum/holoparasite_ability/weapon/dextrous/proc/on_wield(datum/_source, mob/living/user)
	SIGNAL_HANDLER
	if(!can_wield)
		to_chat(user, span_warning("You are not strong enough to wield two-handed weapons!"))
		return COMPONENT_TWOHANDED_BLOCK_WIELD

/datum/holoparasite_ability/weapon/dextrous/proc/can_fire_gun(datum/_source, obj/item/gun/gun)
	SIGNAL_HANDLER
	if(!istype(gun) || is_type_in_typecache(gun, forbidden_guns))
		return
	if(can_use_most_guns || (can_use_nonlethal_guns && !gun.chambered?.harmful))
		return HOLOPARA_CAN_FIRE_GUN

/**
 * Allows examining the holoparasite to see what item it's holding.
 */
/datum/holoparasite_ability/weapon/dextrous/proc/on_examine(datum/source, mob/user, text)
	SIGNAL_HANDLER
	var/t_they = owner.p_They()
	var/t_their = owner.p_their()
	var/t_is = owner.p_are()
	for(var/obj/item/item in owner.held_items)
		if(item.item_flags & ABSTRACT || HAS_TRAIT(item, TRAIT_EXAMINE_SKIP))
			continue

		text += span_notice("[t_they] [t_is] holding <b>[item.examine_title(user)]</b> in [t_their] [owner.get_held_index_name(owner.get_held_index_of_item(item))].")
	if(internal_storage)
		if(internal_storage.item_flags & ABSTRACT || HAS_TRAIT(internal_storage, TRAIT_EXAMINE_SKIP))
			return
		if((!owner.has_matching_summoner(user) && !isobserver(user)) && get_dist(owner, user) > HOLOPARA_DEXTROUS_EXAMINE_DISTANCE)
			text += span_notice("[t_they] [t_is] holding something in [t_their] internal storage, but you are <b>too far away</b> to see what.")
			return
		text += span_notice("[t_they] [t_is] holding <b>[internal_storage.examine_title(user)]</b> in [t_their] internal storage.")
