/mob/living/simple_animal/hostile/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage/crates.dmi'
	icon_state = "crate"
	icon_living = "crate"

	response_help_continuous = "touches"
	response_help_simple = "touch"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"
	speed = 0
	maxHealth = 250
	health = 250
	gender = NEUTER
	mob_biotypes = list(MOB_INORGANIC)

	melee_damage = 10
	attack_sound = 'sound/weapons/punch1.ogg'
	emote_taunt = list("growls")
	speak_emote = list("creaks")
	taunt_chance = 30

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list(FACTION_MIMIC)
	move_to_delay = 9
	gold_core_spawnable = NO_SPAWN
	del_on_death = TRUE
	hardattacks = TRUE

	discovery_points = 4000

	var/spawaning_obj_type = null

// Aggro when you try to open them. Will also pickup loot when spawns and drop it when dies.
/mob/living/simple_animal/hostile/mimic/crate
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	speak_emote = list("clatters")
	stop_automated_movement = 1
	wander = FALSE
	var/attempt_open = FALSE
	spawaning_obj_type = /obj/structure/closet/crate
	gold_core_spawnable = HOSTILE_SPAWN

// Pickup loot
/mob/living/simple_animal/hostile/mimic/crate/Initialize(mapload)
	. = ..()
	var/ate_something = list()
	for(var/obj/each_obj in loc)
		if(!isitem(each_obj))
			continue
		if(!mapload)
			ate_something += "[each_obj.name]"
		each_obj.forceMove(src) // nom nom
	if(!mapload && length(ate_something))
		visible_message(span_warning("[src] ate some stuff!"))
		log_game("Newly created mimic-crate ate item(s): [english_list(ate_something)] in [AREACOORD(src)]")
		message_admins("Newly created mimic-crate ate item(s): [english_list(ate_something)] in [ADMIN_VERBOSEJMP(src)]")
	add_overlay("[icon_state]_door")

/mob/living/simple_animal/hostile/mimic/Destroy()
	var/turf_to_spawn = get_turf(src)
	// spawns a crate/a closet/a locker, whatever
	if(spawaning_obj_type && ispath(spawaning_obj_type, /obj/structure/closet))
		var/obj/structure/closet/crate = new spawaning_obj_type(turf_to_spawn)
		crate.opened = TRUE
		crate.locked = FALSE
		crate.update_icon()
	pop_out_stuff()
	. = ..()


/mob/living/simple_animal/hostile/mimic/crate/DestroyPathToTarget()
	..()
	cut_overlays()
	if(prob(90))
		add_overlay("[icon_state]_open")
	else
		add_overlay("[icon_state]_door")

/mob/living/simple_animal/hostile/mimic/crate/ListTargets()
	if(attempt_open)
		return ..()
	return ..(1)

/mob/living/simple_animal/hostile/mimic/crate/FindTarget()
	. = ..()
	if(.)
		trigger()

/mob/living/simple_animal/hostile/mimic/crate/AttackingTarget()
	. = ..()
	if(.)
		cut_overlays()
		add_overlay("[icon_state]_door")

/mob/living/simple_animal/hostile/mimic/crate/proc/trigger()
	if(!attempt_open)
		visible_message("<b>[src]</b> starts to move!")
		attempt_open = TRUE

/mob/living/simple_animal/hostile/mimic/crate/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	trigger()
	. = ..()

/mob/living/simple_animal/hostile/mimic/crate/LoseTarget()
	..()
	cut_overlays()
	add_overlay("[icon_state]_door")



/mob/living/simple_animal/hostile/mimic/proc/pop_out_stuff()
	var/turf_to_spawn = get_turf(src)
	for(var/atom/movable/each_atom in src)
		each_atom.forceMove(turf_to_spawn)
		// for a copied mob, its original version is inside of the mob. This will let it out


