/*
	FYI these used to have scientific names, and some of them were refs to real mushrooms. I dont want to condone the risk of eating these mushrooms irl, so try not to use real latin names
*/
/obj/item/food/grown/mushroom
	name = "mushroom"
	bite_consumption_mod = 3
	foodtypes = VEGETABLES
	wine_power = 40
	/// Default mushroom icon for recipes that need any mushroom
	icon_state = "plumphelmet"

// Reishi
/obj/item/food/grown/mushroom/reishi
	seed = /obj/item/plant_seeds/preset/reishi
	name = "reishi"
	desc = "A special fungus known for its medicinal and stress relieving properties."
	icon_state = "reishi"
	trade_flags = TRADE_CONTRABAND

// Fly Amanita
/obj/item/food/grown/mushroom/amanita
	seed = /obj/item/plant_seeds/preset/amanita
	name = "fly amanita"
	desc = "Learn poisonous mushrooms by heart. Only pick mushrooms you know."
	icon_state = "amanita"
	trade_flags = TRADE_CONTRABAND

// Destroying Angel
/obj/item/food/grown/mushroom/angel
	seed = /obj/item/plant_seeds/preset/angel
	name = "destroying angel"
	desc = "Deadly poisonous basidiomycete fungus filled with alpha amatoxins."
	icon_state = "angel"
	wine_power = 60
	discovery_points = 300

// Liberty Cap
/obj/item/food/grown/mushroom/libertycap
	seed = /obj/item/plant_seeds/preset/liberty
	name = "liberty-cap"
	desc = "Liberate yourself!"
	icon_state = "libertycap"
	wine_power = 80
	trade_flags = TRADE_CONTRABAND

// Plump Helmet
/obj/item/food/grown/mushroom/plumphelmet
	seed = /obj/item/plant_seeds/preset/plump
	name = "plump-helmet"
	desc = "Plump, soft and s-so inviting~"
	icon_state = "plumphelmet"
	distill_reagent = /datum/reagent/consumable/ethanol/manly_dorf
	trade_flags = TRADE_CONTRABAND

// Walking Mushroom
/obj/item/food/grown/mushroom/walkingmushroom
	seed = /obj/item/plant_seeds/preset/walking
	name = "walking mushroom"
	desc = "The beginning of the great walk."
	icon_state = "walkingmushroom"
	can_distill = FALSE
	discovery_points = 300

// Chanterelle
/obj/item/food/grown/mushroom/chanterelle
	seed = /obj/item/plant_seeds/preset/chanterelle
	name = "chanterelle cluster"
	desc = "These jolly yellow little shrooms sure look tasty!"
	icon_state = "chanterelle"

//Jupiter Cup
/obj/item/food/grown/mushroom/jupitercup
	seed = /obj/item/plant_seeds/preset/jupitercup
	name = "jupiter cup"
	desc = "A strange red mushroom, its surface is moist and slick. You wonder how many tiny worms have met their fate inside."
	icon_state = "jupitercup"
	discovery_points = 300

// Glowshroom
/obj/item/food/grown/mushroom/glowshroom
	seed = /obj/item/plant_seeds/preset/glowshroom
	name = "glowshroom cluster"
	desc = "This species of mushroom glows in the dark."
	icon_state = "glowshroom"
	var/effect_path = /obj/structure/glowshroom
	wine_power = 50
	discovery_points = 300
	trade_flags = TRADE_CONTRABAND

/obj/item/food/grown/mushroom/glowshroom/attack_self(mob/user)
	if(isspaceturf(user.loc))
		return FALSE
	if(!isturf(user.loc))
		to_chat(user, span_warning("You need more space to plant [src]."))
		return FALSE
	var/count = 0
	var/maxcount = 1
	for(var/tempdir in GLOB.cardinals)
		var/turf/closed/wall = get_step(user.loc, tempdir)
		if(istype(wall))
			maxcount++
	for(var/obj/structure/glowshroom/G in user.loc)
		count++
	if(count >= maxcount)
		to_chat(user, span_warning("There are too many shrooms here to plant [src]."))
		return FALSE
	new effect_path(user.loc, seed)
	to_chat(user, span_notice("You plant [src]."))
	qdel(src)
	return TRUE


// Glowcap
/obj/item/food/grown/mushroom/glowshroom/glowcap
	seed = /obj/item/plant_seeds/preset/glowcap
	name = "glowcap cluster"
	desc = "This species of mushroom glows in the dark, but isn't actually bioluminescent. They're warm to the touch..."
	icon_state = "glowcap"
	effect_path = /obj/structure/glowshroom/glowcap
	tastes = list("glowcap" = 1)
	discovery_points = 300

//Shadowshroom
/obj/item/food/grown/mushroom/glowshroom/shadowshroom
	seed = /obj/item/plant_seeds/preset/shadowshroom
	name = "shadowshroom cluster"
	desc = "This species of mushroom emits shadow instead of light."
	icon_state = "shadowshroom"
	effect_path = /obj/structure/glowshroom/shadowshroom
	tastes = list("shadow" = 1, "mushroom" = 1)
	wine_power = 60
	discovery_points = 300

/obj/item/food/grown/mushroom/glowshroom/shadowshroom/attack_self(mob/user)
	. = ..()
	if(.)
		investigate_log("was planted by [key_name(user)] at [AREACOORD(user)]", INVESTIGATE_BOTANY)
