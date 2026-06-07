/* In this file:
 *
 * Plasma floor
 * Gold floor
 * Silver floor
 * Copper floor
 * Bananium floor
 * Diamond floor
 * Uranium floor
 * Shuttle floor (Titanium)
 */

/turf/open/floor/mineral
	name = "mineral floor"
	icon_state = ""
	material_flags = MATERIAL_EFFECTS
	var/list/icons
	tiled_dirt = FALSE
	max_integrity = 200


/turf/open/floor/mineral/Initialize(mapload)
	. = ..()
	icons = typelist("icons", icons)


/turf/open/floor/mineral/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		if( !(icon_state in icons) )
			icon_state = initial(icon_state)

//PLASMA

/turf/open/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	floor_tile = /obj/item/stack/tile/mineral/plasma
	icons = list("plasma","plasma_dam")
	max_integrity = 200

/turf/open/floor/mineral/plasma/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/turf/open/floor/mineral/plasma/atmos_expose(datum/gas_mixture/air, exposed_temperature)
		PlasmaBurn(exposed_temperature)

/turf/open/floor/mineral/plasma/attackby(obj/item/W, mob/user, params)
	if(W.get_temperature() > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma flooring was ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(src)]")
		log_game("Plasma flooring was ignited by [key_name(user)] in [AREACOORD(src)]")
		ignite(W.get_temperature())
		return
	..()

/turf/open/floor/mineral/plasma/proc/PlasmaBurn(temperature)
	make_plating()
	atmos_spawn_air("plasma=20;TEMP=[temperature]")

/turf/open/floor/mineral/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)


//GOLD

/turf/open/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	floor_tile = /obj/item/stack/tile/mineral/gold
	icons = list("gold","gold_dam")
	max_integrity = 250

//SILVER

/turf/open/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	floor_tile = /obj/item/stack/tile/mineral/silver
	icons = list("silver","silver_dam")
	max_integrity = 300

//COPPER

/turf/open/floor/mineral/copper
	name = "copper floor"
	icon_state = "copper"
	floor_tile = /obj/item/stack/tile/mineral/copper
	icons = list("copper","copper_dam")
	max_integrity = 175

//TITANIUM (shuttle)

/turf/open/floor/mineral/titanium
	name = "shuttle floor"
	icon_state = "titanium"
	floor_tile = /obj/item/stack/tile/mineral/titanium

/turf/open/floor/mineral/titanium/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/yellow
	icon_state = "titanium_yellow"
	floor_tile = /obj/item/stack/tile/mineral/titanium/yellow

/turf/open/floor/mineral/titanium/yellow/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/blue
	icon_state = "titanium_blue"
	floor_tile = /obj/item/stack/tile/mineral/titanium/blue

/turf/open/floor/mineral/titanium/blue/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/white
	icon_state = "titanium_white"
	floor_tile = /obj/item/stack/tile/mineral/titanium/white

/turf/open/floor/mineral/titanium/white/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/purple
	icon_state = "titanium_purple"
	floor_tile = /obj/item/stack/tile/mineral/titanium/purple

/turf/open/floor/mineral/titanium/purple/airless
	initial_gas_mix = AIRLESS_ATMOS

// OLD TITANIUM
/turf/open/floor/mineral/titanium/tiled
	name = "titanium floor"
	icon_state = "titanium_alt"
	floor_tile = /obj/item/stack/tile/mineral/titanium/tiled

/turf/open/floor/mineral/titanium/tiled/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/tiled/yellow
	icon_state = "titanium_alt_yellow"
	floor_tile = /obj/item/stack/tile/mineral/titanium/tiled/yellow

/turf/open/floor/mineral/titanium/tiled/yellow/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/tiled/blue
	icon_state = "titanium_alt_blue"
	floor_tile = /obj/item/stack/tile/mineral/titanium/tiled/blue

/turf/open/floor/mineral/titanium/tiled/blue/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/tiled/white
	icon_state = "titanium_alt_white"
	floor_tile = /obj/item/stack/tile/mineral/titanium/tiled/white

/turf/open/floor/mineral/titanium/tiled/white/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/tiled/purple
	icon_state = "titanium_alt_purple"
	floor_tile = /obj/item/stack/tile/mineral/titanium/tiled/purple

