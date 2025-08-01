/*****************************Survival Pod********************************/
/area/survivalpod
	name = "\improper Emergency Shelter"
	icon_state = "away"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA

//Survival Capsule
/obj/item/survivalcapsule
	name = "bluespace shelter capsule"
	desc = "An emergency shelter stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/template_id = "shelter_alpha"
	var/datum/map_template/shelter/template
	var/used = FALSE

/obj/item/survivalcapsule/proc/get_template()
	if(template)
		return
	template = SSmapping.shelter_templates[template_id]
	if(!template)
		WARNING("Shelter template ([template_id]) not found!")
		qdel(src)

/obj/item/survivalcapsule/Destroy()
	template = null // without this, capsules would be one use. per round.
	air_update_turf(TRUE, FALSE)
	. = ..()

/obj/item/survivalcapsule/examine(mob/user)
	. = ..()
	get_template()
	if(template)
		. += "This capsule has the [template.name] stored."
		. += template.description

/obj/item/survivalcapsule/attack_self()
	//Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(!used)
		loc.visible_message(span_warning("\The [src] begins to shake. Stand back!"))
		used = TRUE
		sleep(50)
		var/turf/deploy_location = get_turf(src)
		var/status = template.check_deploy(deploy_location)
		switch(status)
			if(SHELTER_DEPLOY_BAD_AREA)
				src.loc.visible_message(span_warning("\The [src] will not function in this area."))
			if(SHELTER_DEPLOY_BAD_TURFS, SHELTER_DEPLOY_ANCHORED_OBJECTS)
				var/width = template.width
				var/height = template.height
				src.loc.visible_message(span_warning("\The [src] doesn't have room to deploy! You need to clear a [width]x[height] area!"))

		if(status != SHELTER_DEPLOY_ALLOWED)
			used = FALSE
			return

		playsound(src, 'sound/effects/phasein.ogg', 100, 1)

		var/turf/T = deploy_location
		if(!is_mining_level(T.z)) //only report capsules away from the mining/lavaland level
			message_admins("[ADMIN_LOOKUPFLW(usr)] activated a bluespace capsule away from the mining level! [ADMIN_VERBOSEJMP(T)]")
			log_admin("[key_name(usr)] activated a bluespace capsule away from the mining level at [AREACOORD(T)]")
		template.load(deploy_location, centered = TRUE)
		new /obj/effect/particle_effect/smoke(get_turf(src))
		qdel(src)

/obj/item/survivalcapsule/luxury
	name = "luxury bluespace shelter capsule"
	desc = "An exorbitantly expensive luxury suite stored within a pocket of bluespace."
	icon_state = "capsulelux"
	template_id = "shelter_beta"

/obj/item/survivalcapsule/luxuryelite
	name = "luxury elite bar capsule"
	desc = "A luxury bar in a capsule. Bartender required and not included."
	icon_state = "capsuleluxelite"
	template_id = "shelter_charlie"

/obj/item/survivalcapsule/encampment
	name = "mining encampment capsule"
	desc = "A medium-sized mining encampment in a capsule. A home away from home, away from home!"
	icon_state = "capsulecamp"
	template_id = "shelter_delta"

/obj/item/survivalcapsule/medical
	name = "emergency medical capsule"
	desc = "A small pod with medical facilities designed for station emergencies inside a bluespace capsule. Do NOT swallow."
	icon_state = "capsulemed"
	icon = 'icons/obj/mining.dmi'
	template_id = "shelter_echo"

/obj/item/survivalcapsule/space
	name = "space shelter capsule"
	desc = "A spaceworthy shelter designed for emergencies/construction in a bluespace capsule."
	icon_state = "capsuleeng"
	icon = 'icons/obj/mining.dmi'
	template_id = "shelter_eta"

/obj/item/survivalcapsule/barricade
	name = "barricade capsule"
	desc = "A 3x3 glass barricade designed for security use with energy weapons."
	icon_state = "capsulesec"
	icon = 'icons/obj/mining.dmi'
	template_id = "capsule_barricade"

