/**
 *	# Thaumaturgy
 *
 *	Level 1 - One shot bloodbeam spell
 *	Level 2 - Bloodbeam spell - Gives them a Blood shield until they use Bloodbeam
 *	Level 3 - Bloodbeam spell that breaks open lockers/doors - Gives them a Blood shield until they use Bloodbeam
 *	Level 4 - Bloodbeam spell that breaks open lockers/doors + double damage to victims - Gives them a Blood shield until they use Bloodbeam
 *	Level 5 - Bloodbeam spell that breaks open lockers/doors + double damage & steals blood - Gives them a Blood shield until they use Bloodbeam
 */
/datum/action/vampire/targeted/tremere/thaumaturgy
	name = "Level 1: Thaumaturgy"
	upgraded_power = /datum/action/vampire/targeted/tremere/thaumaturgy/two
	desc = "Fire a blood bolt at your enemy, dealing Burn damage."
	level_current = 1
	button_icon_state = "power_thaumaturgy"
	power_explanation = "Shoots a blood bolt spell that deals burn damage"
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_UNCONSCIOUS
	bloodcost = 20
	constant_bloodcost = 0
	cooldown_time = 6 SECONDS
	prefire_message = "Click where you wish to fire."

	/// Blood shield given while this Power is active.
	var/datum/weakref/blood_shield

/datum/action/vampire/targeted/tremere/thaumaturgy/two
	name = "Level 2: Thaumaturgy"
	upgraded_power = /datum/action/vampire/targeted/tremere/thaumaturgy/three
	desc = "Create a Blood shield and fire a blood bolt at your enemy, dealing Burn damage."
	level_current = 2
	power_explanation = "Activating Thaumaturgy will temporarily give you a Blood Shield.\n\
		The blood shield has a 75% block chance, but costs 15 Blood per hit to maintain.\n\
		You can also fire a blood bolt which will deactivate your shield."
	prefire_message = "Click where you wish to fire (using your power removes blood shield)."
	bloodcost = 40
	cooldown_time = 4 SECONDS

/datum/action/vampire/targeted/tremere/thaumaturgy/three
	name = "Level 3: Thaumaturgy"
	upgraded_power = /datum/action/vampire/targeted/tremere/thaumaturgy/advanced
	desc = "Create a Blood shield and fire a blood bolt, dealing Burn damage and opening doors/lockers."
	level_current = 3
	power_explanation = "Activating Thaumaturgy will temporarily give you a Blood Shield,\n\
		The blood shield has a 75% block chance, but costs 15 Blood per hit to maintain.\n\
		You can also fire a blood bolt which will deactivate your shield.\n\
		If the blood bolt hits a locker or door, it will open it."
	bloodcost = 50
	cooldown_time = 6 SECONDS

/datum/action/vampire/targeted/tremere/thaumaturgy/advanced
	name = "Level 4: Blood Strike"
	upgraded_power = /datum/action/vampire/targeted/tremere/thaumaturgy/advanced/two
	desc = "Create a Blood shield and fire a blood bolt, dealing Burn damage and opening doors/lockers."
	level_current = 4
	power_explanation = "Activating Thaumaturgy will temporarily give you a Blood Shield,\n\
		The blood shield has a 75% block chance, but costs 15 Blood per hit to maintain.\n\
		You can also fire a blood bolt which will deactivate your shield.\n\
		If the blood bolt hits a locker or door, it will open it.\n\
		Your blood bolt does more damage."
	background_icon_state = "tremere_power_gold_off"
	background_icon_state_on = "tremere_power_gold_on"
	background_icon_state_off = "tremere_power_gold_off"
	prefire_message = "Click where you wish to fire (using your power removes blood shield)."
	bloodcost = 60
	cooldown_time = 6 SECONDS

/datum/action/vampire/targeted/tremere/thaumaturgy/advanced/two
	name = "Level 5: Blood Strike"
	upgraded_power = null
	desc = "Create a Blood shield and fire a blood bolt, dealing Burn damage, stealing Blood and opening doors/lockers."
	level_current = 5
	power_explanation = "Activating Thaumaturgy will temporarily give you a Blood Shield,\n\
		The blood shield has a 75% block chance, but costs 15 Blood per hit to maintain.\n\
		You can also fire a blood bolt which will deactivate your shield.\n\
		If the blood bolt hits a locker or door, it will open it.\n\
		Your blood bolt does more damage, and if it hits a person will steal blood"
	bloodcost = 80
	cooldown_time = 8 SECONDS