/turf/open/floor/mineral/titanium/tiled/purple/airless
	initial_gas_mix = AIRLESS_ATMOS

//PLASTITANIUM (syndieshuttle)
/turf/open/floor/mineral/plastitanium
	name = "shuttle floor"
	icon_state = "plastitanium"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium

/turf/open/floor/mineral/plastitanium/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/plastitanium/red
	icon_state = "plastitanium_red"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium/red

/turf/open/floor/mineral/plastitanium/red/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/plastitanium/red/brig
	name = "brig floor"

//BANANIUM

/turf/open/floor/mineral/bananium
	name = "bananium floor"
	icon_state = "bananium"
	floor_tile = /obj/item/stack/tile/mineral/bananium
	icons = list("bananium","bananium_dam")
	custom_materials = list(/datum/material/bananium = 500)
	material_flags = NONE //The slippery comp makes it unpractical for good clown decor. The custom mat one should still slip.
	max_integrity = 100
	var/spam_flag = 0

/turf/open/floor/mineral/bananium/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(.)
		return
	if(isliving(arrived))
		squeak()

/turf/open/floor/mineral/bananium/attackby(obj/item/W, mob/user, params)
	.=..()
	if(!.)
		honk()

/turf/open/floor/mineral/bananium/attack_hand(mob/user, list/modifiers)
	.=..()
	if(!.)
		honk()

/turf/open/floor/mineral/bananium/attack_paw(mob/user)
	.=..()
	if(!.)
		honk()

/turf/open/floor/mineral/bananium/proc/honk()
	if(spam_flag < world.time)
		playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
		spam_flag = world.time + 20

/turf/open/floor/mineral/bananium/proc/squeak()
	if(spam_flag < world.time)
		playsound(src, "clownstep", 50, 1)
		spam_flag = world.time + 10

/turf/open/floor/mineral/bananium/airless
	initial_gas_mix = AIRLESS_ATMOS

//DIAMOND

/turf/open/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	floor_tile = /obj/item/stack/tile/mineral/diamond
	icons = list("diamond","diamond_dam")
	max_integrity = 400
	damage_deflection = 10

//URANIUM

/turf/open/floor/mineral/uranium
	article = "a"
	name = "uranium floor"
	icon_state = "uranium"
	floor_tile = /obj/item/stack/tile/mineral/uranium
	icons = list("uranium","uranium_dam")
	max_integrity = 75
	damage_deflection = 0

	COOLDOWN_DECLARE(radiate_cooldown)

/turf/open/floor/mineral/uranium/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(.)
		return
	if(isliving(arrived))
		radiate()

/turf/open/floor/mineral/uranium/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!.)
		radiate()

/turf/open/floor/mineral/uranium/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!.)
		radiate()

/turf/open/floor/mineral/uranium/attack_paw(mob/user)
	. = ..()
	if(!.)
		radiate()

/turf/open/floor/mineral/uranium/proc/radiate()
	if(!COOLDOWN_FINISHED(src, radiate_cooldown))
		return

	COOLDOWN_START(src, radiate_cooldown, 1.5 SECONDS)
	radiation_pulse(
		src,
		max_range = 2,
		threshold = RAD_LIGHT_INSULATION,
		intensity = URANIUM_IRRADIATION_INTENSITY,
		minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
	)

	for(var/turf/open/floor/mineral/uranium/uranium_floor in (RANGE_TURFS(1, src) - src))
		uranium_floor.radiate()

// ALIEN ALLOY
/turf/open/floor/mineral/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	floor_tile = /obj/item/stack/tile/mineral/abductor
	icons = list("alienpod1", "alienpod2", "alienpod3", "alienpod4", "alienpod5", "alienpod6", "alienpod7", "alienpod8", "alienpod9")
	baseturfs = /turf/open/floor/plating/abductor2
	max_integrity = 450
	damage_deflection = 15

/turf/open/floor/mineral/abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1,9)]"

/turf/open/floor/mineral/abductor/break_tile()
	return //unbreakable

/turf/open/floor/mineral/abductor/burn_tile()
	return //unburnable
