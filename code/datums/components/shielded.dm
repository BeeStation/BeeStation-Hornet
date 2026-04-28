/**
 * The shielded component causes the parent item to nullify a certain number of attacks against the wearer, see: shielded hardsuits.
 */

/datum/component/shielded
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// The person currently wearing us
	var/mob/living/wearer
	/// How many charges we can have max, and how many we start with
	var/max_integrity
	/// How many charges we currently have
	var/current_integrity
	/// How long we have to avoid being hit to replenish charges.
	var/recharge_start_delay = 20 SECONDS
	/// Once we go unhit long enough to recharge, we replenish charges this often. The floor is effectively 1 second, AKA how often SSdcs processes
	var/charge_increment_delay = 1 SECONDS
	/// How many charges we recover on each charge increment. If set to 0, we don't recharge
	var/charge_recovery = 20
	/// What .dmi we're pulling the shield icon from
	var/shield_icon_file = 'icons/effects/effects.dmi'
	/// What icon is used when someone has a functional shield up
	var/shield_icon = "shield-old"
	/// Do we still shield if we're being held in-hand? If FALSE, it needs to be equipped to a slot to work
	var/shield_inhand = FALSE
	/// Energy shield flags
	var/shield_flags = ENERGY_SHIELD_BLOCK_PROJECTILES | ENERGY_SHIELD_BLOCK_MELEE
	/// Energy shield alpha
	var/shield_alpha = 180
	/// The item we use for recharging
	var/recharge_path
	/// The cooldown tracking when we were last hit
	COOLDOWN_DECLARE(recently_hit_cd)
	/// The cooldown tracking when we last replenished a charge
	COOLDOWN_DECLARE(charge_add_cd)
	/// Callback for when the health of the shield changes
	/// Parameters: mob/living/user, current_integrity
	var/datum/callback/on_integrity_changed
	/// A callback for the sparks/message that play when a charge is used, see [/datum/component/shielded/proc/default_run_hit_callback]
	var/datum/callback/on_hit_effects
	/// Have effects been activated
	VAR_PRIVATE/_effects_activated
	/// Invoked when the mob equips the shield
	/// Parameters: mob/living/user, current_integrity
	var/datum/callback/on_active_effects
	/// Invoked when the mob unequips the shield
	/// Parameters: mob/living/user, current_integrity
	var/datum/callback/on_deactive_effects

/datum/component/shielded/Initialize(
		max_integrity = 60,
		charge_recovery = 20,
		recharge_start_delay = 20 SECONDS,
		charge_increment_delay = 1 SECONDS,
		shield_icon_file = 'icons/effects/effects.dmi',
		shield_icon = "shield-old",
		shield_inhand = FALSE,
		shield_flags = ENERGY_SHIELD_BLOCK_PROJECTILES | ENERGY_SHIELD_BLOCK_MELEE,
		shield_alpha = 160,
		recharge_path = null,
		run_hit_callback,
		on_active_effects,
		on_deactive_effects,
		on_integrity_changed,
		)
	if(!isitem(parent) || max_integrity <= 0)
		return COMPONENT_INCOMPATIBLE

	src.max_integrity = max_integrity
	src.recharge_start_delay = recharge_start_delay
	src.charge_increment_delay = charge_increment_delay
	src.charge_recovery = charge_recovery
	src.shield_icon_file = shield_icon_file
	src.shield_icon = shield_icon
	src.shield_inhand = shield_inhand
	src.shield_flags = shield_flags
	src.shield_alpha = shield_alpha
	src.recharge_path = recharge_path
	src.on_hit_effects = run_hit_callback || CALLBACK(src, PROC_REF(default_run_hit_callback))
	src.on_active_effects = on_active_effects
	src.on_deactive_effects = on_deactive_effects
	src.on_integrity_changed = on_integrity_changed

	current_integrity = max_integrity
	if(charge_recovery)
		START_PROCESSING(SSdcs, src)

/datum/component/shielded/Destroy(force, silent)
	if(wearer)
		shield_icon = "broken"
		UnregisterSignal(wearer, COMSIG_ATOM_UPDATE_OVERLAYS)
		wearer.update_appearance(UPDATE_ICON)
		if (_effects_activated)
			on_deactive_effects?.Invoke(wearer, current_integrity)
			_effects_activated = FALSE
		wearer = null
	on_hit_effects = null
	return ..()

