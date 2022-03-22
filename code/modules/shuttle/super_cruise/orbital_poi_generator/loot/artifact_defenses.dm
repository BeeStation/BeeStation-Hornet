/obj/structure/alien_artifact
	name = "alien artifact structure"
	icon = 'icons/obj/artifact.dmi'
	max_integrity = 100
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE

/obj/structure/alien_artifact/ComponentInitialize()
	AddComponent(/datum/component/discoverable, 20000)

//Watcher
//Triggers nearby defenses when motion is detected
/obj/structure/alien_artifact/watcher
	name = "watcher"
	desc = "It sends a shiver down your spine."
	icon_state = "watcher"
	var/cooldown = 0

/obj/structure/alien_artifact/watcher/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, rand(3, 6))
	var/turf/T = get_turf(src)
	var/list/turfs = RANGE_TURFS(2, T)
	var/list/valid_turfs = list()
	for(var/turf/open/floor/F in turfs)
		if(locate(/obj/structure) in F)
			continue
		valid_turfs += F
	//Shuffle the list
	shuffle_inplace(valid_turfs)
	new /obj/structure/alien_artifact/protector(valid_turfs[1])

/obj/structure/alien_artifact/watcher/HasProximity(atom/movable/AM)
	if(cooldown > world.time)
		return
	if (iseffect(AM) || isprojectile(AM))
		return
	cooldown = world.time + 50
	//Trigger nearby protectors
	for(var/obj/structure/alien_artifact/protector/protector in view(6, src))
		protector.trigger(AM)

//Protectors
/obj/structure/alien_artifact/protector
	name = "protector"
	desc = "A strange artifact developed centuries ago by beings that are now beyond us."
	icon_state = "protector"
	max_integrity = 200
	var/active = FALSE
	var/datum/protector_effect/effect

/obj/structure/alien_artifact/protector/Initialize(mapload)
	. = ..()
	var/effect_type = pick(subtypesof(/datum/protector_effect))
	effect = new effect_type()

/obj/structure/alien_artifact/protector/proc/trigger(atom/movable/target)
	if(active)
		return
	active = TRUE
	flick("protector_pulse", src)
	var/turf/target_location = get_turf(target)
	addtimer(CALLBACK(src, .proc/reset_cooldown), 1.5 SECONDS)
	sleep(1 SECONDS)
	effect.trigger(src, get_turf(src), target, target_location)

/obj/structure/alien_artifact/protector/proc/reset_cooldown()
	active = FALSE

//Protector effects

/datum/protector_effect/proc/trigger(obj/source, turf/source_location, atom/movable/target, turf/target_location)
	return

/datum/protector_effect/hierophant_chasers/trigger(obj/source, turf/source_location, atom/movable/target, turf/target_location)
	playsound(source_location,'sound/machines/airlockopen.ogg', 200, 1)
	source.visible_message("<span class='hierophant'>\"Mx gerrsx lmhi.\"</span>")
	var/obj/effect/temp_visual/hierophant/chaser/C = new(source_location, source, target, 3, FALSE)
	C.moving = 3
	C.moving_dir = pick(GLOB.cardinals)
	C.damage = 10

/datum/protector_effect/hierophant_burst/trigger(obj/source, turf/source_location, atom/movable/target, turf/target_location)
	playsound(source_location,'sound/machines/airlockopen.ogg', 200, 1)
	source.visible_message("<span class='hierophant'>\"Irkekmrk hijirwmzi tvsxsgspw.\"</span>")
	protector_burst(null, get_turf(target), 1)

/datum/protector_effect/hierophant_burst_self/trigger(obj/source, turf/source_location, atom/movable/target, turf/target_location)
	playsound(source_location,'sound/machines/airlockopen.ogg', 200, 1)
	source.visible_message("<span class='hierophant'>\"Yrorsar irxmxc hixigxih.\"</span>")
	protector_burst(null, source_location, 2)

/datum/protector_effect/emp_attack/trigger(obj/source, turf/source_location, atom/movable/target, turf/target_location)
	playsound(source_location,'sound/machines/airlockopen.ogg', 200, 1)
	source_location.visible_message("<span class='hierophant'>\"Svhivw vigmizih.\"</span>")
	new /obj/effect/temp_visual/hierophant/blast/defenders(target_location, src, FALSE)
	sleep(0.5 SECONDS)
	empulse(target_location, 0, 2)

//expanding square designed for the artifact defenders
/proc/protector_burst(mob/caster, turf/original, burst_range)
	playsound(original,'sound/machines/airlockopen.ogg', 200, 1)
	var/last_dist = 0
	for(var/turf/T as() in spiral_range_turfs(burst_range, original))
		if(!T)
			continue
		var/dist = get_dist(original, T)
		if(dist > last_dist)
			last_dist = dist
			sleep(1 + min(burst_range - last_dist, 12)) //gets faster as it gets further out
		new /obj/effect/temp_visual/hierophant/blast/defenders(T, caster, FALSE)

/obj/effect/temp_visual/hierophant/blast/defenders
	damage = 7
	duration = 1.2 SECONDS
