/datum/action/spell/lichdom
	name = "Bind Soul"
	desc = "A spell that binds your soul to an item in your hands. \
		Binding your soul to an item will turn you into an immortal Lich. \
		So long as the item remains intact, you will revive from death, \
		no matter the circumstances."
	button_icon = 'icons/hud/actions/actions_spells.dmi'
	button_icon_state = "skeleton"

	school = SCHOOL_NECROMANCY
	cooldown_time = 1 SECONDS

	invocation = "NECREM IMORTIUM!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_OFF_CENTCOM|SPELL_REQUIRES_MIND
	spell_max_level = 1

/datum/action/spell/lichdom/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE

	// We call this here so we can get feedback if they try to cast it when they shouldn't.
	if(!is_valid_spell(owner, owner))
		if(feedback)
			to_chat(owner, span_warning("You don't have a soul to bind!"))
		return FALSE

	return TRUE

/datum/action/spell/lichdom/is_valid_spell(mob/user, atom/target)
	return isliving(user) && !HAS_TRAIT(user, TRAIT_NO_SOUL)

/datum/action/spell/lichdom/on_cast(mob/living/user, atom/target)
	var/obj/item/marked_item = user.get_active_held_item()
	if(!marked_item || marked_item.item_flags & ABSTRACT)
		return
	if(HAS_TRAIT(marked_item, TRAIT_NODROP))
		to_chat(user, span_warning("[marked_item] is stuck to your hand - it wouldn't be a wise idea to place your soul into it."))
		return
	// I ensouled the nuke disk once.
	// But it's a really mean tactic, so we probably should disallow it.
	if(SEND_SIGNAL(marked_item, COMSIG_ITEM_IMBUE_SOUL, src, user) & COMPONENT_BLOCK_IMBUE)
		to_chat(user, span_warning("[marked_item] is not suitable for emplacement of your fragile soul."))
		return

	. = ..()
	playsound(user, 'sound/effects/pope_entry.ogg', 100)

	to_chat(user, ("<span class='green'>You begin to focus your very being into [marked_item]..."))
	if(!do_after(user, 5 SECONDS, target = marked_item, timed_action_flags = IGNORE_HELD_ITEM))
		to_chat(user, span_warning("Your soul snaps back to your body as you stop ensouling [marked_item]!"))
		return

	marked_item.AddComponent(/datum/component/phylactery, user.mind)

	user.set_species(/datum/species/skeleton)
	to_chat(user, span_userdanger("With a hideous feeling of emptiness you watch in horrified fascination \
		as skin sloughs off bone! Blood boils, nerves disintegrate, eyes boil in their sockets! \
		As your organs crumble to dust in your fleshless chest you come to terms with your choice. \
		You're a lich!"))

	if(iscarbon(user))
		var/mob/living/carbon/carbon_cast_on = user
		var/obj/item/organ/brain/lich_brain = carbon_cast_on.get_organ_slot(ORGAN_SLOT_BRAIN)
		if(lich_brain) // This prevents MMIs being used to stop lich revives
			lich_brain.organ_flags &= ~ORGAN_VITAL
			lich_brain.decoy_override = TRUE

	if(ishuman(user))
		var/mob/living/carbon/human/human_cast_on = user
		human_cast_on.dropItemToGround(human_cast_on.w_uniform)
		human_cast_on.dropItemToGround(human_cast_on.wear_suit)
		human_cast_on.dropItemToGround(human_cast_on.head)
		human_cast_on.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(human_cast_on), ITEM_SLOT_OCLOTHING)
		human_cast_on.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(human_cast_on), ITEM_SLOT_HEAD)
		human_cast_on.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(human_cast_on), ITEM_SLOT_ICLOTHING)


	// No soul. You just sold it
	ADD_TRAIT(user, TRAIT_NO_SOUL, LICH_TRAIT)
	// You only get one phylactery.
	qdel(src)
