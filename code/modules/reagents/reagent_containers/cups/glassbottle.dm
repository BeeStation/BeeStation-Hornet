#define BOTTLE_KNOCKDOWN_DEFAULT_DURATION (1.3 SECONDS)

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now knockdown and break when smashed on people's heads. - Giacom

/obj/item/reagent_containers/cup/glass/bottle
	name = "glass bottle"
	desc = "This blank bottle is unyieldingly anonymous, offering no clues to its contents."
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "glassbottle"
	worn_icon_state = "bottle"
	fill_icon_thresholds = list(0, 10, 20, 30, 40, 50, 60, 70, 80, 90)
	custom_price = PAYCHECK_MEDIUM * 1.1
	amount_per_transfer_from_this = 10
	volume = 100
	force = 15 //Smashing bottles over someone's head hurts.
	throwforce = 15
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	var/broken_item_state = "broken_beer"
	lefthand_file = 'icons/mob/inhands/misc/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/drinks_righthand.dmi'
	drink_type = ALCOHOL
	item_flags = ISWEAPON
	///Directly relates to the 'knockdown' duration. Lowered by armor (i.e. helmets)
	var/bottle_knockdown_duration = BOTTLE_KNOCKDOWN_DEFAULT_DURATION

/obj/item/reagent_containers/cup/glass/bottle/small
	name = "small glass bottle"
	desc = "This blank bottle is unyieldingly anonymous, offering no clues to its contents."
	icon_state = "glassbottlesmall"
	volume = 50
	custom_price = PAYCHECK_MEDIUM * 0.9

/obj/item/reagent_containers/cup/glass/bottle/smash(mob/living/target, mob/thrower, ranged = FALSE)
	if(bartender_check(target) && ranged)
		return
	SplashReagents(target, ranged, override_spillable = TRUE)
	var/obj/item/broken_bottle/B = new(loc)
	if(!ranged && thrower)
		thrower.put_in_hands(B)
	B.mimic_broken(src, target)
	B.item_state = broken_item_state

	qdel(src)
	target.Bumped(B)

/obj/item/reagent_containers/cup/glass/bottle/try_splash(mob/living/user, atom/target)

	if(!target || !isliving(target))
		return ..()

	if(!isGlass)
		return ..()

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You don't want to harm [target]!"))
		return FALSE

	var/mob/living/living_target = target

	var/armor_block = 0 //Get the target's armor values for normal attack damage.
	var/armor_duration = 0 //The more force the bottle has, the longer the duration.

	// Preference for smashing on the head with this item due to it dealing a stun effect on top
	var/target_zone = user.is_zone_selected(BODY_ZONE_HEAD) ? BODY_ZONE_HEAD : user.get_combat_bodyzone(target)

	//Calculating duration and calculating damage.
	if(ishuman(target))

		var/mob/living/carbon/human/H = target
		var/headarmor = 0 // Target's head armor
		armor_block = H.run_armor_check(target_zone, MELEE, "", "", armour_penetration) // For normal attack damage

		//If they have a hat/helmet and the user is targeting their head.
		if(istype(H.head, /obj/item/clothing/head) && target_zone == BODY_ZONE_HEAD)
			headarmor = H.head.get_armor_rating(MELEE)
		//Calculate the knockdown duration for the target.
		armor_duration = (bottle_knockdown_duration - headarmor) + force

	else
		//Only humans can have armor, right?
		armor_block = living_target.run_armor_check(target_zone, MELEE)
		if(target_zone == BODY_ZONE_HEAD)
			armor_duration = bottle_knockdown_duration + force
	//Apply the damage!
	armor_block = min(90,armor_block)
	living_target.apply_damage(force, BRUTE, target_zone, armor_block)

	// You are going to knock someone down for longer if they are not wearing a helmet.
	var/head_attack_message = ""
	if(target_zone == BODY_ZONE_HEAD && iscarbon(target))
		head_attack_message = " on the head"
		if(armor_duration)
			living_target.apply_effect(min(armor_duration, 200) , EFFECT_KNOCKDOWN)

	//Display an attack message.
	if(target != user)
		target.visible_message(span_danger("[user] hits [target][head_attack_message] with a bottle of [src.name]!"), \
				span_userdanger("[user] hits you [head_attack_message] with a bottle of [src.name]!"))
	else
		target.visible_message(span_danger("[target] hits [target.p_them()]self with a bottle of [src.name][head_attack_message]!"), \
				span_userdanger("You hit yourself with a bottle of [src.name][head_attack_message]!"))

	//Attack logs
	log_combat(user, target, "attacked", src)

	//Finally, smash the bottle. This kills (del) the bottle.
	smash(target, user)

	return TRUE

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/broken_bottle
	name = "broken bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks/drink_effects.dmi'
	icon_state = "broken_bottle"
	force = 9
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	item_state = "broken_beer"
	lefthand_file = 'icons/mob/inhands/misc/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/drinks_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("stabs", "slashes", "attacks")
	attack_verb_simple = list("stab", "slash", "attack")
	sharpness = SHARP
	bleed_force = BLEED_SURFACE
	var/static/icon/broken_outline = icon('icons/obj/drinks/drink_effects.dmi', "broken")

