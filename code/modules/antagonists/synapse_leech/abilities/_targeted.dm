/**
 * # Targeted Leech Ability
 *
 * Base class for leech abilities that require clicking on a target after activation. The action
 * button arms the ability; the next valid click on a target inside target_range triggers it.
 *
 * Subclasses should override:
 *   - is_valid_target(atom/target) gate which atoms can be selected
 *   - on_target(mob/living/basic/synapse_leech/leech, atom/target) the actual effect
 *
 * Costs (substrate / saturation / cooldown) are paid only after a successful target click.
 */
/datum/action/leech/targeted
	abstract_type = /datum/action/leech/targeted
	requires_target = TRUE
	unset_after_click = FALSE // We control cooldown / unset ourselves so failures don't waste it.
	click_cd_override = CLICK_CD_MELEE
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

	/// Maximum range from the leech that the target may be at. 0 = self only, null = unlimited.
	var/target_range = 1
	/// Optional message shown to the leech when arming the ability.
	var/prefire_message

/datum/action/leech/targeted/update_desc()
	. = ..()
	desc = "[desc][desc ? "<br>" : ""]<i>Targeted ability.</i>"

/datum/action/leech/targeted/set_click_ability(mob/on_who)
	. = ..()
	if(prefire_message)
		to_chat(on_who, span_notice(prefire_message))

/datum/action/leech/targeted/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(!is_available())
		unset_click_ability(clicker, refund_cooldown = FALSE)
		return TRUE
	if(!can_pay_cost())
		unset_click_ability(clicker, refund_cooldown = TRUE)
		return TRUE
	if(!check_target_range(target))
		clicker.balloon_alert(clicker, "out of range!")
		return TRUE
	if(!is_valid_target(target))
		clicker.balloon_alert(clicker, "invalid target!")
		return TRUE

	var/mob/living/basic/synapse_leech/leech = get_leech()
	if(!on_target(leech, target))
		// Subclass refused; don't spend resources or cooldown.
		return TRUE

	pay_cost()
	start_cooldown()
	unset_click_ability(clicker, refund_cooldown = FALSE)
	clicker.next_click = world.time + click_cd_override
	return TRUE

/// Range: null = unlimited.
/datum/action/leech/targeted/proc/check_target_range(atom/target)
	if(target == owner)
		return TRUE
	if(isnull(target_range))
		return TRUE
	return (target in view(target_range, owner))

/// Override to filter valid targets.
/datum/action/leech/targeted/proc/is_valid_target(atom/target)
	return TRUE

/// Override to implement the targeted effect. Return TRUE if the ability fired successfully.
/datum/action/leech/targeted/proc/on_target(mob/living/basic/synapse_leech/leech, atom/target)
	return FALSE
