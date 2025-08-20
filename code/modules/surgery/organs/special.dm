/obj/item/organ/apid_stinger
	name = "apid stinger"
	desc = "An apid stinger. Who pissed off the bee?"
	visual = FALSE
	icon_state = "beestinger"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_TAIL
	actions_types = list(/datum/action/item_action/organ_action/use/bee_sting)

/datum/action/item_action/organ_action/use/bee_sting
	requires_target = TRUE
	check_flags = AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	cooldown_time = 2 MINUTES

/datum/action/item_action/organ_action/use/bee_sting/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return
	to_chat(on_who, ("<span class='notice'>You prepare to sting. <B>Left-click your target!</B></span>"))
	update_buttons()

/datum/action/item_action/organ_action/use/bee_sting/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, ("<span class='notice'>You are no longer prepared to sting.</span>"))
	update_buttons()

/datum/action/item_action/organ_action/use/bee_sting/on_activate(mob/user, atom/target)
	if(!owner.Adjacent(target))
		owner.balloon_alert(owner, "Your stinger can't reach that far!")
		return FALSE

	if(!isliving(target))
		return FALSE

	if(target == owner)
		return FALSE

	var/mob/living/living_target = target
	playsound(living_target, 'sound/weapons/bladeslice.ogg', 50, TRUE, -1)
	if(living_target.can_inject(user, user.get_combat_bodyzone(), INJECT_CHECK_PENETRATE_THICK))

		living_target.visible_message(span_danger("[user] stings [living_target]!"), \
					span_userdanger("You're stung by [user]!"), null, COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You sting [living_target]!"))
		log_combat(user, living_target, "apid sting", user)
		living_target.reagents.add_reagent(/datum/reagent/toxin/apidvenom, 10)
		start_cooldown()
		return TRUE
	else
		living_target.visible_message(span_danger("[user] tries to sting [living_target]!"), \
					span_userdanger("[user] tries to sting you, but it deflects off!"), null, COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You fail to sting [living_target]!"))
		log_combat(user, living_target, "attempted and failed apid sting", user)
		unset_click_ability()
		return FALSE