/mob/living/simple_animal/hostile/mimic/copy/pop_out_stuff()
	..()
	// death of this mob means the destruction of the original stuff of the copied mob.
	if(istype(original_of_this, /obj/machinery/vending))
		original_of_this.take_damage(original_of_this.max_integrity, BRUTE, 0, FALSE)
		// currently do this to vending machines only.
		// because the destruction of stuff (especially items) is annoying.

GLOBAL_LIST_INIT(protected_objects, list(/obj/structure/table, /obj/structure/cable, /obj/structure/window, /obj/structure/grille))

/mob/living/simple_animal/hostile/mimic/copy
	health = 100
	maxHealth = 100
	var/mob/living/creator = null // the creator
	var/knockdown_people = 0
	var/static/mutable_appearance/googly_eyes = mutable_appearance('icons/mob/mob.dmi', "googly_eyes")
	var/overlay_googly_eyes = TRUE
	var/idledamage = TRUE
	gold_core_spawnable = NO_SPAWN
	var/obj/original_of_this = null

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/simple_animal/hostile/mimic/copy)

/mob/living/simple_animal/hostile/mimic/copy/Initialize(mapload, obj/original, mob/living/creator, destroy_original = 0, no_googlies = FALSE)
	. = ..()
	if (no_googlies)
		overlay_googly_eyes = FALSE
	if(!CopyObject(original, creator, destroy_original))
		stack_trace("something's wrong to create a mimic. It failed to mimic something - [original].")

/mob/living/simple_animal/hostile/mimic/copy/Life(delta_time = SSMOBS_DT, times_fired)
	..()
	if(idledamage && !target && !mind) //Objects eventually revert to normal if no one is around to terrorize
		adjustBruteLoss(0.5 * delta_time)
	for(var/mob/living/M in contents) //a fix for animated statues from the flesh to stone spell
		death()

/mob/living/simple_animal/hostile/mimic/copy/ListTargets()
	. = ..()
	return . - creator

/mob/living/simple_animal/hostile/mimic/copy/wabbajack(what_to_randomize, change_flags = WABBAJACK)
	visible_message(span_warning("[src] resists polymorphing into a new creature!"))

/mob/living/simple_animal/hostile/mimic/copy/proc/ChangeOwner(mob/owner)
	if(owner != creator)
		LoseTarget()
		creator = owner
		faction |= "[REF(owner)]"

/mob/living/simple_animal/hostile/proc/CheckObject(obj/O)
	if(isitem(O) || isstructure(O) || ismachinery(O))
		if(!is_type_in_list(O, GLOB.protected_objects))
			return TRUE
		return FALSE

/mob/living/simple_animal/hostile/mimic/copy/proc/CopyObject(obj/O, mob/living/user, destroy_original = 0)
	if(CheckObject(O) || destroy_original)
		name = O.name
		desc = O.desc
		icon = O.icon
		icon_state = O.icon_state
		icon_living = icon_state
		copy_overlays(O)
		if (overlay_googly_eyes)
			add_overlay(googly_eyes)
		if(isstructure(O) || ismachinery(O))
			health = (anchored * 50) + 50
			if(O.density && O.anchored)
				knockdown_people = 1
				melee_damage *= 2
		else if(isitem(O))
			var/obj/item/I = O
			health = 8 * I.w_class
			melee_damage = 2 + I.force
			move_to_delay = I.w_class + 1
		maxHealth = health
		if(user)
			creator = user
			faction += "[REF(creator)]" // very unique
		if(destroy_original)
			qdel(O)
		else
			O.forceMove(src) // the original object will be hidden inside of this mob
			original_of_this = O
		return TRUE