/datum/component/shielded/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(lost_wearer))
	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, PROC_REF(on_hit_react))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(check_recharge_rune))
	if (shield_flags & ENERGY_SHIELD_EMP_VULNERABLE)
		RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(emp_destruction))
	var/atom/shield = parent
	if(ismob(shield.loc))
		var/mob/holder = shield.loc
		if(holder.is_holding(parent) && !shield_inhand)
			return
		set_wearer(holder)

/datum/component/shielded/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_ITEM_HIT_REACT, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_EMP_ACT))
	var/atom/shield = parent
	if(shield.loc == wearer)
		lost_wearer(src, wearer)

// Handle recharging, if we want to
/datum/component/shielded/process(delta_time)
	if(current_integrity >= max_integrity)
		STOP_PROCESSING(SSdcs, src)
		return
	if (!wearer)
		STOP_PROCESSING(SSdcs, src)
		return

	if(!COOLDOWN_FINISHED(src, recently_hit_cd))
		return
	if(!COOLDOWN_FINISHED(src, charge_add_cd))
		return

	var/obj/item/item_parent = parent
	COOLDOWN_START(src, charge_add_cd, charge_increment_delay)
	adjust_charge(charge_recovery)
	playsound(item_parent, 'sound/magic/charge.ogg', 50, TRUE)
	if(current_integrity == max_integrity)
		playsound(item_parent, 'sound/machines/ding.ogg', 50, TRUE)

/datum/component/shielded/proc/emp_destruction(datum/source, severity)
	SIGNAL_HANDLER
	if (!current_integrity)
		return
	COOLDOWN_START(src, recently_hit_cd, recharge_start_delay)
	current_integrity = 0
	on_integrity_changed?.Invoke(wearer, current_integrity)

	if(!charge_recovery) // if charge_recovery is 0, we don't recharge
		qdel(src)
		return

	if (!wearer)
		return

	// Remove effects on shield break
	if (_effects_activated)
		on_deactive_effects?.Invoke(wearer)
		_effects_activated = FALSE
	wearer.update_appearance(UPDATE_ICON)

	START_PROCESSING(SSdcs, src) // if we DO recharge, start processing so we can do that

/datum/component/shielded/proc/adjust_charge(change)
	var/needs_update = current_integrity <= 0
	current_integrity = clamp(current_integrity + change, 0, max_integrity)
	if (!wearer)
		return
	on_integrity_changed?.Invoke(wearer, current_integrity)
	if(wearer && needs_update)
		wearer.update_appearance(UPDATE_ICON)
		// re-add effects when the shield recovers
		if (!_effects_activated)
			on_active_effects?.Invoke(wearer, current_integrity)
			_effects_activated = TRUE
	if (current_integrity < max_integrity)
		START_PROCESSING(SSdcs, src)

/datum/component/shielded/proc/set_charge(new_value)
	current_integrity = clamp(new_value, 0, max_integrity)
	on_integrity_changed?.Invoke(wearer, current_integrity)
	// activate cooldown after updating the charge
	COOLDOWN_START(src, recently_hit_cd, recharge_start_delay)
	// Start processing if we need to charge up
	if (current_integrity < max_integrity)
		START_PROCESSING(SSdcs, src)

/// Check if we've been equipped to a valid slot to shield
/datum/component/shielded/proc/on_equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(slot == ITEM_SLOT_HANDS && !shield_inhand)
		lost_wearer(source, user)
		return
	set_wearer(user)

/// Either we've been dropped or our wearer has been QDEL'd. Either way, they're no longer our problem
/datum/component/shielded/proc/lost_wearer(datum/source, mob/user)
	SIGNAL_HANDLER

	if(wearer)
		if (_effects_activated)
			on_deactive_effects?.Invoke(user, current_integrity)
			_effects_activated = FALSE
		UnregisterSignal(wearer, list(COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_QDELETING))
		wearer.update_appearance(UPDATE_ICON)
		wearer = null

