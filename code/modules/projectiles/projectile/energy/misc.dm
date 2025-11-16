/obj/projectile/energy/declone
	name = "radiation beam"
	icon_state = "declone"
	damage = 20
	damage_type = CLONE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

/obj/projectile/energy/declone/weak
	damage = 9

/obj/projectile/energy/dart //ninja throwing dart
	name = "dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	paralyze = 100
	range = 7

/obj/projectile/energy/splintergun
	name = "splinter"
	icon_state = ""
	hitscan = TRUE
	damage = 2
	damage_type = BRUTE
	armor_flag = BULLET
	pass_flags = PASSTABLE | PASSGRILLE
	light_color = LIGHT_COLOR_FIRE
	ricochets_max = 0

	tracer_type = /obj/effect/projectile/tracer/laser/emitter/drill
	var/constant_tracer = FALSE

/obj/projectile/energy/splintergun/on_hit(atom/target)
	. = ..()
	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/targetmech = target
		damage = 75 //Increased damage to counter mechs health and armor
		var/internaldamagetype = rand(1, 100)
		targetmech.visible_message(span_danger("The mech blooms with a shower of sparks!"))
		switch(internaldamagetype)
			if(1 to 15)
				targetmech.set_internal_damage(MECHA_INT_TANK_BREACH)
			if(16 to 30)
				targetmech.set_internal_damage(MECHA_INT_SHORT_CIRCUIT)
			if(31 to 45)
				targetmech.set_internal_damage(MECHA_INT_FIRE)
			if(46 to 60)
				targetmech.set_internal_damage(MECHA_INT_CONTROL_LOST)
			if(61 to 75)
				targetmech.set_internal_damage(MECHA_INT_TEMP_CONTROL)
			else
				//25% chance to do nothing extra
				return
		for(var/mob/living/pilot in targetmech.return_occupants())
			if(iscarbon(pilot))
				var/mob/living/carbon/carbonpilot = pilot
				carbonpilot.add_bleeding(BLEED_CUT)
				carbonpilot.apply_damage_type(rand(10,20), BRUTE)
				for(var/i in 1 to 3)
					var/obj/item/shrapnel/spalling = new /obj/item/shrapnel(get_turf(carbonpilot))
					spalling.tryEmbed(carbonpilot) //Mech just got hit by a tungsten splinter moving at mach Jesus, poor pilot is at least going to have a headache