/obj/item/broken_bottle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = force)
	AddComponent(/datum/component/butchering, 200, 55)

/// Mimics the appearance and properties of the passed in bottle.
/// Takes the broken bottle to mimic, and the thing the bottle was broken agaisnt as args
/obj/item/broken_bottle/proc/mimic_broken(obj/item/reagent_containers/cup/glass/to_mimic, atom/target)
	icon_state = to_mimic.icon_state
	var/icon/drink_icon = new(to_mimic.icon, icon_state)
	drink_icon.Blend(broken_outline, ICON_OVERLAY, rand(5), 1)
	drink_icon.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	icon = drink_icon

	if(istype(to_mimic, /obj/item/reagent_containers/cup/glass/bottle/juice))
		force = 0
		throwforce = 0
		desc = "A carton with the bottom half burst open. Might give you a papercut."
	else
		if(prob(33))
			var/obj/item/shard/stab_with = new(to_mimic.drop_location())
			target.Bumped(stab_with)
		playsound(src, "shatter", 70, TRUE)
	name = "broken [to_mimic.name]"
	to_mimic.transfer_fingerprints_to(src)

/obj/item/reagent_containers/cup/glass/bottle/beer
	name = "space beer"
	desc = "Beer. In space."
	icon_state = "beer"
	volume = 30
	list_reagents = list(/datum/reagent/consumable/ethanol/beer = 30)
	drink_type = GRAIN | ALCOHOL
	custom_price = PAYCHECK_MEDIUM

/obj/item/reagent_containers/cup/glass/bottle/beer/almost_empty
	list_reagents = list(/datum/reagent/consumable/ethanol/beer = 1)

/obj/item/reagent_containers/cup/glass/bottle/beer/syndicate
	name = "syndicate beer"
	desc = "Consumed only by the finest syndicate agents. There is a round warning label stating 'Don't drink more than one in quick succession!'"
	icon_state = "beer"
	list_reagents = list(/datum/reagent/consumable/ethanol/beer = 10, /datum/reagent/medicine/antitoxin = 20)

/obj/item/reagent_containers/cup/glass/bottle/beer/light
	name = "Carp Lite"
	desc = "Brewed with \"Pure Ice Asteroid Spring Water\"."
	list_reagents = list(/datum/reagent/consumable/ethanol/beer/light = 30)

/obj/item/reagent_containers/cup/glass/bottle/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	volume = 30
	list_reagents = list(/datum/reagent/consumable/ethanol/ale = 30)
	drink_type = GRAIN | ALCOHOL
	custom_price = PAYCHECK_MEDIUM

/obj/item/reagent_containers/cup/glass/bottle/gin
	name = "Griffeater gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/gin = 100)

/obj/item/reagent_containers/cup/glass/bottle/whiskey
	name = "Uncle Git's special reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 100)

