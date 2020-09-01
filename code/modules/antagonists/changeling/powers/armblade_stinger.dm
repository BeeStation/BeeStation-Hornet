/***************************************\
|***********ARM BLADE STINGER***********|
\***************************************/

/datum/action/changeling/weapon/arm_stinger
	name = "Stinger"
	desc = "A more exotic form of the Armblade, adapted to incapacitate targets instead of killing them. Can be loaded with chemicals. Costs 30 chemicals."
	helptext = "We may retract our armblade in the same manner as we form it. Cannot be used while in lesser form."
	button_icon_state = "tentacle"
	chemical_cost = 30
	dna_cost = 2
	req_human = 1
	weapon_type = /obj/item/melee/stingblade
	weapon_name_simple = "stinger"
	
// default armblade data
/obj/item/melee/stingblade
	name = "stinger"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 5	//considerably reduced
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	block_power = 20
	block_level = 1
	block_upgrade_walk = 1
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("stung", "injected", "stabbed")
	sharpness = IS_SHARP
	var/volume = 30
	var/list/list_reagents = null

/obj/item/melee/stingblade/Initialize(mapload,silent,synthetic)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc) && !silent)
		loc.visible_message("<span class='warning'>A grotesque blade forms around [loc.name]\'s arm!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a deadly blade.</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")
	AddComponent(/datum/component/butchering, 60, 80)

/obj/item/melee/stingblade/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !iscarbon(M))
		return
		
	//inject carbon entities by default
	imp_in.reagents.add_reagent(/datum/reagent/medical/tirizene, 2)
	log_combat(user, M, "injected", src, "5u tirizene")
	
	if(!reagents.total_volume) //it is empty
		return

	//Always log attemped injects for admins
	var/list/injected = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		injected += R.name
	var/contained = english_list(injected)
	log_combat(user, M, "attempted to inject", src, "([contained])")

	if(reagents.total_volume && M.can_inject(user, 1)) 
		
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
		reagents.reaction(M, INJECT, fraction)
		if(M.reagents)
			var/trans = reagents.copy_to(M, amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>[trans] unit\s injected.  [reagents.total_volume] unit\s remaining in [src].</span>")
			log_combat(user, M, "stingblade injected", src, "([contained])")
	
	//default armblade functionality
	if(istype(target, /obj/structure/table))
		var/obj/structure/table/T = target
		T.deconstruct(FALSE)

	else if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/C = target
		C.attack_alien(user) //muh copypasta
		
	//Maybe remove the functionality of the armblade, given this is not actually an armblade
	/*else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if((!A.requiresID() || A.allowed(user)) && A.hasPower()) //This is to prevent stupid shit like hitting a door with an arm blade, the door opening because you have acces and still getting a "the airlocks motors resist our efforts to force it" message, power requirement is so this doesn't stop unpowered doors from being pried open if you have access
			return
		if(A.locked)
			to_chat(user, "<span class='warning'>The airlock's bolts prevent it from being forced!</span>")
			return

		if(A.hasPower())
			user.visible_message("<span class='warning'>[user] jams [src] into the airlock and starts prying it open!</span>", "<span class='warning'>We start forcing the [A] open.</span>", \
			"<span class='italics'>You hear a metal screeching sound.</span>")
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 100, 1)
			if(!do_after(user, 100, target = A))
				return
		//user.say("Heeeeeeeeeerrre's Johnny!")
		user.visible_message("<span class='warning'>[user] forces the airlock to open with [user.p_their()] [src]!</span>", "<span class='warning'>We force the [A] to open.</span>", \
		"<span class='italics'>You hear a metal screeching sound.</span>")
		A.open(2)*/
	
/obj/item/melee/stingblade/is_refillable()	
	. = ..()
	