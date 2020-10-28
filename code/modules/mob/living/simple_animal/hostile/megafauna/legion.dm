/*
LEGION
Legion spawns from the necropolis gate in the far north of lavaland. It is the guardian of the Necropolis and emerges from within whenever an intruder tries to enter through its gate.
Whenever Legion emerges, everything in lavaland will receive a notice via color, audio, and text. This is because Legion is powerful enough to slaughter the entirety of lavaland with little effort.
It has two attack modes that it constantly rotates between.
In ranged mode, it will behave like a normal legion - retreating when possible and firing legion skulls at the target.
In charge mode, it will spin and rush its target, attacking with melee whenever possible.
When Legion dies, it drops a staff of storms, which allows its wielder to call and disperse ash storms at will and functions as a powerful melee weapon.
Difficulty: Medium
*/

/mob/living/simple_animal/hostile/megafauna/legion
	name = "Legion"
	health = 800
	maxHealth = 800
	icon_state = "legion"
	icon_living = "legion"
	desc = "One of many."
	icon = 'icons/mob/lavaland/legion.dmi'
	attacktext = "chomps"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	speak_emote = list("echoes")
	armour_penetration = 50
	melee_damage = 25
	speed = 5
	ranged = TRUE
	del_on_death = TRUE
	retreat_distance = 5
	minimum_distance = 5
	ranged_cooldown_time = 20
	var/size = 5
	var/charging = FALSE
	gps_name = "Echoing Signal"
	medal_type = BOSS_MEDAL_LEGION
	score_type = LEGION_SCORE
	pixel_y = -90
	pixel_x = -75
	loot = list(/obj/item/stack/sheet/bone = 3)
	vision_range = 13
	wander = FALSE
	elimination = TRUE
	appearance_flags = 0
	mouse_opacity = MOUSE_OPACITY_ICON
	attack_action_types = list(/datum/action/innate/megafauna_attack/create_skull,
							   /datum/action/innate/megafauna_attack/charge_target)
	small_sprite_type = /datum/action/small_sprite/megafauna/legion

/datum/action/innate/megafauna_attack/create_skull
	name = "Create Legion Skull"
	icon_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	button_icon_state = "legion_head"
	chosen_message = "<span class='colossus'>You are now creating legion skulls.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/charge_target
	name = "Charge Target"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now charging at your target.</span>"
	chosen_attack_num = 2

/mob/living/simple_animal/hostile/megafauna/legion/OpenFire(the_target)
	if(charging)
		return
	ranged_cooldown = world.time + ranged_cooldown_time

	if(client)
		switch(chosen_attack)
			if(1)
				create_legion_skull()
			if(2)
				charge_target()
		return

	if(prob(75))
		create_legion_skull()
	else
		charge_target()

/mob/living/simple_animal/hostile/megafauna/legion/proc/create_legion_skull()
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/A = new(loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction

/mob/living/simple_animal/hostile/megafauna/legion/proc/charge_target()
	visible_message("<span class='warning'><b>[src] charges!</b></span>")
	SpinAnimation(speed = 20, loops = 5)
	ranged = FALSE
	retreat_distance = 0
	minimum_distance = 0
	set_varspeed(0)
	charging = TRUE
	addtimer(CALLBACK(src, .proc/reset_charge), 50)

/mob/living/simple_animal/hostile/megafauna/legion/GiveTarget(new_target)
	. = ..()
	if(target)
		wander = TRUE

/mob/living/simple_animal/hostile/megafauna/legion/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(GLOB.necropolis_gate && true_spawn)
		GLOB.necropolis_gate.toggle_the_gate(null, TRUE) //very clever.
	return ..()

/mob/living/simple_animal/hostile/megafauna/legion/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/L = target
		if(L.stat == UNCONSCIOUS)
			var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/A = new(loc)
			A.infest(L)

/mob/living/simple_animal/hostile/megafauna/legion/proc/reset_charge()
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	set_varspeed(2)
	charging = FALSE

/mob/living/simple_animal/hostile/megafauna/legion/death()
	if(health > 0)
		return
	if(size > 1)
		adjustHealth(-maxHealth) //heal ourself to full in prep for splitting
		var/mob/living/simple_animal/hostile/megafauna/legion/L = new(loc)

		L.maxHealth = round(maxHealth * 0.6,DAMAGE_PRECISION)
		maxHealth = L.maxHealth

		L.health = L.maxHealth
		health = maxHealth

		size--
		L.size = size

		L.resize = L.size * 0.2
		transform = initial(transform)
		resize = size * 0.2

		L.update_transform()
		update_transform()

		L.faction = faction.Copy()

		L.GiveTarget(target)

		visible_message("<span class='boldannounce'>[src] splits in twain!</span>")
	else
		var/last_legion = TRUE
		for(var/mob/living/simple_animal/hostile/megafauna/legion/other in GLOB.mob_living_list)
			if(other != src)
				last_legion = FALSE
				break
		if(last_legion)
			loot = list(/obj/item/staff/storm)
			elimination = FALSE
		else if(prob(5))
			loot = list(/obj/structure/closet/crate/necropolis/tendril)
		if(!true_spawn)
			loot = null
		..()

//Loot

/obj/item/staff/storm
	name = "staff of storms"
	desc = "An ancient staff retrieved from the remains of Legion. The wind stirs as you move it."
	icon_state = "staffofstorms"
	item_state = "staffofstorms"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	var/storm_type = /datum/weather/ash_storm
	var/storm_cooldown = 0
	var/static/list/excluded_areas = list(/area/reebe/city_of_cogs)

/obj/item/staff/storm/attack_self(mob/user)
	if(storm_cooldown > world.time)
		to_chat(user, "<span class='warning'>The staff is still recharging!</span>")
		return

	var/area/user_area = get_area(user)
	var/turf/user_turf = get_turf(user)
	if(!user_area || !user_turf || (user_area.type in excluded_areas))
		to_chat(user, "<span class='warning'>Something is preventing you from using the staff here.</span>")
		return
	var/datum/weather/A
	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if((user_turf.z in W.impacted_z_levels) && W.area_type == user_area.type)
			A = W
			break

	if(A)
		if(A.stage != END_STAGE)
			if(A.stage == WIND_DOWN_STAGE)
				to_chat(user, "<span class='warning'>The storm is already ending! It would be a waste to use the staff now.</span>")
				return
			user.visible_message("<span class='warning'>[user] holds [src] skywards as an orange beam travels into the sky!</span>", \
			"<span class='notice'>You hold [src] skyward, dispelling the storm!</span>")
			playsound(user, 'sound/magic/staff_change.ogg', 200, 0)
			A.wind_down()
			log_game("[user] ([key_name(user)]) has dispelled a storm at [AREACOORD(user_turf)]")
			return
	else
		A = new storm_type(list(user_turf.z))
		A.name = "staff storm"
		log_game("[user] ([key_name(user)]) has summoned [A] at [AREACOORD(user_turf)]")
		if (is_special_character(user))
			message_admins("[A] has been summoned in [ADMIN_VERBOSEJMP(user_turf)] by [ADMIN_LOOKUPFLW(user)], a non-antagonist")
		A.area_type = user_area.type
		A.telegraph_duration = 100
		A.end_duration = 100

	user.visible_message("<span class='warning'>[user] holds [src] skywards as red lightning crackles into the sky!</span>", \
	"<span class='notice'>You hold [src] skyward, calling down a terrible storm!</span>")
	playsound(user, 'sound/magic/staff_change.ogg', 200, 0)
	A.telegraph()
	storm_cooldown = world.time + 200