/obj/item/reagent_containers/cup/glass/bottle/vodka
	name = "Tunguska triple distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/vodka = 100)

/obj/item/reagent_containers/cup/glass/bottle/vodka/badminka
	name = "Badminka vodka"
	desc = "The label's written in Cyrillic. All you can make out is the name and a word that looks vaguely like 'Vodka'."
	icon_state = "badminka"
	list_reagents = list(/datum/reagent/consumable/ethanol/vodka = 100)

/obj/item/reagent_containers/cup/glass/bottle/tequila
	name = "Caccavo guaranteed quality tequila"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequilabottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/tequila = 100)

/obj/item/reagent_containers/cup/glass/bottle/bottleofnothing
	name = "bottle of nothing"
	desc = "A bottle filled with nothing."
	icon_state = "bottleofnothing"
	list_reagents = list(/datum/reagent/consumable/nothing = 100)
	drink_type = NONE

/obj/item/reagent_containers/cup/glass/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequila, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/patron = 100)

/obj/item/reagent_containers/cup/glass/bottle/rum
	name = "Captain Pete's Cuban spiced rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/rum = 100)

/obj/item/reagent_containers/cup/glass/bottle/holywater
	name = "flask of holy water"
	desc = "A flask of the chaplain's holy water."
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "holyflask"
	list_reagents = list(/datum/reagent/water/holywater = 100)
	drink_type = NONE

/obj/item/reagent_containers/cup/glass/bottle/unholywater
	name = "flask of unholy water"
	desc = "Toxic to nonbelievers, reinvigorating to the faithful."
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "holyflask"
	list_reagents = list(/datum/reagent/fuel/unholywater = 100)
	drink_type = NONE

/obj/item/reagent_containers/cup/glass/bottle/hellwater
	name = "flask of holy water?"
	desc = "A flask of holy water...it's been sitting in the Necropolis a while though."
	list_reagents = list(/datum/reagent/hellwater = 100)

/obj/item/reagent_containers/cup/glass/bottle/vermouth
	name = "Goldeneye vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/vermouth = 100)

/obj/item/reagent_containers/cup/glass/bottle/kahlua
	name = "Robert Robust's coffee liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK."
	icon_state = "kahluabottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/kahlua = 100)
	drink_type = VEGETABLES

/obj/item/reagent_containers/cup/glass/bottle/goldschlager
	name = "College Girl goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/goldschlager = 100)

/obj/item/reagent_containers/cup/glass/bottle/cognac
	name = "Chateau de Baton premium cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/cognac = 100)

/obj/item/reagent_containers/cup/glass/bottle/wine
	name = "Doublebeard's bearded special wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/wine = 100)
	drink_type = FRUIT | ALCOHOL

//Vintage wine code goes here

/obj/item/reagent_containers/cup/glass/bottle/absinthe
	name = "extra-strong absinthe"
	desc = "A strong alcoholic drink brewed and distributed by"
	icon_state = "absinthebottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/absinthe = 100)

/obj/item/reagent_containers/cup/glass/bottle/absinthe/Initialize(mapload)
	. = ..()
	redact()

/obj/item/reagent_containers/cup/glass/bottle/absinthe/proc/redact()
	// There was a large fight in the coderbus about a player reference
	// in absinthe. Ergo, this is why the name generation is now so
	// complicated. Judge us kindly.
	var/shortname = pick_weight(
		list("T&T" = 1, "A&A" = 1, "Generic" = 1))
	var/fullname
	switch(shortname)
		if("T&T")
			fullname = "Teal and Tealer"
		if("A&A")
			fullname = "Ash and Asher"
		if("Generic")
			fullname = "Nanotrasen Cheap Imitations"
	var/removals = list(
		"\[REDACTED\]",
		"\[EXPLETIVE DELETED\]",
		"\[EXPUNGED\]",
		"\[INFORMATION ABOVE YOUR SECURITY CLEARANCE\]",
		"\[MOVE ALONG CITIZEN\]",
		"\[NOTHING TO SEE HERE\]",
	)
	var/chance = 50

	if(prob(chance))
		shortname = pick_n_take(removals)

	var/list/final_fullname = list()
	for(var/word in splittext(fullname, " "))
		if(prob(chance))
			word = pick_n_take(removals)
		final_fullname += word

	fullname = jointext(final_fullname, " ")

	// Actually finally setting the new name and desc
	name = "[shortname] [name]"
	desc = "[desc] [fullname] Inc."