/obj/item/survivalcapsule/capsule_checkpoint
	name = "checkpoint capsule"
	desc = "A 3x3 glass checkpoint designed for allowing safely searching passing personnel."
	icon_state = "capsulesec"
	icon = 'icons/obj/mining.dmi'
	template_id = "capsule_checkpoint"

/obj/item/survivalcapsule/party
	name = "party capsule"
	desc = "A 7x7 party area, fit with tables and a dancefloor. Groovy."
	icon_state = "capsuleparty"
	icon = 'icons/obj/mining.dmi'
	template_id = "shelter_theta"

//Pod objects

//Window
/obj/structure/window/shuttle/survival_pod
	name = "pod window"
	icon = 'icons/obj/smooth_structures/windows/pod_window.dmi'
	icon_state = "pod_window-0"
	base_icon_state = "pod_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_SURVIVAL_TIANIUM_POD, SMOOTH_GROUP_SHUTTLE_PARTS)
	canSmoothWith = list(SMOOTH_GROUP_SURVIVAL_TIANIUM_POD)

/obj/structure/window/shuttle/survival_pod/spawner/north
	dir = NORTH

/obj/structure/window/shuttle/survival_pod/spawner/east
	dir = EAST

/obj/structure/window/shuttle/survival_pod/spawner/west
	dir = WEST

/obj/structure/window/reinforced/survival_pod
	name = "pod window"
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "pwindow"

/obj/structure/window/reinforced/survival_pod/corner
	icon_state = "pwindow_corner"
	density = FALSE

//Door
/obj/machinery/door/airlock/survival_pod
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/survival/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/survival_overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_pod
	anim_parts = "topbolts=0,6,0,3;bottombolts=0,-6,3,-6;top=0,4,0,2;bottom=0,-4,0,2;rightbolts=14,0,1.5,5;left=-15,0,1.5,5;right=14,0,1.5,5"

/obj/machinery/door/airlock/survival_pod/glass
	opacity = FALSE
	glass = TRUE

/obj/structure/door_assembly/door_assembly_pod
	name = "pod airlock assembly"
	icon = 'icons/obj/doors/airlocks/survival/survival.dmi'
	base_name = "pod airlock"
	overlays_file = 'icons/obj/doors/airlocks/survival/survival_overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/survival_pod
	glass_type = /obj/machinery/door/airlock/survival_pod/glass

//Windoor
/obj/machinery/door/window/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "windoor"
	base_state = "windoor"

//Table
/obj/structure/table/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "table"
	smoothing_flags = NONE

//Sleeper
/obj/machinery/sleeper/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "sleeper"
	roundstart_vials = list()

/obj/machinery/sleeper/survival_pod/update_icon()
	if(state_open)
		cut_overlays()
	else
		add_overlay("sleeper_cover")

//Lifeform Stasis Unit
/obj/machinery/stasis/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "sleeper"
	mattress_state = null
	buckle_lying = 270

/obj/machinery/stasis/survival_pod/play_power_sound()
	return

/obj/machinery/stasis/survival_pod/update_icon()
	return

//NanoMed
/obj/machinery/vending/wallmed/survival_pod
	name = "survival pod medical supply"
	desc = "Wall-mounted Medical Equipment dispenser. This one seems just a tiny bit smaller."
	refill_canister = null
	onstation = FALSE

//Computer
/obj/item/gps/computer
	name = "pod computer"
	icon_state = "pod_computer"
	icon = 'icons/obj/lavaland/pod_computer.dmi'
	anchored = TRUE
	density = TRUE
	pixel_y = -32

/obj/item/gps/computer/wrench_act(mob/living/user, obj/item/I)
	if(flags_1 & NODECONSTRUCT_1)
		return TRUE

	user.visible_message(span_warning("[user] disassembles [src]."),
		span_notice("You start to disassemble [src]..."), "You hear clanking and banging noises.")
	if(I.use_tool(src, user, 20, volume=50))
		new /obj/item/gps(loc)
		qdel(src)
	return TRUE

/obj/item/gps/computer/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	attack_self(user)

//Beds
/obj/structure/bed/pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "bed"

/obj/structure/bed/double/pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "bed_double"

