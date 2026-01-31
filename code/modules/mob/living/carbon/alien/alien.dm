/mob/living/carbon/alien
	name = "alien"
	icon = 'icons/mob/alien.dmi'
	gender = FEMALE //All xenos are girls!!
	dna = null
	faction = list(FACTION_ALIEN)
	sight = SEE_MOBS
	see_in_dark = 4
	verb_say = "hisses"
	initial_language_holder = /datum/language_holder/alien
	bubble_icon = "alien"
	type_of_meat = /obj/item/food/meat/slab/xeno
	status_flags = CANUNCONSCIOUS|CANPUSH
	gib_type = /obj/effect/decal/cleanable/xenoblood/xgibs
	unique_name = 1
	mobchatspan = "alienmobsay"

	var/static/regex/alien_name_regex = new("alien (larva|sentinel|drone|hunter|praetorian|queen)( \\(\\d+\\))?")
	heat_protection = 0.5 // minor heat insulation

	var/leaping = FALSE
	var/move_delay_add = 0 // movement delay to add

/mob/living/carbon/alien/Initialize(mapload)
	add_verb(/mob/living/proc/mob_sleep)
	add_verb(/mob/living/proc/toggle_resting)

	create_bodyparts() //initialize bodyparts
	create_internal_organs()

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	return ..()

/mob/living/carbon/alien/create_internal_organs()
	organs += new /obj/item/organ/brain/alien
	organs += new /obj/item/organ/alien/hivenode
	organs += new /obj/item/organ/tongue/alien
	organs += new /obj/item/organ/eyes/night_vision/alien
	organs += new /obj/item/organ/liver/alien
	organs += new /obj/item/organ/ears
	..()

/mob/living/carbon/alien/assess_threat(judgment_criteria, lasercolor = "", datum/callback/weaponcheck=null) // beepsky won't hunt aliums
	return -10

/mob/living/carbon/alien/handle_environment(datum/gas_mixture/environment, delta_time, times_fired)
	// Run base mob body temperature proc before taking damage
	// this balances body temp to the enviroment and natural stabilization
	. = ..()

	if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		//Body temperature is too hot.
		throw_alert("alien_fire", /atom/movable/screen/alert/alien_fire)
		switch(bodytemperature)
			if(360 to 400)
				apply_damage(HEAT_DAMAGE_LEVEL_1 * delta_time, BURN)
			if(400 to 460)
				apply_damage(HEAT_DAMAGE_LEVEL_2 * delta_time, BURN)
			if(460 to INFINITY)
				if(on_fire)
					apply_damage(HEAT_DAMAGE_LEVEL_3 * delta_time, BURN)
				else
					apply_damage(HEAT_DAMAGE_LEVEL_2 * delta_time, BURN)
	else
		clear_alert("alien_fire")

/mob/living/carbon/alien/reagent_check(datum/reagent/R, delta_time, times_fired) //can metabolize all reagents
	return FALSE

/mob/living/carbon/alien/getTrail()
	if(getBruteLoss() < 200)
		return pick (list("xltrails_1", "xltrails2"))
	else
		return pick (list("xttrails_1", "xttrails2"))
/*----------------------------------------
Proc: AddInfectionImages()
Des: Gives the client of the alien an image on each infected mob.
----------------------------------------*/
/mob/living/carbon/alien/proc/AddInfectionImages()
	if(!client)
		return
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		if(HAS_TRAIT(L, TRAIT_XENO_HOST))
			var/obj/item/organ/body_egg/alien_embryo/A = L.get_organ_by_type(/obj/item/organ/body_egg/alien_embryo)
			if(A)
				var/I = image('icons/mob/alien.dmi', loc = L, icon_state = "infected[A.stage]")
				client.images += I


/*----------------------------------------
Proc: RemoveInfectionImages()
Des: Removes all infected images from the alien.
----------------------------------------*/
/mob/living/carbon/alien/proc/RemoveInfectionImages()
	if(client)
		for(var/image/I in client.images)
			var/searchfor = "infected"
			if(findtext(I.icon_state, searchfor, 1, length(searchfor) + 1))
				client.images -= I
				qdel(I)
	return

/mob/living/carbon/alien/canBeHandcuffed()
	if(num_hands < 2)
		return FALSE
	return TRUE

/mob/living/carbon/alien/proc/alien_evolve(mob/living/carbon/alien/new_xeno)
	visible_message(
		span_noticealien("[src] begins to twist and contort!"),
		span_alertalien("You begin to evolve!"),
	)
	new_xeno.setDir(dir)
	if(!alien_name_regex.Find(name))
		new_xeno.name = name
		new_xeno.real_name = real_name
	if(mind)
		mind.transfer_to(new_xeno)
	qdel(src)

/mob/living/carbon/alien/can_hold_items(obj/item/I)
	return ((I && istype(I, /obj/item/clothing/mask/facehugger)) || (ISADVANCEDTOOLUSER(src) && ..()))

/mob/living/carbon/alien/on_lying_down(new_lying_angle)
	. = ..()
	update_icons()

/mob/living/carbon/alien/on_standing_up()
	. = ..()
	update_icons()
