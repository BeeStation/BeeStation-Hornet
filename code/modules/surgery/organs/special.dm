/obj/item/organ/apid_stinger
	name = "apid stinger"
	desc = "An apid stinger. Who pissed off the bee?"
	visual = FALSE
	icon_state = "beestinger"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_TAIL
	actions_types = list(/datum/action/cooldown/bee_sting)

/datum/action/cooldown/bee_sting
	name = "Use Apid Stinger"
	check_flags = AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	cooldown_time = 2 MINUTES
	click_to_activate = TRUE
	unset_after_click = TRUE
	button_icon_state = null

/datum/action/cooldown/bee_sting/New(Target)
	. = ..()
	if(Target)
		AddComponent(/datum/component/action_item_overlay, Target)
		if(istype(Target, /obj/item/organ))
			var/obj/item/organ/organ_target = Target
			name = "Use [organ_target.name]"

/datum/action/cooldown/bee_sting/is_available(feedback = FALSE)
	var/obj/item/organ/attached_organ = target
	if(!istype(attached_organ) || !attached_organ.owner)
		return FALSE
	return ..()

/datum/action/cooldown/bee_sting/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return
	to_chat(on_who, span_notice("You prepare to sting. <B>Left-click your target!</B>"))

/datum/action/cooldown/bee_sting/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return
	if(refund_cooldown)
		to_chat(on_who, span_notice("You are no longer prepared to sting."))

/datum/action/cooldown/bee_sting/Activate(atom/target)
	if(!owner.Adjacent(target))
		owner.balloon_alert(owner, "Your stinger can't reach that far!")
		return FALSE

	if(!isliving(target))
		return FALSE

	if(target == owner)
		return FALSE

	var/mob/living/living_target = target
	playsound(living_target, 'sound/weapons/bladeslice.ogg', 50, TRUE, -1)
	if(living_target.can_inject(owner, owner.get_combat_bodyzone(), INJECT_CHECK_PENETRATE_THICK))

		living_target.visible_message(span_danger("[owner] stings [living_target]!"), \
					span_userdanger("You're stung by [owner]!"), null, COMBAT_MESSAGE_RANGE, owner)
		to_chat(owner, span_danger("You sting [living_target]!"))
		log_combat(owner, living_target, "apid sting", owner)
		living_target.reagents.add_reagent(/datum/reagent/toxin/apidvenom, 10)
		start_cooldown()
		return TRUE
	else
		living_target.visible_message(span_danger("[owner] tries to sting [living_target]!"), \
					span_userdanger("[owner] tries to sting you, but it deflects off!"), null, COMBAT_MESSAGE_RANGE, owner)
		to_chat(owner, span_danger("You fail to sting [living_target]!"))
		log_combat(owner, living_target, "attempted and failed apid sting", owner)
		unset_click_ability(owner)
		return FALSE