//Survival Storage Unit
/obj/machinery/smartfridge/survival_pod
	name = "survival pod storage"
	desc = "A heated storage unit."
	icon_state = "donkvendor"
	icon = 'icons/obj/lavaland/donkvendor.dmi'
	base_build_path = /obj/machinery/smartfridge/survival_pod
	light_range = 5
	light_power = 1.2
	light_color = "#DDFFD3"
	max_n_of_items = 10
	pixel_y = -4
	flags_1 = NODECONSTRUCT_1
	opacity = FALSE

/obj/machinery/smartfridge/survival_pod/update_icon()
	return

/obj/machinery/smartfridge/survival_pod/preloaded/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 5)
		var/obj/item/food/donkpocket/warm/W = new(src)
		load(W)
	if(prob(50))
		var/obj/item/storage/pill_bottle/dice/D = new(src)
		load(D)
	else
		var/obj/item/instrument/guitar/G = new(src)
		load(G)

/obj/machinery/smartfridge/survival_pod/accept_check(obj/item/O)
	return isitem(O)

//Fans
/obj/structure/fans
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "fans"
	name = "environmental regulation system"
	desc = "A large machine releasing a constant gust of air."
	anchored = TRUE
	density = TRUE
	var/buildstacktype = /obj/item/stack/sheet/iron
	var/buildstackamount = 5
	can_atmos_pass = ATMOS_PASS_NO

/obj/structure/fans/deconstruct()
	if(!(flags_1 & NODECONSTRUCT_1))
		if(buildstacktype)
			new buildstacktype(loc,buildstackamount)
	qdel(src)

/obj/structure/fans/wrench_act(mob/living/user, obj/item/I)
	if(flags_1 & NODECONSTRUCT_1)
		return TRUE

	user.visible_message(span_warning("[user] disassembles [src]."),
		span_notice("You start to disassemble [src]..."), "You hear clanking and banging noises.")
	if(I.use_tool(src, user, 20, volume=50))
		deconstruct()
	return TRUE

/obj/structure/fans/tiny
	name = "tiny fan"
	desc = "A tiny fan, releasing a thin gust of air."
	layer = ABOVE_NORMAL_TURF_LAYER
	density = FALSE
	icon_state = "fan_tiny"
	buildstackamount = 2

/obj/structure/fans/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE, TRUE)

//Inivisible, indestructible fans
/obj/structure/fans/tiny/invisible
	name = "air flow blocker"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_ABSTRACT

//Signs
/obj/structure/sign/mining
	name = "nanotrasen mining corps sign"
	desc = "A sign of relief for weary miners, and a warning for would-be competitors to Nanotrasen's mining claims."
	icon_state = "minskymine"

/obj/structure/sign/mining/survival
	name = "shelter sign"
	desc = "A high visibility sign designating a safe shelter."
	icon_state = "securearea"

//Fluff
/obj/structure/tubes
	icon_state = "tubes"
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	name = "tubes"
	anchored = TRUE
	layer = BELOW_MOB_LAYER
	density = FALSE

/obj/item/fakeartefact
	name = "expensive forgery"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	var/possible = list(/obj/item/ship_in_a_bottle,
						/obj/item/gun/energy/pulse,
						/obj/item/book/granter/martial/carp,
						/obj/item/melee/supermatter_sword,
						/obj/item/lava_staff,
						/obj/item/energy_katana,
						/obj/item/hierophant_club,
						/obj/item/his_grace,
						/obj/item/gun/energy/minigun,
						/obj/item/gun/ballistic/automatic/l6_saw,
						/obj/item/gun/magic/staff/chaos,
						/obj/item/gun/magic/staff/spellblade,
						/obj/item/gun/magic/wand/death,
						/obj/item/gun/magic/wand/fireball,
						/obj/item/stack/sheet/telecrystal/twenty,
						/obj/item/nuke_core,
						/obj/item/banhammer)

/obj/item/fakeartefact/Initialize(mapload)
	. = ..()
	var/obj/item/I = pick(possible)
	name = initial(I.name)
	icon = initial(I.icon)
	desc = initial(I.desc)
	icon_state = initial(I.icon_state)
	item_state = initial(I.item_state)
