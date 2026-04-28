/datum/holoparasite_ability/major/assassin
	name = "Assassin"
	desc = "The $theme can sneak up on people and do a powerful attack."
	ui_icon = "eye-slash"
	cost = 2
	thresholds = list(
		list(
			"stat" = "Potential",
			"desc" = "Reduces the cooldown of the stealth ability."
		)
	)
	/// If the holopara is in assassin mode or not.
	var/assassin = FALSE
	/// How long the stealth cooldown lasts
	var/stealth_cooldown_time = 0
	/// The HUD button to toggle assassin mode.
	var/atom/movable/screen/holoparasite/toggle_assassin/toggle_hud
	/// The on-screen alert notifying the holoparasite that they are currently able to enter stealth mode.
	var/atom/movable/screen/alert/can_stealth_alert
	/// The on-screen alert notifying the holoparasite that they are currently in stealth mode.
	var/atom/movable/screen/alert/in_stealth_alert
	/// Cooldown for when the holoparasite can next enter stealth mode.
	COOLDOWN_DECLARE(stealth_cooldown)

/datum/holoparasite_ability/major/assassin/Destroy()
	. = ..()
	QDEL_NULL(toggle_hud)
	QDEL_NULL(can_stealth_alert)
	QDEL_NULL(in_stealth_alert)

/datum/holoparasite_ability/major/assassin/apply()
	..()
	stealth_cooldown_time = (7.5 SECONDS) / master_stats.potential

/datum/holoparasite_ability/major/assassin/register_signals()
	..()
	RegisterSignal(owner, COMSIG_HOLOPARA_STAT, PROC_REF(on_stat))
	RegisterSignal(owner, COMSIG_HOLOPARA_SETUP_HUD, PROC_REF(on_hud_setup))

/datum/holoparasite_ability/major/assassin/unregister_signals()
	..()
	UnregisterSignal(owner, list(COMSIG_HOLOPARA_STAT, COMSIG_HOLOPARA_SETUP_HUD))

/**
 * Adds stealth mode cooldown info to the holoparasite's stat panel.
 */
/datum/holoparasite_ability/major/assassin/proc/on_stat(datum/_source, list/tab_data)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, stealth_cooldown))
		tab_data["Stealth Cooldown"] = GENERATE_STAT_TEXT(COOLDOWN_TIMELEFT_TEXT(src, stealth_cooldown))

/**
 * Sets up the HUD, with the toggle assassin mode button.
 */
/datum/holoparasite_ability/major/assassin/proc/on_hud_setup(datum/_source, datum/hud/holoparasite/hud, list/huds_to_add)
	SIGNAL_HANDLER
	if(QDELETED(toggle_hud))
		toggle_hud = new(null, owner, src)
	huds_to_add += toggle_hud

/**
 * Enters assassin mode, allowing the holoparasite to become near-invisible and strike with a single massive, armor-penetrating hit.
 */
/datum/holoparasite_ability/major/assassin/proc/enter_assassin()
	. = TRUE
	ASSERT_ABILITY_USABILITY
	if(!COOLDOWN_FINISHED(src, stealth_cooldown))
		to_chat(owner, span_dangerbold("You cannot yet enter stealth, wait another [COOLDOWN_TIMELEFT_TEXT(src, stealth_cooldown)]!"))
		return FALSE
	owner.melee_damage = 50
	owner.armour_penetration = 100
	owner.obj_damage = 0
	owner.environment_smash = ENVIRONMENT_SMASH_NONE
	new /obj/effect/temp_visual/holoparasite/phase/out(get_turf(owner))
	owner.alpha = 15
	assassin = TRUE
	update_stealth_alert()
	owner.balloon_alert(owner, "entered assassin mode", show_in_chat = FALSE)

/**
 * Exits assassin mode, restoring the holoparasite's stats, visibility, and such to normal.
 */
/datum/holoparasite_ability/major/assassin/proc/exit_assassin(forced = FALSE)
	owner.melee_damage = initial(owner.melee_damage)
	owner.armour_penetration = initial(owner.armour_penetration)
	owner.obj_damage = initial(owner.obj_damage)
	owner.environment_smash = initial(owner.environment_smash)
	owner.alpha = initial(owner.alpha)
	master_stats.apply(owner)
	if(!forced)
		owner.visible_message(span_danger("[owner.color_name] suddenly appears!"))
		COOLDOWN_START(src, stealth_cooldown, stealth_cooldown_time)
		COOLDOWN_START(owner, manifest_cooldown, 4 SECONDS)
		toggle_hud.begin_timer(stealth_cooldown_time)
		if(owner.hud_used)
			var/atom/movable/screen/holoparasite/manifest_recall/mr_hud = locate() in owner.hud_used.static_inventory
			mr_hud?.begin_timer(4 SECONDS)
		owner.balloon_alert(owner, "exited assassin mode", show_in_chat = FALSE)
	update_stealth_alert()
	assassin = FALSE

/**
 * Updates the on-screen alert indicating the holoparasite's stealth status
 */
/datum/holoparasite_ability/major/assassin/proc/update_stealth_alert()
	if(COOLDOWN_FINISHED(src, stealth_cooldown))
		// TODO: mode
		/*if(mode)
			if(!in_stealth_alert)
				in_stealth_alert = owner.throw_alert("instealth", /atom/movable/screen/alert/instealth)
				owner.clear_alert("canstealth")
				can_stealth_alert = null
		else
			if(!can_stealth_alert)
				can_stealth_alert = owner.throw_alert("canstealth", /atom/movable/screen/alert/canstealth)
				owner.clear_alert("instealth")
				in_stealth_alert = null*/
		;
	else
		owner.clear_alert("instealth")
		in_stealth_alert = null
		owner.clear_alert("canstealth")
		can_stealth_alert = null

/atom/movable/screen/holoparasite/toggle_assassin
	name = "Toggle Assassin Mode"
	desc = "Enter assassin mode, allowing you to easily backstab a target for massive damage and armor penetration."
	icon_state = "backstab"
	var/datum/holoparasite_ability/major/assassin/ability

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/screen/holoparasite/toggle_assassin)

/atom/movable/screen/holoparasite/toggle_assassin/Initialize(mapload, mob/living/simple_animal/hostile/holoparasite/_owner, datum/holoparasite_ability/major/assassin/_ability)
	. = ..()
	if(!istype(_ability))
		CRASH("Tried to make assassin holoparasite HUD without proper reference to assassin ability")
	ability = _ability

/atom/movable/screen/holoparasite/toggle_assassin/use()
	if(ability.assassin)
		ability.exit_assassin()
	else
		ability.enter_assassin()
	update_appearance()

/atom/movable/screen/holoparasite/toggle_assassin/tooltip_content()
	. = ..()
	if(owner.is_manifested())
		. += "<br><b>You must be recalled to change assassin modes!</b>"
