/**********************Resonator**********************/
/obj/item/resonator
	name = "resonator"
	icon = 'icons/obj/mining.dmi'
	icon_state = "resonator"
	item_state = "resonator"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	desc = "A handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It does increased damage in low pressure."
	w_class = WEIGHT_CLASS_NORMAL
	force = 15
	throwforce = 10
	var/charge_time = 15
	var/fieldlimit = 4
	var/list/fields = list()
	var/quick_burst_mod = 0.8
	var/charged = TRUE
	var/trap_mode = FALSE

/obj/item/resonator/upgraded
	name = "upgraded resonator"
	desc = "An upgraded version of the resonator that can produce more fields at once, as well as having no damage penalty for bursting a resonance field early."
	icon_state = "resonator_u"
	item_state = "resonator_u"
	fieldlimit = 6
	charge_time = 8
	quick_burst_mod = 1

/obj/item/resonator/attack_self(mob/user) //Was tooo shitty
	for(var/obj/effect/temp_visual/resonance/field in fields)
		field.damage_multiplier = quick_burst_mod
		field.burst()
	to_chat(user, "<span class='info'>You activate your resonator's remote detonator and rupture all the fields at once.</span>")

/obj/item/resonator/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	. = ..()
	if(charged && length(fields) < fieldlimit)
		var/turf/proj_turf = user.loc
		if(!isturf(proj_turf))
			return
		var/obj/item/projectile/resonator/D = new /obj/item/projectile/resonator(proj_turf)
		if(trap_mode)
			D.rupture_time = 50
			D.name = "resonating force"
		D.preparePixelProjectile(target, user, clickparams)
		D.firer = user
		D.resonator = src
		playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, 1)
		D.fire()
		charged = FALSE
		update_icon()
		addtimer(CALLBACK(src, .proc/Recharge), charge_time)
		return

/obj/item/resonator/AltClick(mob/user)
	to_chat(user, "<span class='info'>You switched [src] to [trap_mode ? "mining":"trapping"] mode.</span>")
	trap_mode = !trap_mode
	. = ..()

/obj/item/resonator/proc/Recharge()
	charged = TRUE

/obj/item/projectile/resonator
	name = "resonating force"
	icon_state = "holoball"
	damage = 5 //We're just here to create resonators. Small damage through, but not for mobs
	damage_type = BRUTE
	flag = "bomb"
	speed = 4 //Pretty fucking slow
	range = 6
	log_override = TRUE
	var/rupture_time = 10
	var/obj/item/resonator/resonator

/obj/item/projectile/resonator/on_hit(atom/target, blocked = FALSE)
	if(isturf(target))
		new/obj/effect/temp_visual/resonance(target, firer, resonator, rupture_time)
	else
		new/obj/effect/temp_visual/resonance(get_turf(target), firer, resonator, rupture_time)

	if(ismob(target))
		damage = 0
		nodamage = TRUE
	else
		damage = 5
		nodamage = FALSE
	. = ..()

//resonance field, crushes rock, damages mobs
/obj/effect/temp_visual/resonance
	name = "resonance field"
	desc = "A resonating field that significantly damages anything inside of it when the field eventually ruptures. More damaging in low pressure environments."
	icon_state = "shield1"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 10
	var/resonance_damage = 10 //Nerfed the damage
	var/damage_multiplier = 1
	var/creator
	var/obj/item/resonator/res

/obj/effect/temp_visual/resonance/Initialize(mapload, set_creator, set_resonator, set_duration)
	duration = set_duration
	. = ..()
	creator = set_creator
	res = set_resonator
	if(res)
		res.fields += src
	playsound(src,'sound/weapons/resonator_fire.ogg',50,1)
	transform = matrix()*0.75
	animate(src, transform = matrix()*1.5, time = duration)
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, .proc/burst), duration, TIMER_STOPPABLE)

/obj/effect/temp_visual/resonance/Destroy()
	if(res)
		res.fields -= src
		res = null
	creator = null
	. = ..()

/obj/effect/temp_visual/resonance/proc/check_pressure(turf/proj_turf)
	if(!proj_turf)
		proj_turf = get_turf(src)
	resonance_damage = initial(resonance_damage)
	if(lavaland_equipment_pressure_check(proj_turf))
		name = "strong [initial(name)]"
		resonance_damage *= 4.5
	else
		name = initial(name)
	resonance_damage *= damage_multiplier

/obj/effect/temp_visual/resonance/proc/burst()
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/resonance_crush(T)
	if(ismineralturf(T))
		var/turf/closed/mineral/M = T
		M.gets_drilled(creator)
	check_pressure(T)
	playsound(T,'sound/weapons/resonator_blast.ogg',50,1)
	for(var/mob/living/L in T)
		if(creator)
			log_combat(creator, L, "used a resonator field on", "resonator")
		to_chat(L, "<span class='userdanger'>[src] ruptured with you in it!</span>")
		L.apply_damage(resonance_damage, BRUTE)
	qdel(src)

/obj/effect/temp_visual/resonance_crush
	icon_state = "shield1"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 4

/obj/effect/temp_visual/resonance_crush/Initialize()
	. = ..()
	transform = matrix()*1.5
	animate(src, transform = matrix()*0.1, alpha = 50, time = 4)
