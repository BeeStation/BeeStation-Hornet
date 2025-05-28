
/datum/chemical_reaction/slime
	name = "Abstract Slime Reaction"
	reaction_tags = REACTION_TAG_SLIME
	required_other = TRUE
	var/deletes_extract = TRUE

/datum/chemical_reaction/slime/pre_reaction_other_checks(datum/reagents/holder)
	var/obj/item/slime_extract/extract = holder.my_atom
	if(!istype(extract))
		return FALSE

	return extract.Uses > 0

/datum/chemical_reaction/slime/on_reaction(datum/reagents/holder)
	use_slime_core(holder)

/datum/chemical_reaction/slime/proc/use_slime_core(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, "type")
	if(deletes_extract)
		delete_extract(holder)

/datum/chemical_reaction/slime/proc/delete_extract(datum/reagents/holder)
	var/obj/item/slime_extract/M = holder.my_atom
	if(M.Uses <= 0 && !results.len) //if the slime doesn't output chemicals
		qdel(M)

//Grey
/datum/chemical_reaction/slime/slimespawn
	name = "Slime Spawn"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/slimespawn/on_reaction(datum/reagents/holder)
	var/mob/living/simple_animal/slime/S = new(get_turf(holder.my_atom), "grey")
	S.visible_message(span_danger("Infused with plasma, the core begins to quiver and grow, and a new baby slime emerges from it!"))
	..()

/datum/chemical_reaction/slime/slimeinaprov
	name = "Slime epinephrine"
	results = list(/datum/reagent/medicine/epinephrine = 3)
	required_reagents = list(/datum/reagent/water = 5)
	required_container = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/slimemonkey
	name = "Slime Monkey"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/slimemonkey/on_reaction(datum/reagents/holder)
	for(var/i in 1 to 3)
		new /obj/item/food/monkeycube(get_turf(holder.my_atom))
	..()

//Green
/datum/chemical_reaction/slime/slimemutate
	name = "Mutation Toxin"
	results = list(/datum/reagent/mutationtoxin/jelly = 5)
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slime/unstabletoxin
	name = "Unstable Mutation Toxin"
	results = list(/datum/reagent/mutationtoxin/unstable = 5)
	required_reagents = list(/datum/reagent/uranium/radium = 1)
	required_container = /obj/item/slime_extract/green


//Metal
/datum/chemical_reaction/slime/slimemetal
	name = "Slime Metal"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/metal

/datum/chemical_reaction/slime/slimemetal/on_reaction(datum/reagents/holder)
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/plasteel(location, 5)
	new /obj/item/stack/sheet/iron(location, 15)
	..()

/datum/chemical_reaction/slime/slimeglass
	name = "Slime Glass"
	required_reagents = list(/datum/reagent/water = 1)
	required_container = /obj/item/slime_extract/metal

/datum/chemical_reaction/slime/slimeglass/on_reaction(datum/reagents/holder)
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/rglass(location, 5)
	new /obj/item/stack/sheet/glass(location, 15)
	..()

//Gold
/datum/chemical_reaction/slime/slimemobspawn
	name = "Slime Crit"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/gold
	deletes_extract = FALSE //we do delete, but we don't do so instantly

/datum/chemical_reaction/slime/slimemobspawn/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	summon_mobs(holder, T)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	..()
	M.qdel_timer = addtimer(CALLBACK(src, PROC_REF(delete_extract), holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimemobspawn/proc/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message(span_danger("The slime extract begins to vibrate violently!"))
	addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 5, "Gold Slime", HOSTILE_SPAWN), 50)

/datum/chemical_reaction/slime/slimemobspawn/lesser
	name = "Slime Crit Lesser"
	required_reagents = list(/datum/reagent/blood = 1)

/datum/chemical_reaction/slime/slimemobspawn/lesser/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message(span_danger("The slime extract begins to vibrate violently!"))
	addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 3, "Lesser Gold Slime", HOSTILE_SPAWN, "neutral"), 50)