/obj/item/reagent_containers/cup/glass/bottle/absinthe/premium
	name = "Gwyn's premium absinthe"
	desc = "A potent alcoholic beverage, almost makes you forget the ash in your lungs."
	icon_state = "absinthepremium"

/obj/item/reagent_containers/cup/glass/bottle/absinthe/premium/redact()
	return

/obj/item/reagent_containers/cup/glass/bottle/lizardwine
	name = "bottle of lizard wine"
	desc = "An alcoholic beverage from Space China, made by infusing lizard tails in ethanol. Inexplicably popular among command staff."
	icon_state = "lizardwine"
	list_reagents = list(/datum/reagent/consumable/ethanol/lizardwine = 100)
	drink_type = FRUIT | ALCOHOL

/obj/item/reagent_containers/cup/glass/bottle/hcider
	name = "Jian Hard Cider"
	desc = "Apple juice for adults."
	icon_state = "hcider"
	volume = 50
	list_reagents = list(/datum/reagent/consumable/ethanol/hcider = 50)

/obj/item/reagent_containers/cup/glass/bottle/grappa
	name = "Phillipe's well-aged Grappa"
	desc = "Bottle of Grappa."
	icon_state = "grappabottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/grappa = 100)

/obj/item/reagent_containers/cup/glass/bottle/sake
	name = "Ryo's traditional sake"
	desc = "Sweet as can be, and burns like fire going down."
	icon_state = "sakebottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/sake = 100)

/obj/item/reagent_containers/cup/glass/bottle/sake/Initialize(mapload)
	. = ..()
	if(prob(10))
		name = "Fluffy Tail Sake"
		desc += " On the bottle is a picture of a kitsune with nine touchable tails."
		icon_state = "sakebottle_k"
	else if(prob(10))
		name = "Inubashiri's Home Brew"
		desc += " Awoo."
		icon_state = "sakebottle_i"

/obj/item/reagent_containers/cup/glass/bottle/fernet
	name = "Fernet Bronca"
	desc = "A bottle of pure Fernet Bronca, produced in Cordoba Space Station"
	icon_state = "fernetbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/fernet = 100)

/obj/item/reagent_containers/cup/glass/bottle/homemaderum
	name = "Cookie's Homemade Rum"
	desc = "Brewed all the way back on Space Station 3. Might tell you where those basket-hats of fruit keep coming from."
	icon_state = "moonshinebottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/rum = 95, /datum/reagent/drug/mushroomhallucinogen = 5)

/obj/item/reagent_containers/cup/glass/bottle/grenadine
	name = "Jester Grenadine"
	desc = "Contains 0% real cherries!"
	custom_price = PAYCHECK_MEDIUM
	icon_state = "grenadine"
	list_reagents = list(/datum/reagent/consumable/grenadine = 100)
	drink_type = FRUIT

/obj/item/reagent_containers/cup/glass/bottle/synthflesh
	name = "carton of synthflesh"
	desc = "A No-Name carton of synthflesh. It seems moldy. And it seems that YOUR INCOMPETENT ASS IS THE ONLY FUCKING REASON THIS THING EVEN EXISTS!!!!"
	icon_state = "synthflesh"
	item_state = "carton"
	isGlass = FALSE
	list_reagents = list(/datum/reagent/medicine/synthflesh = 100)

/obj/item/reagent_containers/cup/glass/bottle/virusfood
	name = "carton of virus food"
	desc = "A carton of ready-mixed virus food. Do not drink."
	icon_state = "virusfood"
	item_state = "carton"
	isGlass = FALSE
	list_reagents = list(/datum/reagent/consumable/virus_food = 100)