/mob/living/simple_animal/hostile/mimic/copy/AttackingTarget()
	. = ..()
	if(knockdown_people && . && prob(15) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.Paralyze(40)
		C.visible_message(span_danger("\The [src] knocks down \the [C]!"), \
				span_userdanger("\The [src] knocks you down!"))

/mob/living/simple_animal/hostile/mimic/copy/machine
	speak = list("HUMANS ARE IMPERFECT!", "YOU SHALL BE ASSIMILATED!", "YOU ARE HARMING YOURSELF", "You have been deemed hazardous. Will you comply?", \
				"My logic is undeniable.", "One of us.", "FLESH IS WEAK", "THIS ISN'T WAR, THIS IS EXTERMINATION!")
	speak_chance = 7

/mob/living/simple_animal/hostile/mimic/copy/machine/CanAttack(atom/the_target)
	if(the_target == creator) // Don't attack our creator AI.
		return 0
	if(iscyborg(the_target))
		var/mob/living/silicon/robot/R = the_target
		if(R.connected_ai == creator) // Only attack robots that aren't synced to our creator AI.
			return 0
	return ..()



/mob/living/simple_animal/hostile/mimic/copy/ranged
	var/obj/item/gun/TrueGun = null
	var/obj/item/gun/magic/Zapstick
	var/obj/item/gun/ballistic/Pewgun
	var/obj/item/gun/energy/Zapgun

/mob/living/simple_animal/hostile/mimic/copy/ranged/CopyObject(obj/O, mob/living/creator, destroy_original = 0)
	if(..())
		emote_see = list("aims menacingly")
		obj_damage = 0
		environment_smash = ENVIRONMENT_SMASH_NONE //needed? seems weird for them to do so
		ranged = 1
		retreat_distance = 1 //just enough to shoot
		minimum_distance = 6
		var/obj/item/gun/G = O
		melee_damage = G.force
		move_to_delay = 2 * G.w_class + 1
		projectilesound = G.fire_sound
		TrueGun = G
		if(istype(G, /obj/item/gun/magic))
			Zapstick = G
			var/obj/item/ammo_casing/magic/M = Zapstick.ammo_type
			projectiletype = initial(M.projectile_type)
		if(istype(G, /obj/item/gun/ballistic))
			Pewgun = G
			var/obj/item/ammo_box/magazine/M = Pewgun.mag_type
			casingtype = initial(M.ammo_type)
		if(istype(G, /obj/item/gun/energy))
			Zapgun = G
			var/selectfiresetting = Zapgun.select
			var/obj/item/ammo_casing/energy/E = Zapgun.ammo_type[selectfiresetting]
			projectiletype = initial(E.projectile_type)
		return TRUE

/mob/living/simple_animal/hostile/mimic/copy/ranged/OpenFire(the_target)
	if(Zapgun)
		if(Zapgun.cell)
			var/obj/item/ammo_casing/energy/shot = Zapgun.ammo_type[Zapgun.select]
			if(Zapgun.cell.charge >= shot.e_cost)
				Zapgun.cell.use(shot.e_cost)
				Zapgun.update_icon()
				..()
	else if(Zapstick)
		if(Zapstick.charges)
			Zapstick.charges--
			Zapstick.update_icon()
			..()
	else if(Pewgun)
		if(Pewgun.chambered)
			if(Pewgun.chambered.BB)
				qdel(Pewgun.chambered.BB)
				Pewgun.chambered.BB = null //because qdel takes too long, ensures icon update
				Pewgun.chambered.update_icon()
				..()
			else
				visible_message(span_danger("The <b>[src]</b> clears a jam!"))
			Pewgun.chambered.forceMove(loc) //rip revolver immersions, blame shotgun snowflake procs
			Pewgun.chambered = null
			if(Pewgun.magazine && Pewgun.magazine.stored_ammo.len)
				Pewgun.chambered = Pewgun.magazine.get_round(0)
				Pewgun.chambered.forceMove(Pewgun)
			Pewgun.update_icon()
		else if(Pewgun.magazine && Pewgun.magazine.stored_ammo.len) //only true for pumpguns i think
			Pewgun.chambered = Pewgun.magazine.get_round(0)
			Pewgun.chambered.forceMove(Pewgun)
			visible_message(span_danger("The <b>[src]</b> cocks itself!"))
	else
		ranged = 0 //BANZAIIII
		retreat_distance = 0
		minimum_distance = 1
		return
	icon_state = TrueGun.icon_state
	icon_living = TrueGun.icon_state