/datum/chemical_reaction/slime/slimemobspawn/friendly
	name = "Slime Crit Friendly"
	required_reagents = list(/datum/reagent/water = 1)

/datum/chemical_reaction/slime/slimemobspawn/friendly/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message(span_danger("The slime extract begins to vibrate adorably!"))
	addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 1, "Friendly Gold Slime", FRIENDLY_SPAWN, "neutral"), 50)

//Silver
/datum/chemical_reaction/slime/slimebork
	name = "Slime Bork"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/silver

/datum/chemical_reaction/slime/slimebork/on_reaction(datum/reagents/holder)
	//BORK BORK BORK
	var/turf/T = get_turf(holder.my_atom)

	playsound(T, 'sound/effects/phasein.ogg', 100, TRUE)

	for(var/mob/living/carbon/C in viewers(T))
		C.flash_act()

	var/chosen = getbork()
	var/obj/item/food_item = new chosen(T)
	if(prob(5))//Fry it!
		food_item.AddElement(/datum/element/fried_item, rand(15, 60))
	//if(prob(5))//Grill it!
		//food_item.AddElement(/datum/element/grilled_item, rand(30, 100))
	..()

/datum/chemical_reaction/slime/slimebork/proc/getbork()
	return get_random_food()

/datum/chemical_reaction/slime/slimebork/drinks
	name = "Slime Bork 2"
	required_reagents = list(/datum/reagent/water = 1)

/datum/chemical_reaction/slime/slimebork/drinks/getbork()
	return get_random_drink()

//Blue
/datum/chemical_reaction/slime/slimefrost
	name = "Slime Frost Oil"
	results = list(/datum/reagent/consumable/frostoil = 10)
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/blue

/datum/chemical_reaction/slime/slimestabilizer
	name = "Slime Stabilizer"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/blue

