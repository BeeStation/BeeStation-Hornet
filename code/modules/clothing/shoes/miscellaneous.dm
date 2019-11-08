/obj/item/clothing/shoes/proc/step_action() //this was made to rewrite clown shoes squeaking
	SEND_SIGNAL(src, COMSIG_SHOES_STEP_ACTION)

/obj/item/clothing/shoes/sneakers/mime
	name = "mime shoes"
	icon_state = "mime"
	item_color = "mime"

/obj/item/clothing/shoes/combat //basic syndicate combat boots for nuke ops and mob corpses
	name = "combat boots"
	desc = "High speed, low drag combat boots."
	icon_state = "jackboots"
	item_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 10, "rad" = 0, "fire" = 70, "acid" = 50)
	strip_delay = 40
	resistance_flags = NONE
	permeability_coefficient = 0.05 //Thick soles, and covers the ankle
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes

/obj/item/clothing/shoes/combat/swat //overpowered boots for death squads
	name = "\improper SWAT boots"
	desc = "High speed, no drag combat boots."
	permeability_coefficient = 0.01
	clothing_flags = NOSLIP
	armor = list("melee" = 40, "bullet" = 30, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 90, "acid" = 50)

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	strip_delay = 50
	equip_delay_other = 50
	permeability_coefficient = 0.9
	strip_delay = 5
	
/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic black shoes."
	name = "magic shoes"
	icon_state = "black"
	resistance_flags = FIRE_PROOF |  ACID_PROOF

/obj/item/clothing/shoes/sandal/magic
	name = "magical sandals"
	desc = "A pair of sandals imbued with magic."
	resistance_flags = FIRE_PROOF |  ACID_PROOF

/obj/item/clothing/shoes/galoshes
	desc = "A pair of yellow rubber boots, designed to prevent slipping on wet surfaces."
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.01
	clothing_flags = NOSLIP
	slowdown = SHOES_SLOWDOWN+1
	strip_delay = 30
	equip_delay_other = 50
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 75)
	can_be_bloody = FALSE
	custom_price = 100

/obj/item/clothing/shoes/galoshes/dry
	name = "absorbent galoshes"
	desc = "A pair of orange rubber boots, designed to prevent slipping on wet surfaces while also drying them."
	icon_state = "galoshes_dry"

/obj/item/clothing/shoes/galoshes/dry/step_action()
	var/turf/open/t_loc = get_turf(src)
	SEND_SIGNAL(t_loc, COMSIG_TURF_MAKE_DRY, TURF_WET_WATER, TRUE, INFINITY)

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn, they're huge! Ctrl-click to toggle waddle dampeners."
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	item_color = "clown"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes/clown
	var/datum/component/waddle
	var/enabled_waddle = TRUE

/obj/item/clothing/shoes/clown_shoes/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg'=1,'sound/effects/clownstep2.ogg'=1), 50)

/obj/item/clothing/shoes/clown_shoes/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_SHOES)
		if(enabled_waddle)
			waddle = user.AddComponent(/datum/component/waddling)
		if(user.mind && user.mind.assigned_role == "Clown")
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "clownshoes", /datum/mood_event/clownshoes)

/obj/item/clothing/shoes/clown_shoes/dropped(mob/user)
	. = ..()
	QDEL_NULL(waddle)
	if(user.mind && user.mind.assigned_role == "Clown")
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "clownshoes")

/obj/item/clothing/shoes/clown_shoes/CtrlClick(mob/living/user)
	if(!isliving(user))
		return
	if(user.get_active_held_item() != src)
		to_chat(user, "You must hold the [src] in your hand to do this.")
		return
	if (!enabled_waddle)
		to_chat(user, "<span class='notice'>You switch off the waddle dampeners!</span>")
		enabled_waddle = TRUE
	else
		to_chat(user, "<span class='notice'>You switch on the waddle dampeners!</span>")
		enabled_waddle = FALSE

/obj/item/clothing/shoes/clown_shoes/jester
	name = "jester shoes"
	desc = "A court jester's shoes, updated with modern squeaking technology."
	icon_state = "jester_shoes"

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	item_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	item_color = "hosred"
	strip_delay = 30
	equip_delay_other = 50
	resistance_flags = NONE
	permeability_coefficient = 0.05 //Thick soles, and covers the ankle
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes

/obj/item/clothing/shoes/jackboots/fast
	slowdown = -1

/obj/item/clothing/shoes/winterboots
	name = "winter boots"
	desc = "Boots lined with 'synthetic' animal fur."
	icon_state = "winterboots"
	item_state = "winterboots"
	permeability_coefficient = 0.15
	cold_protection = FEET|LEGS
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET|LEGS
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes

/obj/item/clothing/shoes/workboots
	name = "work boots"
	desc = "Nanotrasen-issue Engineering lace-up work boots for the especially blue-collar."
	icon_state = "workboots"
	item_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	permeability_coefficient = 0.15
	strip_delay = 20
	equip_delay_other = 40
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes

/obj/item/clothing/shoes/workboots/mining
	name = "mining boots"
	desc = "Steel-toed mining boots for mining in hazardous environments. Very good at keeping toes uncrushed."
	icon_state = "explorer"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/shoes/cult
	name = "\improper Nar'Sien invoker boots"
	desc = "A pair of boots worn by the followers of Nar'Sie."
	icon_state = "cult"
	item_state = "cult"
	item_color = "cult"
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/cult/alt
	name = "cultist boots"
	icon_state = "cultalt"

