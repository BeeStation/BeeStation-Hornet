/obj/structure/alien_artifact
	name = "alien artifact structure"
	icon = 'icons/obj/artifact.dmi'
	max_integrity = 100
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE

/obj/structure/alien_artifact/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/discoverable, 20000)

//Watcher
//Triggers nearby defenses when motion is detected
/obj/structure/alien_artifact/watcher
	name = "watcher"
	desc = "It sends a shiver down your spine."
	icon_state = "watcher"
	var/cooldown = 0
	var/range //Trigger range
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor

/obj/structure/alien_artifact/watcher/Initialize(mapload)
	. = ..()
	range = rand(3, 6)
	proximity_monitor = new(src, range)
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
	if(cooldown > world.time || iseffect(AM) || isprojectile(AM) || !(locate(AM) in view(range ,src)))
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
	addtimer(CALLBACK(effect, PROC_REF(trigger), src, get_turf(src), target, target_location), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), 1.5 SECONDS)

/obj/structure/alien_artifact/protector/proc/reset_cooldown()
	active = FALSE

//Protector effects

/datum/protector_effect/proc/trigger(obj/source, turf/source_location, atom/movable/target, turf/target_location)
	return

/datum/protector_effect/hierophant_chasers/trigger(obj/source, turf/source_location, atom/movable/target, turf/target_location)
	playsound(source_location,'sound/machines/airlockopen.ogg', 200, 1)
	source.visible_message(span_hierophant("\"Mx gerrsx lmhi.\""))
	var/obj/effect/temp_visual/hierophant/chaser/C = new(source_location, source, target, 3, FALSE)
	C.moving = 3
	C.moving_dir = pick(GLOB.cardinals)
	C.damage = 10

/datum/protector_effect/hierophant_burst/trigger(obj/source, turf/source_location, atom/movable/target, turf/target_location)
	playsound(source_location,'sound/machines/airlockopen.ogg', 200, 1)
	source.visible_message(span_hierophant("\"Irkekmrk hijirwmzi tvsxsgspw.\""))
	INVOKE_ASYNC(src, PROC_REF(protector_burst), null, get_turf(target), 1)

/datum/protector_effect/hierophant_burst_self/trigger(obj/source, turf/source_location, atom/movable/target, turf/target_location)
	playsound(source_location,'sound/machines/airlockopen.ogg', 200, 1)
	source.visible_message(span_hierophant("\"Yrorsar irxmxc hixigxih.\""))
	INVOKE_ASYNC(src, PROC_REF(protector_burst), null, source_location, 2)

/datum/protector_effect/emp_attack/trigger(obj/source, turf/source_location, atom/movable/target, turf/target_location)
	playsound(source_location,'sound/machines/airlockopen.ogg', 200, 1)
	source_location.visible_message(span_hierophant("\"Svhivw vigmizih.\""))
	new /obj/effect/temp_visual/hierophant/blast/defenders/emp(target_location, src, FALSE)

//expanding square designed for the artifact defenders
/datum/protector_effect/proc/protector_burst(mob/caster, turf/original, burst_range)
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

//Weakened Blasts for artifacts.
/obj/effect/temp_visual/hierophant/blast/defenders
	damage = 7
	duration = 1.2 SECONDS

/obj/effect/temp_visual/hierophant/blast/defenders/emp
	duration = 1 SECONDS

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/temp_visual/hierophant/blast/defenders/emp)

/obj/effect/temp_visual/hierophant/blast/defenders/emp/Initialize(mapload, new_caster, friendly_fire)
	. = ..()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(empulse), src.loc, 1, 2), 1 SECONDS)