/datum/chemical_reaction/slime/slimestabilizer/on_reaction(datum/reagents/holder)
	new /obj/item/slimepotion/slime/stabilizer(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimefoam
	name = "Slime Foam"
	results = list(/datum/reagent/fluorosurfactant = 20, /datum/reagent/water = 20)
	required_reagents = list(/datum/reagent/water = 5)
	required_container = /obj/item/slime_extract/blue

//Dark Blue
/datum/chemical_reaction/slime/slimefreeze
	name = "Slime Freeze"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/darkblue
	deletes_extract = FALSE

/datum/chemical_reaction/slime/slimefreeze/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message(span_danger("The slime extract starts to feel extremely cold!"))
	addtimer(CALLBACK(src, PROC_REF(freeze), holder), 50)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	..()
	M.qdel_timer = addtimer(CALLBACK(src, PROC_REF(delete_extract), holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimefreeze/proc/freeze(datum/reagents/holder)
	if(holder && holder.my_atom)
		var/turf/open/T = get_turf(holder.my_atom)
		if(istype(T))
			T.atmos_spawn_air("n2=50;TEMP=2.7")

/datum/chemical_reaction/slime/slimefireproof
	name = "Slime Fireproof"
	required_reagents = list(/datum/reagent/water = 1)
	required_container = /obj/item/slime_extract/darkblue

/datum/chemical_reaction/slime/slimefireproof/on_reaction(datum/reagents/holder)
	new /obj/item/slimepotion/fireproof(get_turf(holder.my_atom))
	..()

//Orange
/datum/chemical_reaction/slime/slimecasp
	name = "Slime Capsaicin Oil"
	results = list(/datum/reagent/consumable/capsaicin = 10)
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/orange

/datum/chemical_reaction/slime/slimefire
	name = "Slime fire"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/orange
	deletes_extract = FALSE

/datum/chemical_reaction/slime/slimefire/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message(span_danger("The slime extract begins to vibrate adorably!"))
	addtimer(CALLBACK(src, PROC_REF(slime_burn), holder), 50)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	..()
	M.qdel_timer = addtimer(CALLBACK(src, PROC_REF(delete_extract), holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimefire/proc/slime_burn(datum/reagents/holder)
	if(holder && holder.my_atom)
		var/turf/open/T = get_turf(holder.my_atom)
		if(istype(T))
			T.atmos_spawn_air("plasma=50;TEMP=1000")


/datum/chemical_reaction/slime/slimesmoke
	name = "Slime Smoke"
	results = list(/datum/reagent/phosphorus = 10, /datum/reagent/potassium = 10, /datum/reagent/consumable/sugar = 10)
	required_reagents = list(/datum/reagent/water = 5)
	required_container = /obj/item/slime_extract/orange

//Yellow
/datum/chemical_reaction/slime/slimeoverload
	name = "Slime EMP"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/yellow

/datum/chemical_reaction/slime/slimeoverload/on_reaction(datum/reagents/holder, created_volume)
	empulse(get_turf(holder.my_atom), 3, 7, magic=TRUE)
	..()

/datum/chemical_reaction/slime/slimecell
	name = "Slime Power Cell"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/yellow

/datum/chemical_reaction/slime/slimecell/on_reaction(datum/reagents/holder, created_volume)
	new /obj/item/stock_parts/cell/high/slime(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimeglow
	name = "Slime Glow"
	required_reagents = list(/datum/reagent/water = 1)
	required_container = /obj/item/slime_extract/yellow

/datum/chemical_reaction/slime/slimeglow/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message(span_danger("The slime begins to emit a soft light. Squeezing it will cause it to grow brightly."))
	new /obj/item/flashlight/slime(T)
	..()

//Purple
/datum/chemical_reaction/slime/slimepsteroid
	name = "Slime Steroid"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/purple

/datum/chemical_reaction/slime/slimepsteroid/on_reaction(datum/reagents/holder)
	new /obj/item/slimepotion/slime/steroid(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimeregen
	name = "Slime Regen"
	results = list(/datum/reagent/medicine/regen_jelly = 5)
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/purple

//Dark Purple
/datum/chemical_reaction/slime/slimeplasma
	name = "Slime Plasma"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/darkpurple

/datum/chemical_reaction/slime/slimeplasma/on_reaction(datum/reagents/holder)
	new /obj/item/stack/sheet/mineral/plasma(get_turf(holder.my_atom), 3)
	..()

//Red
/datum/chemical_reaction/slime/slimemutator
	name = "Slime Mutator"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/red

/datum/chemical_reaction/slime/slimemutator/on_reaction(datum/reagents/holder)
	new /obj/item/slimepotion/slime/mutator(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimebloodlust
	name = "Bloodlust"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/red

/datum/chemical_reaction/slime/slimebloodlust/on_reaction(datum/reagents/holder)
	for(var/mob/living/simple_animal/slime/slime in viewers(get_turf(holder.my_atom)))
		if(slime.docile) //Undoes docility, but doesn't make rabid.
			slime.visible_message(span_danger("[slime] forgets its training, becoming wild once again!"))
			slime.docile = FALSE
			slime.update_name()
			continue
		slime.rabid = 1
		slime.visible_message(span_danger("The [slime] is driven into a frenzy!"))
	..()

/datum/chemical_reaction/slime/slimespeed
	name = "Slime Speed"
	required_reagents = list(/datum/reagent/water = 1)
	required_container = /obj/item/slime_extract/red

/datum/chemical_reaction/slime/slimespeed/on_reaction(datum/reagents/holder)
	new /obj/item/slimepotion/speed(get_turf(holder.my_atom))
	..()

//Pink
/datum/chemical_reaction/slime/docility
	name = "Docility Potion"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/pink

/datum/chemical_reaction/slime/docility/on_reaction(datum/reagents/holder)
	new /obj/item/slimepotion/slime/docility(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/gender
	name = "Gender Potion"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/pink

/datum/chemical_reaction/slime/gender/on_reaction(datum/reagents/holder)
	new /obj/item/slimepotion/genderchange(get_turf(holder.my_atom))
	..()

//Black
/datum/chemical_reaction/slime/slimemutate2
	name = "Advanced Mutation Toxin"
	results = list(/datum/reagent/aslimetoxin = 5)
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/black

//Oil
/datum/chemical_reaction/slime/slimeexplosion
	name = "Slime Explosion"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/oil
	deletes_extract = FALSE

/datum/chemical_reaction/slime/slimeexplosion/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	var/lastkey = holder.my_atom.fingerprintslast
	var/touch_msg = "N/A"
	if(lastkey)
		var/mob/toucher = get_mob_by_ckey(lastkey)
		touch_msg = "[ADMIN_LOOKUPFLW(toucher)]."
	message_admins("Slime Explosion reaction started at [ADMIN_VERBOSEJMP(T)]. Last Fingerprint: [touch_msg]")
	log_game("Slime Explosion reaction started at [AREACOORD(T)]. Last Fingerprint: [lastkey ? lastkey : "N/A"].")
	T.visible_message(span_danger("The slime extract begins to vibrate violently !"))
	addtimer(CALLBACK(src, PROC_REF(boom), holder), 50)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	..()
	M.qdel_timer = addtimer(CALLBACK(src, PROC_REF(delete_extract), holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimeexplosion/proc/boom(datum/reagents/holder)
	if(holder?.my_atom)
		explosion(get_turf(holder.my_atom), 0, 2, 3)


/datum/chemical_reaction/slime/slimeoil
	name = "Slime Corn Oil"
	results = list(/datum/reagent/consumable/nutriment/fat/oil = 10)
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/oil

//Light Pink
/datum/chemical_reaction/slime/slimepotion2
	name = "Slime Potion 2"
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list(/datum/reagent/toxin/plasma = 1)

/datum/chemical_reaction/slime/slimepotion2/on_reaction(datum/reagents/holder)
	new /obj/item/slimepotion/slime/sentience(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/renaming
	name = "Renaming Potion"
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list(/datum/reagent/water = 1)

/datum/chemical_reaction/slime/renaming/on_reaction(datum/reagents/holder)
	new /obj/item/slimepotion/slime/renaming(holder.my_atom.drop_location())
	..()


//Adamantine
/datum/chemical_reaction/slime/adamantine
	name = "Adamantine"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/adamantine

/datum/chemical_reaction/slime/adamantine/on_reaction(datum/reagents/holder)
	new /obj/item/stack/sheet/mineral/adamantine(get_turf(holder.my_atom))
	..()

//Bluespace
/datum/chemical_reaction/slime/slimefloor2
	name = "Bluespace Floor"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/bluespace

/datum/chemical_reaction/slime/slimefloor2/on_reaction(datum/reagents/holder, created_volume)
	new /obj/item/stack/tile/bluespace(get_turf(holder.my_atom), 25)
	..()


/datum/chemical_reaction/slime/slimecrystal
	name = "Slime Crystal"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/bluespace

/datum/chemical_reaction/slime/slimecrystal/on_reaction(datum/reagents/holder, created_volume)
	var/obj/item/stack/ore/bluespace_crystal/BC = new (get_turf(holder.my_atom))
	BC.visible_message(span_notice("The [BC.name] appears out of thin air!"))
	..()

/datum/chemical_reaction/slime/slimeradio
	name = "Slime Radio"
	required_reagents = list(/datum/reagent/water = 1)
	required_container = /obj/item/slime_extract/bluespace

/datum/chemical_reaction/slime/slimeradio/on_reaction(datum/reagents/holder, created_volume)
	new /obj/item/slimepotion/slime/slimeradio(get_turf(holder.my_atom))
	..()

//Cerulean
/datum/chemical_reaction/slime/slimepsteroid2
	name = "Slime Steroid 2"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/cerulean

/datum/chemical_reaction/slime/slimepsteroid2/on_reaction(datum/reagents/holder)
	new /obj/item/slimepotion/enhancer(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slime_territory
	name = "Slime Territory"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/cerulean

/datum/chemical_reaction/slime/slime_territory/on_reaction(datum/reagents/holder)
	new /obj/item/areaeditor/blueprints/slime(get_turf(holder.my_atom))
	..()

//Sepia
/datum/chemical_reaction/slime/slimestop
	name = "Slime Stop"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/sepia

/datum/chemical_reaction/slime/slimestop/on_reaction(datum/reagents/holder)
	addtimer(CALLBACK(src, PROC_REF(slime_stop), holder), 5 SECONDS)

/datum/chemical_reaction/slime/slimestop/proc/slime_stop(datum/reagents/holder)
	var/obj/item/slime_extract/sepia/extract = holder.my_atom
	var/turf/T = get_turf(holder.my_atom)
	new /obj/effect/timestop(T, null, null, null)
	if(istype(extract))
		if(extract.Uses > 0)
			var/mob/lastheld = get_mob_by_ckey(holder.my_atom.fingerprintslast)
			if(lastheld && !lastheld.equip_to_slot_if_possible(extract, ITEM_SLOT_HANDS, disable_warning = TRUE))
				extract.forceMove(get_turf(lastheld))

	use_slime_core(holder)

/datum/chemical_reaction/slime/slimecamera
	name = "Slime Camera"
	required_reagents = list(/datum/reagent/water = 1)
	required_container = /obj/item/slime_extract/sepia

/datum/chemical_reaction/slime/slimecamera/on_reaction(datum/reagents/holder)
	new /obj/item/camera(get_turf(holder.my_atom))
	new /obj/item/camera_film(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimefloor
	name = "Sepia Floor"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/sepia

/datum/chemical_reaction/slime/slimefloor/on_reaction(datum/reagents/holder)
	new /obj/item/stack/tile/sepia(get_turf(holder.my_atom), 25)
	..()

//Pyrite
/datum/chemical_reaction/slime/slimepaint
	name = "Slime Paint"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/pyrite

/datum/chemical_reaction/slime/slimepaint/on_reaction(datum/reagents/holder)
	var/chosen = pick(subtypesof(/obj/item/paint))
	new chosen(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimecrayon
	name = "Slime Crayon"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/pyrite

/datum/chemical_reaction/slime/slimecrayon/on_reaction(datum/reagents/holder)
	var/chosen = pick(difflist(subtypesof(/obj/item/toy/crayon),typesof(/obj/item/toy/crayon/spraycan)))
	new chosen(get_turf(holder.my_atom))
	..()

//Rainbow :o)
/datum/chemical_reaction/slime/slimeRNG
	name = "Random Core"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/slimeRNG/on_reaction(datum/reagents/holder, created_volume)
	if(created_volume >= 5)
		var/obj/item/grenade/clusterbuster/slime/S = new (get_turf(holder.my_atom))
		S.visible_message(span_danger("Infused with plasma, the core begins to expand uncontrollably!"))
		S.icon_state = "[S.base_state]_active"
		S.active = TRUE
		addtimer(CALLBACK(S, TYPE_PROC_REF(/obj/item/grenade, prime)), rand(15,60))
		qdel(holder.my_atom) //deleto
	else
		var/mob/living/simple_animal/slime/random/S = new (get_turf(holder.my_atom))
		S.visible_message(span_danger("Infused with plasma, the core begins to quiver and grow, and a new baby slime emerges from it!"))
	..()

/datum/chemical_reaction/slime/slimebomb
	name = "Clusterblorble"
	required_reagents = list(/datum/reagent/toxin/slimejelly = 1)
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/slimebomb/on_reaction(datum/reagents/holder, created_volume)
	var/obj/item/grenade/clusterbuster/slime/volatile/S = new (holder.my_atom.loc)
	S.visible_message(span_danger("Infused with slime jelly, the core begins to expand uncontrollably!"))
	S.icon_state = "[S.base_state]_active"
	S.active = TRUE
	addtimer(CALLBACK(S, TYPE_PROC_REF(/obj/item/grenade, prime)), rand(15,60))
	qdel(holder.my_atom) //deleto
	..()

/datum/chemical_reaction/slime/slime_transfer
	name = "Transfer Potion"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/slime_transfer/on_reaction(datum/reagents/holder)
	new /obj/item/slimepotion/transference(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/flight_potion
	name = "Flight Potion"
	required_reagents = list(/datum/reagent/water/holywater = 5, /datum/reagent/uranium = 5)
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime/flight_potion/on_reaction(datum/reagents/holder)
	new /obj/item/reagent_containers/cup/bottle/potion/flight(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/slimeseed
	name = "Seed Creation"
	required_reagents = list(/datum/reagent/medicine/earthsblood = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/darkgreen

/datum/chemical_reaction/slime/slimeseed/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	playsound(T, 'sound/effects/phasein.ogg', 100, TRUE)
	for(var/mob/living/carbon/C in viewers(T))
		C.flash_act()
	var/chosen = getbork()
	new chosen(T)
	..()

/datum/chemical_reaction/slime/slimeseed/proc/getbork()
	return get_random_seed()

/datum/chemical_reaction/slime/slimefertilise
	name = "Slime Fertiliser"
	results = list(/datum/reagent/plantnutriment/slimenutriment = 1)
	required_reagents = list(/datum/reagent/water = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/darkgreen

/datum/chemical_reaction/slime/slimepush
	name = "Slime Repulsion"
	results = list(/datum/reagent/sorium = 5)
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/cobalt

/datum/chemical_reaction/slime/slimepush/on_reaction(datum/reagents/holder)
	holder.chem_temp += 500

/datum/chemical_reaction/slime/slimepull
	name = "Slime Attraction"
	results = list(/datum/reagent/liquid_dark_matter = 5)
	required_reagents = list(/datum/reagent/blood = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/cobalt

/datum/chemical_reaction/slime/slimepull/on_reaction(datum/reagents/holder)
	holder.chem_temp += 500

/datum/chemical_reaction/slime/slimesummonlegion
	name = "Slime Legion"
	required_reagents = list(/datum/reagent/blood = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/darkgrey

/datum/chemical_reaction/slime/slimesummonlegion/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message(span_danger("The slime extract begins to vibrate violently!"))
	addtimer(CALLBACK(src, PROC_REF(slime_legion), holder), 5 SECONDS)

/datum/chemical_reaction/slime/slimesummonlegion/proc/slime_legion(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	playsound(T, 'sound/effects/phasein.ogg', 100, TRUE)
	T.visible_message(span_danger("Skulls and ashen bone burst fourth from the extract with a flash of light!"))
	for(var/mob/living/carbon/C in viewers(T))
		C.flash_act()
	new /mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril(T)

/datum/chemical_reaction/slime/lavasteroid
	name = "Slime Lava Steroid"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/darkgrey

/datum/chemical_reaction/slime/lavasteroid/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	new /obj/item/slimepotion/slime/lavasteroid(T)
	..()

/datum/chemical_reaction/slime/techshell
	name = "Slime Techshell"
	required_reagents = list(/datum/reagent/gunpowder = 5)
	required_other = TRUE
	required_container = /obj/item/slime_extract/crimson

/datum/chemical_reaction/slime/techshell/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	var/list/techshells = list(
		/obj/item/ammo_casing/shotgun/dragonsbreath,
		/obj/item/ammo_casing/shotgun/pulseslug,
		/obj/item/ammo_casing/shotgun/meteorslug,
		/obj/item/ammo_casing/shotgun/frag12,
		/obj/item/ammo_casing/shotgun/ion,
		/obj/item/ammo_casing/shotgun/laserslug
	)
	var/chosen = pick(techshells)
	new chosen(T)
	..()

/datum/chemical_reaction/slime/pyroxadone
	name = "Pyroxadone Generation"
	results = list(/datum/reagent/medicine/pyroxadone = 3)
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/crimson