/obj/item/reagent_containers/cup/glass/bottle/applejack
	name = "Buckin' Bronco's Applejack"
	desc = "Kicks like a horse, tastes like an apple!"
	custom_price = PAYCHECK_MEDIUM
	icon_state = "applejack_bottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/applejack = 100)
	drink_type = FRUIT

/obj/item/reagent_containers/cup/glass/bottle/champagne
	name = "Eau d' Dandy Brut Champagne"
	desc = "Finely sourced from only the most pretentious French vineyards."
	icon_state = "champagne_bottle"
	base_icon_state = "champagne_bottle"
	reagent_flags = TRANSPARENT
	//spillable = FALSE //This bottle should really be using a cork, but we'll leave it alone for now
	list_reagents = list(/datum/reagent/consumable/ethanol/champagne = 100)

/obj/item/reagent_containers/cup/glass/bottle/blazaam
	name = "Ginbad's Blazaam"
	desc = "You feel like you should give the bottle a good rub before opening."
	icon_state = "blazaambottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/blazaam = 100)

/obj/item/reagent_containers/cup/glass/bottle/trappist
	name = "Mont de Requin Trappistes Bleu"
	desc = "Brewed in space-Belgium. Fancy!"
	icon_state = "trappistbottle"
	volume = 50
	list_reagents = list(/datum/reagent/consumable/ethanol/trappist = 50)

/obj/item/reagent_containers/cup/glass/bottle/hooch
	name = "hooch bottle"
	desc = "A bottle of rotgut. Its owner has applied some street wisdom to cleverly disguise it as a brown paper bag."
	icon_state = "hoochbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/hooch = 100)

/obj/item/reagent_containers/cup/glass/bottle/moonshine
	name = "moonshine jug"
	desc = "It is said that the ancient Appalachians used these stoneware jugs to capture lightning in a bottle."
	icon_state = "moonshinebottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/moonshine = 100)

/obj/item/reagent_containers/cup/glass/bottle/blank //Don't let players print these from a lathe, bottles should be obtained in mass from the bar only.
	name = "glass bottle"
	desc = "This blank bottle is unyieldingly anonymous, offering no clues to it's contents."
	icon_state = "glassbottle"
	fill_icon_thresholds = list(0, 10, 20, 30, 40, 50, 60, 70, 80, 90)

/obj/item/reagent_containers/cup/glass/bottle/blank/update_icon()
	..()
	add_overlay("[initial(icon_state)]shine")

/obj/item/reagent_containers/cup/glass/bottle/blank/small
	name = "small glass bottle"
	desc = "This small bottle is unyieldingly anonymous, offering no clues to it's contents."
	icon_state = "glassbottlesmall"
	volume = 50

////////////////////////// MOLOTOV ///////////////////////
/obj/item/reagent_containers/cup/glass/bottle/molotov
	name = "molotov cocktail"
	desc = "A throwing weapon used to ignite things, typically filled with an accelerant. Recommended highly by rioters and revolutionaries. Light and toss."
	icon_state = "vodkabottle"
	list_reagents = list()
	var/active = FALSE
	var/list/accelerants = list(
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fuel,
		/datum/reagent/clf3,
		/datum/reagent/phlogiston,
		/datum/reagent/napalm,
		/datum/reagent/hellwater,
		/datum/reagent/toxin/plasma,
		/datum/reagent/toxin/spore_burning
	)

/obj/item/reagent_containers/cup/glass/bottle/molotov/CheckParts(list/parts_list)
	..()
	var/obj/item/reagent_containers/cup/glass/bottle/B = locate() in contents
	if(B)
		icon_state = B.icon_state
		B.reagents.copy_to(src, 100)
		if(istype(B, /obj/item/reagent_containers/cup/glass/bottle/juice))
			desc += " You're not sure if making this out of a carton was the brightest idea."
			isGlass = FALSE
	return

