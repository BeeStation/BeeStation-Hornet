/mob/living/carbon
	gender = MALE
	pressure_resistance = 15
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ANTAG_HUD,GLAND_HUD,NANITE_HUD,DIAG_NANITE_FULL_HUD)
	has_limbs = 1
	held_items = list(null, null)
	num_legs = 0 //Populated on init through list/bodyparts
	usable_legs = 0 //Populated on init through list/bodyparts
	num_hands = 0 //Populated on init through list/bodyparts
	usable_hands = 0 //Populated on init through list/bodyparts
	/// List of /obj/item/organ in the mob. They don't go in the contents for some reason I don't want to know.
	var/list/internal_organs = list()
	/// Same as above, but stores "slot ID" - "organ" pairs for easy access.
	var/list/internal_organs_slot = list()
	/// Whether or not the mob is handcuffed
	var/obj/item/handcuffed = null
	/// Same as handcuffs but for legs. Bear traps use this.
	var/obj/item/legcuffed = null

	/// Measure of how disgusted we are. See DISGUST_LEVEL_GROSS and friends
	var/disgust = 0
	/// How disgusted we were LAST time we processed disgust. Helps prevent unneeded work
	var/old_disgust = 0

	//inventory slots
	var/obj/item/back = null
	var/obj/item/clothing/mask/wear_mask = null
	var/obj/item/clothing/neck/wear_neck = null
	/// Equipped air tank. Never set this manually.
	var/obj/item/tank/internal = null
	/// "External" air tank. Never set this manually. Not required to stay directly equipped on the mob (i.e. could be a machine).
	var/obj/item/tank/external = null
	var/obj/item/clothing/head = null

	var/obj/item/clothing/gloves = null //only used by humans
	var/obj/item/clothing/shoes = null //only used by humans.
	var/obj/item/clothing/glasses/glasses = null //only used by humans.
	var/obj/item/clothing/ears = null //only used by humans.

	var/datum/dna/dna = null // Carbon
	var/datum/mind/last_mind = null //last mind to control this mob, for blood-based cloning

	var/failed_last_breath = 0 //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.

	var/co2overloadtime = null
	var/temperature_resistance = T0C+75
	var/obj/item/food/meat/slab/type_of_meat = /obj/item/food/meat/slab

	var/gib_type = /obj/effect/decal/cleanable/blood/gibs

	var/rotate_on_lying = 1

	var/tinttotal = 0	// Total level of visualy impairing items

	var/list/icon_render_keys = list()
	var/list/bodyparts = list(
		/obj/item/bodypart/chest,
		/obj/item/bodypart/head,
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/leg/right,
		/obj/item/bodypart/leg/left
	)

	//Gets filled up in create_bodyparts()

	var/list/hand_bodyparts = list() //a collection of arms (or actually whatever the fug /bodyparts you monsters use to wreck my systems)


	var/static/list/limb_icon_cache = list()

	/// Used to temporarily increase severity of / apply a new damage overlay (the red ring around the ui / screen).
	/// This number will translate to equivalent brute or burn damage taken. Handled in [mob/living/proc/update_damage_hud].
	/// (For example, setting damageoverlaytemp = 20 will add 20 "damage" to the overlay the next time it updates.)
	/// This number is also reset to 0 every tick of carbon Life(). Pain.
	var/damageoverlaytemp = 0

	var/stam_regen_start_time = 0 //used to halt stamina regen temporarily
	var/stam_heal = 10	//Stamina healed per 2 seconds overall. When the mob has taken more than 60 stamina damage, the rate of stamina regeneration will be increased, up to 20 per second when the mob has taken 120 stamina damage.

	/// Protection (insulation) from the heat, Value 0-1 corresponding to the percentage of protection
	var/heat_protection = 0 // No heat protection
	/// Protection (insulation) from the cold, Value 0-1 corresponding to the percentage of protection
	var/cold_protection = 0 // No cold protection

	/// Timer id of any transformation
	var/transformation_timer

	/// Only load in visual organs
	var/visual_only_organs = FALSE