/datum/component/shielded/proc/set_wearer(mob/user)
	if(wearer == user)
		return
	if(!isnull(wearer))
		CRASH("[type] called set_wearer with [user] but [wearer] was already the wearer!")

	wearer = user
	RegisterSignal(wearer, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(wearer, COMSIG_QDELETING, PROC_REF(lost_wearer))
	if(current_integrity)
		wearer.update_appearance(UPDATE_ICON)
	if (shield_flags & ENERGY_SHIELD_DEPLETE_EQUIP)
		set_charge(0)
	// re-add effects when the shield recovers
	if (!_effects_activated && current_integrity > 0)
		on_active_effects?.Invoke(wearer, current_integrity)
		_effects_activated = TRUE
	// Start charging
	if (current_integrity < max_integrity)
		START_PROCESSING(SSdcs, src)

/// Used to draw the shield overlay on the wearer
/datum/component/shielded/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	if (shield_flags & ENERGY_SHIELD_INVISIBLE)
		return

	var/mutable_appearance/shield_image = mutable_appearance(shield_icon_file, (current_integrity > 0 ? shield_icon : "broken"), MOB_SHIELD_LAYER)
	shield_image.alpha = shield_alpha
	overlays += shield_image

/**
 * This proc fires when we're hit, and is responsible for checking if we're charged, then deducting one + returning that we're blocking if so.
 * It then runs the callback in [/datum/component/shielded/var/on_hit_effects] which handles the messages/sparks (so the visuals)
 */
/datum/component/shielded/proc/on_hit_react(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)
	SIGNAL_HANDLER

	COOLDOWN_START(src, recently_hit_cd, recharge_start_delay)

	if ((attack_type == PROJECTILE_ATTACK || attack_type == THROWN_PROJECTILE_ATTACK) && !(shield_flags & ENERGY_SHIELD_BLOCK_PROJECTILES))
		return
	else if (!(attack_type == PROJECTILE_ATTACK || attack_type == THROWN_PROJECTILE_ATTACK) && !(shield_flags & ENERGY_SHIELD_BLOCK_MELEE))
		return

	if(current_integrity <= 0)
		return
	. = COMPONENT_HIT_REACTION_BLOCK
	current_integrity = max(current_integrity - damage, 0)
	on_integrity_changed?.Invoke(wearer, current_integrity)

	INVOKE_ASYNC(src, PROC_REF(actually_run_hit_callback), owner, attack_text, current_integrity)

	// if charge_recovery is 0, we don't recharge
	if(!charge_recovery)
		// obviously if someone ever adds a manual way to replenish charges, change this
		if(current_integrity <= 0)
			qdel(src)
		return

	if (current_integrity <= 0)
		// Remove effects on shield break
		if (_effects_activated)
			on_deactive_effects?.Invoke(wearer)
			_effects_activated = FALSE
		wearer.update_appearance(UPDATE_ICON)

	START_PROCESSING(SSdcs, src) // if we DO recharge, start processing so we can do that

/// The wrapper to invoke the on_hit callback, so we don't have to worry about blocking in the signal handler
/datum/component/shielded/proc/actually_run_hit_callback(mob/living/owner, attack_text, current_integrity)
	on_hit_effects.Invoke(owner, attack_text, current_integrity)

/// Default on_hit proc, since cult robes are stupid and have different descriptions/sparks
/datum/component/shielded/proc/default_run_hit_callback(mob/living/owner, attack_text, current_integrity)
	do_sparks(2, TRUE, owner)
	owner.visible_message(span_danger("[owner]'s shields deflect [attack_text] in a shower of sparks!"))
	if(current_integrity <= 0)
		owner.visible_message(span_warning("[owner]'s shield overloads!"))

/datum/component/shielded/proc/check_recharge_rune(datum/source, obj/item/recharge_rune, mob/living/user)
	SIGNAL_HANDLER

	if(!istype(recharge_rune, recharge_path))
		return
	. = COMPONENT_NO_AFTERATTACK

	max_integrity += recharge_rune.added_shield
	adjust_charge(recharge_rune.added_shield)
	to_chat(user, span_notice("You charge \the [parent]. It can now absorb [current_integrity] damage."))
	qdel(recharge_rune)
