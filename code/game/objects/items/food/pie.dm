
/obj/item/food/pie
	icon = 'icons/obj/food/piecake.dmi'
	bite_consumption = 3
	w_class = WEIGHT_CLASS_NORMAL
	max_volume = 80
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("pie" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2
	/// type is spawned 5 at a time and replaces this pie when processed by cutting tool
	var/obj/item/food/pieslice/slice_type
	/// so that the yield can change if it isnt 5
	var/yield = 5

/obj/item/food/pie/make_processable()
	if (slice_type)
		AddElement(/datum/element/processable, TOOL_KNIFE, slice_type, yield, table_required = TRUE, screentip_verb = "Slice")

/obj/item/food/pieslice
	name = "pie slice"
	icon = 'icons/obj/food/piecake.dmi'
	w_class = WEIGHT_CLASS_TINY
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("pie" = 1, "uncertainty" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pie/plain
	name = "plain pie"
	desc = "A simple pie, still delicious."
	icon_state = "pie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("pie" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pie/cream
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/banana = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("pie" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR
	var/stunning = TRUE
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/cream/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!.) //if we're not being caught
		splat(hit_atom)

/obj/item/food/pie/cream/proc/splat(atom/movable/hit_atom)
	if(isliving(loc)) //someone caught us!
		return
	var/turf/hit_turf = get_turf(hit_atom)
	new/obj/effect/decal/cleanable/food/pie_smudge(hit_turf)
	if(reagents?.total_volume)
		reagents.expose(hit_atom, TOUCH)
	var/is_creamable = TRUE
	if(isliving(hit_atom))
		var/mob/living/living_target_getting_hit = hit_atom
		if(stunning)
			living_target_getting_hit.Paralyze(20) //splat!
		if(iscarbon(living_target_getting_hit))
			is_creamable = !!(living_target_getting_hit.get_bodypart(BODY_ZONE_HEAD)) // maybe you need a head to get pied, yeah?
		if(is_creamable)
			living_target_getting_hit.adjust_blurriness(1)
		living_target_getting_hit.visible_message(span_warning("[living_target_getting_hit] is creamed by [src]!"), span_userdanger("You've been creamed by [src]!"))
		playsound(living_target_getting_hit, "desceration", 50, TRUE)
	if(is_creamable && is_type_in_typecache(hit_atom, GLOB.creamable))
		hit_atom.AddComponent(/datum/component/creamed, src)
	qdel(src)

/obj/item/food/pie/cream/nostun
	stunning = FALSE


/obj/item/food/pie/cream/body

/obj/item/food/pie/cream/body/Destroy()
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		A.forceMove(T)
		A.throw_at(T, 1, 1)
	. = ..()

/*
/obj/item/food/pie/cream/body/proc/on_consume(mob/living/carbon/M)
	if(!reagents.total_volume) //so that it happens on the last bite
		if(iscarbon(M) && contents.len)
			var/turf/T = get_turf(src)
			for(var/atom/movable/A in contents)
				A.forceMove(T)
				A.throw_at(T, 1, 1)
				M.visible_message("[src] bursts out of [M]!</span>")
			M.emote("scream")
			M.Knockdown(40)
			M.adjustBruteLoss(60)
	return ..()
*/

/obj/item/food/pie/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/berryjuice = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	slice_type = /obj/item/food/pieslice/berry
	tastes = list("pie" = 1, "blackberries" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/berry
	name = "berry clafoutis slice"
	desc = "A slice of berry clafoutis."
	icon_state = "berryclafoutis_slice"
	tastes = list("pie" = 1, "blackberries" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/bearypie
	name = "beary pie"
	desc = "No brown bears, this is a good sign."
	icon_state = "bearypie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	slice_type = /obj/item/food/pieslice/beary
	tastes = list("pie" = 1, "meat" = 1, "salmon" = 1)
	foodtypes = GRAIN | SUGAR | MEAT | FRUIT // so weird
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pieslice/beary
	name = "beary pie slice"
	desc = "A slice of beary pie."
	icon_state = "bearypie_slice"
	tastes = list("pie" = 1, "meat" = 1, "salmon" = 1)
	foodtypes = GRAIN | SUGAR | MEAT | FRUIT
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pie/meatpie
	name = "meat-pie"
	icon_state = "meatpie"
	desc = "An old barber's recipe, very delicious!"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	slice_type = /obj/item/food/pieslice/meat
	tastes = list("pie" = 1, "meat" = 1)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/meat
	name = "meat-pie slice"
	desc = "Oh nice, meat pie!"
	icon_state = "meatpie_slice"
	tastes = list("pie" = 1, "meat" = 1)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/tofupie
	name = "tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/protein = 1, // yeah. Theres 'technically' protein in this thing.
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	slice_type = /obj/item/food/pieslice/tofu
	tastes = list("pie" = 1, "tofu" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/tofu
	name = "tofu-pie slice"
	desc = "Oh nice, meat pie- WAIT A MINUTE!!"
	icon_state = "meatpie_slice"
	tastes = list("pie" = 1, "tofu" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	bite_consumption = 4
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin/amatoxin = 3,
		/datum/reagent/drug/mushroomhallucinogen = 1,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("pie" = 1, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES | TOXIC | GROSS
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("pie" = 1, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/plump_pie/Initialize(mapload)
	var/fey = prob(10)
	if(fey)
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
		food_reagents = list(
			/datum/reagent/consumable/nutriment = 11,
			/datum/reagent/medicine/omnizine = 5,
			/datum/reagent/consumable/nutriment/vitamin = 4,
		)
	. = ..()

/obj/item/food/pie/xemeatpie
	name = "xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	slice_type = /obj/item/food/pieslice/xeno
	tastes = list("pie" = 1, "meat" = 1, "acid" = 1)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/xeno
	name = "xeno-pie slice"
	desc = "Oh god... Is that still moving?"
	icon_state = "xenopie_slice"
	tastes = list("pie" = 1, "meat" = 1, "acid" = 1)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/applepie
	name = "apple pie"
	desc = "A pie containing sweet sweet love... or apple."
	icon_state = "applepie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	slice_type = /obj/item/food/pieslice/apple
	tastes = list("pie" = 1, "apple" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/apple
	name = "apple pie slice"
	desc = "A slice of comfy apple pie, warm autumn memories ahead."
	icon_state = "applepie_slice"
	tastes = list("pie" = 1, "apples" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/cherrypie
	name = "cherry pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	slice_type = /obj/item/food/pieslice/cherry
	tastes = list("pie" = 7, "Nicole Paige Brooks" = 2)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/cherry
	name = "cherry pie slice"
	desc = "A slice of delicious cherry pie, I hope it's morellos!"
	icon_state = "cherrypie_slice"
	tastes = list("pie" = 1, "cherries" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/pumpkinpie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("pie" = 1, "pumpkin" = 1)
	foodtypes = GRAIN | VEGETABLES | SUGAR
	slice_type = /obj/item/food/pieslice/pumpkin
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/pumpkin
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	tastes = list("pie" = 1, "pumpkin" = 1)
	foodtypes = GRAIN | VEGETABLES | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/gold = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("pie" = 1, "apple" = 1, "expensive metal" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pie/grapetart
	name = "grape tart"
	desc = "A tasty dessert that reminds you of the wine you didn't make."
	icon_state = "grapetart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("pie" = 1, "grape" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pie/mimetart
	name = "mime tart"
	desc = "..."
	icon_state = "mimetart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/nothing = 10,
	)
	tastes = list("nothing" = 3)
	foodtypes = GRAIN
	crafted_food_buff = /datum/status_effect/food/trait/mute

/obj/item/food/pie/berrytart
	name = "berry tart"
	desc = "A tasty dessert of many different small barries on a thin pie crust."
	icon_state = "berrytart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("pie" = 1, "berries" = 2)
	foodtypes = GRAIN | FRUIT

/obj/item/food/pie/cocoalavatart
	name = "chocolate lava tart"
	desc = "A tasty dessert made of chocolate, with a liquid core." //But it doesn't even contain chocolate...
	icon_state = "cocolavatart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("pie" = 1, "dark chocolate" = 3)
	foodtypes = GRAIN | SUGAR

/obj/item/food/pie/blumpkinpie
	name = "blumpkin pie"
	desc = "An odd blue pie made with toxic blumpkin."
	icon_state = "blumpkinpie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 13,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("pie" = 1, "a mouthful of pool water" = 1)
	foodtypes = GRAIN | VEGETABLES
	slice_type = /obj/item/food/pieslice/blumpkin
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/blumpkin
	name = "blumpkin pie slice"
	desc = "A slice of blumpkin pie, with whipped cream on top. Is this edible?"
	icon_state = "blumpkinpieslice"
	tastes = list("pie" = 1, "a mouthful of pool water" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/dulcedebatata
	name = "dulce de batata"
	desc = "A delicious jelly made with sweet potatoes."
	icon_state = "dulcedebatata"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 14,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	tastes = list("jelly" = 1, "sweet potato" = 1)
	foodtypes = VEGETABLES | SUGAR
	slice_type = /obj/item/food/pieslice/dulcedebatata
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/dulcedebatata
	name = "dulce de batata slice"
	desc = "A slice of sweet dulce de batata jelly."
	icon_state = "dulcedebatataslice"
	tastes = list("jelly" = 1, "sweet potato" = 1)
	foodtypes = VEGETABLES | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/frostypie
	name = "frosty pie"
	desc = "Tastes like blue and cold."
	icon_state = "frostypie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 14,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	slice_type = /obj/item/food/pieslice/frosty
	tastes = list("mint" = 1, "pie" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/frosty
	name = "frosty pie slice"
	desc = "Tasty blue, like my favourite crayon!"
	icon_state = "frostypie_slice"
	tastes = list("pie" = 1, "mint" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/baklava
	name = "baklava"
	desc = "A delightful healthy snack made of nut layers with thin bread."
	icon_state = "baklava"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("nuts" = 1, "pie" = 1)
	foodtypes = /*NUTS | */SUGAR
	slice_type = /obj/item/food/pieslice/baklava
	yield = 6
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pieslice/baklava
	name = "baklava dish"
	desc = "A portion of a delightful healthy snack made of nut layers with thin bread"
	icon_state = "baklavaslice"
	tastes = list("nuts" = 1, "pie" = 1)
	foodtypes = /*NUTS | */SUGAR
	crafting_complexity = FOOD_COMPLEXITY_4
