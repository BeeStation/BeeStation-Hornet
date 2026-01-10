/datum/action/vampire/targeted/bloodbolt
	name = "Thaumaturgy: Blood Bolt"
	desc = "Fire a blood bolt at your enemy, dealing Burn damage."
	button_icon_state = "power_thaumaturgy"
	background_icon_state_on = "tremere_power_plat_on"
	background_icon_state_off = "tremere_power_plat_off"
	power_explanation = "Shoots a blood bolt spell that deals burn damage"
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 75
	cooldown_time = 60 SECONDS
	target_range = 80 // Sniper :)
	power_activates_immediately = FALSE
	prefire_message = "Select your target."

/datum/action/vampire/targeted/bloodbolt/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/living_owner = owner
	check_witnesses(target_atom)
	living_owner.balloon_alert(living_owner, "you fire a blood bolt!")
	living_owner.face_atom(target_atom)
	living_owner.changeNext_move(CLICK_CD_RANGE)
	living_owner.newtonian_move(get_dir(target_atom, living_owner))

	var/obj/projectile/magic/arcane_barrage/vampire/bolt = new(living_owner.loc)
	bolt.vampire_power = src
	bolt.firer = living_owner
	bolt.def_zone = ran_zone(living_owner.get_combat_bodyzone())
	bolt.preparePixelProjectile(target_atom, living_owner)
	INVOKE_ASYNC(bolt, TYPE_PROC_REF(/obj/projectile, fire))

	power_activated_sucessfully()

/**
 * 	# Blood Bolt
 *
 *	This is the projectile this Power will fire.
 */
/obj/projectile/magic/arcane_barrage/vampire
	name = "blood bolt"
	icon_state = "mini_leaper"
	damage = 40
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	var/datum/action/vampire/targeted/bloodbolt/vampire_power

/obj/projectile/magic/arcane_barrage/vampire/on_hit(atom/target_atom)
	new /obj/effect/gibspawner/generic(target_atom.loc)
	if(istype(target_atom, /obj/structure/closet))
		var/obj/structure/closet/hit_closet = target_atom
		hit_closet.welded = FALSE
		hit_closet.locked = FALSE
		hit_closet.broken = TRUE
		hit_closet.update_appearance()
		qdel(src)
		return BULLET_ACT_HIT

	if(istype(target_atom, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target_atom
		airlock.unbolt()
		airlock.open()
		qdel(src)
		return BULLET_ACT_HIT

	if(isliving(target_atom))
		var/mob/living/living_target = target_atom
		living_target.add_splatter_floor(get_turf(living_target))
		living_target.blood_volume -= 50
		living_target.emote("screams")
		living_target.set_jitter(6 SECONDS)
		living_target.Unconscious(3 SECONDS)
		visible_message(span_danger("[living_target]'s wounds spray boiling hot blood!"), "<span class='userdanger'>Oh god it burns!</span>")
		qdel(src)
		return BULLET_ACT_HIT
	. = ..()