/datum/action/vampire/targeted/tremere/thaumaturgy/activate_power()
	. = ..()
	owner.balloon_alert(owner, "you start thaumaturgy")
	if(level_current >= 2) // Only if we're at least level 2.
		var/obj/item/shield/vampire/new_shield = new
		blood_shield = WEAKREF(new_shield)
		if(!owner.put_in_inactive_hand(new_shield))
			owner.balloon_alert(owner, "off hand is full!")
			to_chat(owner, span_notice("Blood shield couldn't be activated as your off hand is full."))
			return FALSE
		owner.visible_message(
			span_warning("[owner] 's hands begins to bleed and forms into a blood shield!"),
			span_warning("We activate our Blood shield!"),
			span_hear("You hear liquids forming together."))

/datum/action/vampire/targeted/tremere/thaumaturgy/deactivate_power()
	if(blood_shield)
		QDEL_NULL(blood_shield)
	return ..()

/datum/action/vampire/targeted/tremere/thaumaturgy/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/living_owner = owner
	living_owner.balloon_alert(living_owner, "you fire a blood bolt!")
	living_owner.changeNext_move(CLICK_CD_RANGE)
	living_owner.newtonian_move(get_dir(target_atom, living_owner))

	var/obj/projectile/magic/arcane_barrage/vampire/bolt = new(living_owner.loc)
	bolt.vampire_power = src
	bolt.firer = living_owner
	bolt.def_zone = living_owner.get_random_valid_zone(living_owner.get_combat_bodyzone())
	bolt.preparePixelProjectile(target_atom, living_owner)
	INVOKE_ASYNC(bolt, TYPE_PROC_REF(/obj/projectile, fire))

	playsound(living_owner, 'sound/magic/wand_teleport.ogg', 60, TRUE)
	power_activated_sucessfully()

/**
 * 	# Blood Bolt
 *
 *	This is the projectile this Power will fire.
 */
/obj/projectile/magic/arcane_barrage/vampire
	name = "blood bolt"
	icon_state = "mini_leaper"
	damage = 20
	var/datum/action/vampire/targeted/tremere/thaumaturgy/vampire_power

/obj/projectile/magic/arcane_barrage/vampire/on_hit(atom/target_atom)
	if(istype(target_atom, /obj/structure/closet) && vampire_power.level_current >= 3)
		var/obj/structure/closet/hit_closet = target_atom
		hit_closet.welded = FALSE
		hit_closet.locked = FALSE
		hit_closet.broken = TRUE
		hit_closet.update_appearance()
		qdel(src)
		return BULLET_ACT_HIT

	if(istype(target_atom, /obj/machinery/door/airlock) && vampire_power.level_current >= 3)
		var/obj/machinery/door/airlock/airlock = target_atom
		airlock.unbolt()
		airlock.open()
		qdel(src)
		return BULLET_ACT_HIT

	if(isliving(target_atom))
		if(vampire_power.level_current >= 4)
			damage = 40
		if(vampire_power.level_current >= 5)
			var/mob/living/living_target = target_atom
			living_target.blood_volume -= 60
			vampire_power.vampiredatum_power.AddBloodVolume(60)
		qdel(src)
		return BULLET_ACT_HIT
	. = ..()

/**
 *	# Blood Shield
 *
 *	The shield spawned when using Thaumaturgy when strong enough.
 *	Copied mostly from '/obj/item/shield/changeling'
 */
/obj/item/shield/vampire
	name = "blood shield"
	desc = "A shield made out of blood, requiring blood to sustain hits."
	item_flags = ABSTRACT | DROPDEL
	icon = 'icons/vampires/vamp_obj.dmi'
	icon_state = "blood_shield"
	lefthand_file = 'icons/vampires/bs_leftinhand.dmi'
	righthand_file = 'icons/vampires/bs_rightinhand.dmi'
	block_power = 75

/obj/item/shield/vampire/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_VAMPIRE)

/obj/item/shield/vampire/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/datum/antagonist/vampire/vampire = IS_VAMPIRE(owner)
	vampire?.AddBloodVolume(-15)
	return ..()
