/obj/structure/alien_artifact
	name = "alien artifact structure"
	icon = 'icons/obj/artifact.dmi'
	max_integrity = 200
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

/obj/structure/alien_artifact/watcher/Initialize()
	. = ..()
	proximity_monitor = new(src, rand(3, 6))
	var/turf/T = get_turf(src)
	var/list/turfs = RANGE_TURFS(5, T)
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
	if (istype(AM, /obj/effect))
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
	max_integrity = 500
	var/active = FALSE
	var/datum/protector_effect/effect

/obj/structure/alien_artifact/protector/Initialize()
	. = ..()
	var/effect_type = pick(subtypesof(/datum/protector_effect))
	effect = new effect_type()

/obj/structure/alien_artifact/protector/proc/trigger(atom/movable/target)
	if(active)
		return
	active = TRUE
	flick("protector_pulse", src)
	sleep(7.2)
	effect.trigger(src, get_turf(src), target)
	sleep(3.6)
	active = FALSE

//Protector effects

/datum/protector_effect/proc/trigger(obj/source, turf/T, atom/movable/target)
	return

/datum/protector_effect/hierophant_chasers/trigger(obj/source, turf/T, atom/movable/target)
	playsound(T,'sound/machines/airlockopen.ogg', 200, 1)
	source.visible_message("<span class='hierophant'>\"Mx gerrsx lmhi.\"</span>")
	var/obj/effect/temp_visual/hierophant/chaser/C = new(T, source, target, 3, FALSE)
	C.moving = 3
	C.moving_dir = pick(GLOB.cardinals)
	C.damage = 20

/datum/protector_effect/hierophant_burst/trigger(obj/source, turf/T, atom/movable/target)
	playsound(T,'sound/machines/airlockopen.ogg', 200, 1)
	source.visible_message("<span class='hierophant'>\"Irkekmrk hijirwmzi tvsxsgspw.\"</span>")
	hierophant_burst(null, get_turf(target), 4)

/datum/protector_effect/hierophant_burst_self/trigger(obj/source, turf/T, atom/movable/target)
	playsound(T,'sound/machines/airlockopen.ogg', 200, 1)
	source.visible_message("<span class='hierophant'>\"Yrorsar irxmxc hixigxih.\"</span>")
	hierophant_burst(null, T, 7)

/datum/protector_effect/emp_stun/trigger(obj/source, turf/T, atom/movable/target)
	playsound(TAIL_SWEEP_COMBO,'sound/machines/airlockopen.ogg', 200, 1)
	T.visible_message("<span class='hierophant'>\"Svhivw vigmizih.\"</span>")
	empulse(T, 2, 6)
	if(isliving(target))
		var/mob/living/L = target
		L.Paralyze(50)
		L.take_overall_damage(burn=10, stamina=30)