/obj/item/clothing/shoes/cult/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/shoes/cult/alt/ghost/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume."
	icon_state = "boots"

/obj/item/clothing/shoes/laceup
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"
	equip_delay_other = 50

/obj/item/clothing/shoes/roman
	name = "roman sandals"
	desc = "Sandals with buckled leather straps on it."
	icon_state = "roman"
	item_state = "roman"
	strip_delay = 100
	equip_delay_other = 100
	permeability_coefficient = 0.9

/obj/item/clothing/shoes/griffin
	name = "griffon boots"
	desc = "A pair of costume boots fashioned after bird talons."
	icon_state = "griffinboots"
	item_state = "griffinboots"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes

/obj/item/clothing/shoes/bhop
	name = "jump boots"
	desc = "A specialized pair of combat boots with a built-in propulsion system for rapid foward movement."
	icon_state = "jetboots"
	item_state = "jetboots"
	item_color = "hosred"
	resistance_flags = FIRE_PROOF
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
	actions_types = list(/datum/action/item_action/bhop)
	permeability_coefficient = 0.05
	strip_delay = 30
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 3
	var/recharging_rate = 60 //default 6 seconds between each dash
	var/recharging_time = 0 //time until next dash

/obj/item/clothing/shoes/bhop/ui_action_click(mob/user, action)
	if(!isliving(user))
		return

	if(recharging_time > world.time)
		to_chat(user, "<span class='warning'>The boot's internal propulsion needs to recharge still!</span>")
		return

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction

	if (user.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE))
		playsound(src, 'sound/effects/stealthoff.ogg', 50, 1, 1)
		user.visible_message("<span class='warning'>[usr] dashes forward into the air!</span>")
		recharging_time = world.time + recharging_rate
	else
		to_chat(user, "<span class='warning'>Something prevents you from dashing forward!</span>")

/obj/item/clothing/shoes/singery
	name = "yellow performer's boots"
	desc = "These boots were made for dancing."
	icon_state = "ysing"
	equip_delay_other = 50

/obj/item/clothing/shoes/singerb
	name = "blue performer's boots"
	desc = "These boots were made for dancing."
	icon_state = "bsing"
	equip_delay_other = 50

/obj/item/clothing/shoes/bronze
	name = "bronze boots"
	desc = "A giant, clunky pair of shoes crudely made out of bronze. Why would anyone wear these?"
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_treads"

/obj/item/clothing/shoes/bronze/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/machines/clockcult/integration_cog_install.ogg' = 1, 'sound/magic/clockwork/fellowship_armory.ogg' = 1), 50)

/obj/item/clothing/shoes/wheelys
	name = "Wheely-Heels"
	desc = "Uses patented retractable wheel technology. Never sacrifice speed for style - not that this provides much of either." //Thanks Fel
	icon_state = "wheelys"
	item_state = "wheelys"
	actions_types = list(/datum/action/item_action/wheelys)
	var/wheelToggle = FALSE //False means wheels are not popped out
	var/obj/vehicle/ridden/scooter/wheelys/W

/obj/item/clothing/shoes/wheelys/Initialize()
	. = ..()
	W = new /obj/vehicle/ridden/scooter/wheelys(null)

/obj/item/clothing/shoes/wheelys/ui_action_click(mob/user, action)
	if(!isliving(user))
		return
	if(!istype(user.get_item_by_slot(SLOT_SHOES), /obj/item/clothing/shoes/wheelys))
		to_chat(user, "<span class='warning'>You must be wearing the wheely-heels to use them!</span>")
		return
	if(!(W.is_occupant(user)))
		wheelToggle = FALSE
	if(wheelToggle)
		W.unbuckle_mob(user)
		wheelToggle = FALSE
		return
	W.forceMove(get_turf(user))
	W.buckle_mob(user)
	wheelToggle = TRUE

/obj/item/clothing/shoes/wheelys/dropped(mob/user)
	if(wheelToggle)
		W.unbuckle_mob(user)
		wheelToggle = FALSE
	..()

/obj/item/clothing/shoes/wheelys/Destroy()
	QDEL_NULL(W)
	. = ..()

/obj/item/clothing/shoes/kindleKicks
	name = "Kindle Kicks"
	desc = "They'll sure kindle something in you, and it's not childhood nostalgia..."
	icon_state = "kindleKicks"
	item_state = "kindleKicks"
	actions_types = list(/datum/action/item_action/kindleKicks)
	var/lightCycle = 0
	var/active = FALSE

/obj/item/clothing/shoes/kindleKicks/ui_action_click(mob/user, action)
	if(active)
		return
	active = TRUE
	set_light(2, 3, rgb(rand(0,255),rand(0,255),rand(0,255)))
	addtimer(CALLBACK(src, .proc/lightUp), 5)

/obj/item/clothing/shoes/kindleKicks/proc/lightUp(mob/user)
	if(lightCycle < 15)
		set_light(2, 3, rgb(rand(0,255),rand(0,255),rand(0,255)))
		lightCycle += 1
		addtimer(CALLBACK(src, .proc/lightUp), 5)
	else
		set_light(0)
		lightCycle = 0
		active = FALSE

/obj/item/clothing/shoes/russian
	name = "russian boots"
	desc = "Comfy shoes."
	icon_state = "rus_shoes"
	item_state = "rus_shoes"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
