/obj/item/flashlight/oxycandle
	name = "Oxygen Candle"
	desc = "A standard Nakamura Engineering branded emergency oxygen candle. There are instructions on the side that read: 'Remove lid with provided key, strike key on striker surface, insert lit key into designated marked receptacle, wait 5 minutes or until the candle cools'."
	w_class = WEIGHT_CLASS_MEDIUM
	slot_flags = null
	light_range = 2
	icon_state = "oxycandle"
	inhand_icon_state = "oxycandle"
	actions_types = list()
	custom_price = 20
	/// How many seconds of fuel we have left
	var/fuel = 300
	var/on_damage = 7
	var/produce_heat = 1500
	var/gasmix = "o2=3;co2=1;n2=1.1;water_vapor=0.2;TEMP=345"
	heat = 1000
	light_color = LIGHT_COLOR_TUNGSTEN
	light_system = MOVABLE_LIGHT
	grind_results = list(/datum/reagent/sulfur = 4, /datum/reagent/chlorine = 7, /datum/reagent/sodium = 11)
	custom_materials = list(/datum/material/iron=50, /datum/material/copper=10)
	sound_on = 'sound/items/match_strike.ogg'
	sound_off = null


/obj/item/flashlight/oxycandle/Initialize(mapload)
	. = ..()
	fuel = rand(200,400)

/obj/item/flashlight/oxycandle/process(delta_time)
	open_flame(heat)
	fuel = max(fuel -= delta_time, 0)

	var/turf/open/our_turf = get_turf(src)
	if(!isturf(our_turf))
		return
	our_turf.atmos_spawn_air(gasmix)

	if(fuel <= 0)
		turn_off()

/obj/item/flashlight/oxycandle/proc/turn_off()
	STOP_PROCESSING(SSobj, src)
	on = FALSE
	force = initial(src.force)
	damtype = initial(src.damtype)
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness(null)

	balloon_alert_to_viewers("Fizzles and sputters, slowly cooling back down.")
	remove_emitter("smoke")
	icon_state = "[initial(icon_state)]-empty"

/obj/item/flashlight/oxycandle/attack_self(mob/user)

	// Usual checks
	if(fuel <= 0)
		if(user)
			balloon_alert(user, "out of fuel!")
		return
	if(on)
		if(user)
			balloon_alert(user, "already lit!")
		return

	. = ..()
	// All good, turn it on.
	if(!.)
		user.visible_message(span_notice("[user] lights \the [src]."), span_notice("You light \the [src]!"))
		force = on_damage
		damtype = BURN
		add_emitter(/obj/emitter/flare_smoke, "smoke")
		user.dropItemToGround(src)
		START_PROCESSING(SSobj, src)

/obj/item/flashlight/oxycandle/is_hot()
	return on * heat

/obj/item/flashlight/oxycandle/equipped(mob/user, slot)
	..()
	if(!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	if(C.gloves)
		return
	if(!on)
		return
	var/hit_zone = (C.held_index_to_dir(C.active_hand_index) == "l" ? "l_":"r_") + "arm"
	var/obj/item/bodypart/affecting = C.get_bodypart(hit_zone)
	if(affecting)
		if(affecting.receive_damage(0, rand(10,20)))
			C.update_damage_overlays()
	to_chat(C, span_userdanger("The hot metal burns your bare hand!"))
	user.dropItemToGround(src)
	C.emote("scream")
	return

/obj/item/flashlight/oxycandle/hellfire
	name = "Portable Hellfire"
	desc = "Some crackhead thought this up, surely. But... why is it so professionally made?"
	light_range = 7
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	gasmix = "o2=5;plasma=10;TEMP=700"
	icon_state = "hellcandle"
	inhand_icon_state = "hellcandle"

/obj/item/flashlight/oxycandle/hellfire/Initialize(mapload)
	. = ..()
	fuel = 10
