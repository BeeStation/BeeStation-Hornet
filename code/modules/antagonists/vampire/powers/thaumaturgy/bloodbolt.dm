/datum/action/vampire/targeted/bloodbolt
	name = "Thaumaturgy: Blood Bolt"
	desc = "Fire a blood bolt at your enemy, dealing Burn damage."
	button_icon_state = "power_thaumaturgy"
	background_icon_state_on = "tremere_power_plat_on"
	background_icon_state_off = "tremere_power_plat_off"
	power_explanation = "Shoots a blood bolt spell that deals burn damage"
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	bloodcost = 75
	cooldown_time = 20 SECONDS
	target_range = 8
	power_activates_immediately = FALSE
	prefire_message = "Select your target."

/datum/action/vampire/targeted/bloodbolt/FireTargetedPower(atom/target_atom)
	. = ..()
	check_witness()
	var/mob/living/living_owner = owner
	living_owner.balloon_alert(living_owner, "you fire a blood bolt!")
	living_owner.changeNext_move(CLICK_CD_RANGE)
	living_owner.newtonian_move(get_dir(target_atom, living_owner))

	var/obj/projectile/magic/arcane_barrage/vampire/bolt = new(living_owner.loc)
	bolt.vampire_power = src
	bolt.firer = living_owner
	bolt.def_zone = ran_zone(living_owner.get_combat_bodyzone())
	bolt.preparePixelProjectile(target_atom, living_owner)
	INVOKE_ASYNC(bolt, TYPE_PROC_REF(/obj/projectile, fire))

	playsound(living_owner, 'sound/vampires/bloodbolt.ogg', 60, TRUE)
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