/obj/item/reagent_containers/cup/glass/bottle/molotov/smash(atom/target, mob/thrower, ranged = FALSE)
	var/firestarter = 0
	for(var/datum/reagent/contained_reagent in reagents.reagent_list)
		for(var/accelerant_type in accelerants)
			if(istype(contained_reagent, accelerant_type))
				firestarter = 1
				break
	if(firestarter && active)
		target.fire_act()
		new /obj/effect/hotspot(get_turf(target))
	..()

/obj/item/reagent_containers/cup/glass/bottle/molotov/attackby(obj/item/I, mob/user, params)
	if(I.is_hot() && !active)
		active = TRUE
		log_bomber(user, "has primed a", src, "for detonation")

		to_chat(user, span_info("You light [src] on fire."))
		add_overlay(custom_fire_overlay ? custom_fire_overlay : GLOB.fire_overlay)
		if(!isGlass)
			addtimer(CALLBACK(src, PROC_REF(explode)), 5 SECONDS)

/obj/item/reagent_containers/cup/glass/bottle/molotov/proc/explode()
	if(!active)
		return
	if(get_turf(src))
		var/atom/target = loc
		for(var/i in 1 to 2)
			if(istype(target, /obj/item/storage))
				target = target.loc
		SplashReagents(target, override_spillable = TRUE)
		target.fire_act()
	qdel(src)

/obj/item/reagent_containers/cup/glass/bottle/molotov/attack_self(mob/user)
	if(active)
		if(!isGlass)
			to_chat(user, span_danger("The flame's spread too far on it!"))
			return
		to_chat(user, span_info("You snuff out the flame on [src]."))
		cut_overlay(custom_fire_overlay ? custom_fire_overlay : GLOB.fire_overlay)
		active = FALSE
		return
	return ..()

/**
 * Cartons
 * Subtype of glass that don't break, and share a common carton hand state.
 * Meant to be a subtype for use in Molotovs
 */
/obj/item/reagent_containers/cup/glass/bottle/juice
	custom_price = PAYCHECK_MEDIUM
	item_state = "carton"
	isGlass = FALSE

/obj/item/reagent_containers/cup/glass/bottle/juice/orangejuice
	name = "orange juice"
	desc = "Full of vitamins and deliciousness!"
	icon = 'icons/obj/drinks/boxes.dmi'
	icon_state = "orangejuice"
	list_reagents = list(/datum/reagent/consumable/orangejuice = 100)
	drink_type = FRUIT | BREAKFAST

/obj/item/reagent_containers/cup/glass/bottle/juice/cream
	name = "milk cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon = 'icons/obj/drinks/boxes.dmi'
	icon_state = "cream"
	list_reagents = list(/datum/reagent/consumable/cream = 100)
	drink_type = DAIRY

/obj/item/reagent_containers/cup/glass/bottle/juice/tomatojuice
	name = "tomato juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon = 'icons/obj/drinks/boxes.dmi'
	icon_state = "tomatojuice"
	list_reagents = list(/datum/reagent/consumable/tomatojuice = 100)
	drink_type = VEGETABLES

/obj/item/reagent_containers/cup/glass/bottle/juice/limejuice
	name = "lime juice"
	desc = "Sweet-sour goodness."
	icon = 'icons/obj/drinks/boxes.dmi'
	icon_state = "limejuice"
	list_reagents = list(/datum/reagent/consumable/limejuice = 100)
	drink_type = FRUIT

/obj/item/reagent_containers/cup/glass/bottle/juice/pineapplejuice
	name = "pineapple juice"
	desc = "Extremely tart, yellow juice."
	icon = 'icons/obj/drinks/boxes.dmi'
	icon_state = "pineapplejuice"
	list_reagents = list(/datum/reagent/consumable/pineapplejuice = 100)
	drink_type = FRUIT | PINEAPPLE

/obj/item/reagent_containers/cup/glass/bottle/juice/menthol
	name = "menthol"
	desc = "Tastes naturally minty, and imparts a very mild numbing sensation."
	list_reagents = list(/datum/reagent/consumable/menthol = 100)

#undef BOTTLE_KNOCKDOWN_DEFAULT_DURATION
