//=================================================
//Clockwork wall: Causes nearby tinkerer's caches to generate components.
//=================================================
#define COGWALL_DECON_TOOLS list(\
	TOOL_WELDER,\
	TOOL_SCREWDRIVER,\
	TOOL_CROWBAR,\
	TOOL_WELDER,\
	TOOL_CROWBAR,\
	TOOL_SCREWDRIVER\
)

#define COGWALL_START_DECON_MESSAGES list(\
	"You begin welding off the outer cover.",\
	"You begin screwing out the maintenance hatch.",\
	"You begin prying open the maintenance hatch.",\
	"You begin welding off the outer plating.",\
	"You begin prying open the outer plating.",\
	"You begin screwing the frame apart."\
)

#define COGWALL_END_DECON_MESSAGES list(\
	"You weld off the outer cover.",\
	"You remove the screws from the maintenance hatch.",\
	"You pry open the maintenance hatch.",\
	"You weld off the outer plating.",\
	"You pry open the outer plating.",\
	"You screw the frame apart."\
)

#define COGWALL_START_RECON_MESSAGES list(\
	"You begin welding the outer cover back together.",\
	"You begin screwing in the maintenance hatch.",\
	"You begin prying the maintenance hatch shut.",\
	"You begin welding the outer plating back together.",\
	"You begin prying the outer plating shut.",\
)

#define COGWALL_END_RECON_MESSAGES list(\
	"You weld the outer cover back together.",\
	"You insert the screws into the maintenance hatch.",\
	"You pry the maintenance hatch shut.",\
	"You weld together the outer plating.",\
	"You pry the outer plating shut.",\
)

/turf/closed/wall/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	explosion_block = 2
	hardness = 10
	slicing_duration = 80
	sheet_type = /obj/item/stack/tile/brass
	sheet_amount = 1
	girder_type = /obj/structure/destructible/clockwork/wall_gear
	baseturfs = /turf/open/floor/clockwork/reebe
	var/obj/effect/clockwork/overlay/wall/realappearence
	var/reinforced = TRUE	//Walls will be reinforced if there is a direct path to the ark.
	var/d_state = INTACT

/turf/closed/wall/clockwork/Initialize()
	. = ..()
	new /obj/effect/temp_visual/ratvar/wall(src)
	new /obj/effect/temp_visual/ratvar/beam(src)
	realappearence = new /obj/effect/clockwork/overlay/wall(src)
	realappearence.linked = src
	calculate_reebe_pressure()

/turf/closed/wall/clockwork/Destroy()
	if(realappearence)
		qdel(realappearence)
		realappearence = null
	calculate_reebe_pressure()
	return ..()

/turf/closed/wall/clockwork/ReplaceWithLattice()
	..()
	for(var/obj/structure/lattice/L in src)
		L.ratvar_act()

/turf/closed/wall/clockwork/narsie_act()
	..()
	if(istype(src, /turf/closed/wall/clockwork)) //if we haven't changed type
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/turf/closed/wall/clockwork/ratvar_act()
	return 0

/turf/closed/wall/clockwork/dismantle_wall(devastated=0, explode=0)
	if(devastated)
		devastate_wall()
		ScrapeAway()
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		var/newgirder = break_wall()
		if(newgirder) //maybe we want a gear!
			transfer_fingerprints_to(newgirder)
		ScrapeAway()

	for(var/obj/O in src) //Eject contents!
		if(istype(O, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.forceMove(src)

/turf/closed/wall/clockwork/devastate_wall()
	for(var/i in 1 to 2)
		new/obj/item/clockwork/alloy_shards/large(src)
	for(var/i in 1 to 2)
		new/obj/item/clockwork/alloy_shards/medium(src)
	for(var/i in 1 to 3)
		new/obj/item/clockwork/alloy_shards/small(src)

/turf/closed/wall/clockwork/proc/make_reinforced()
	if(!reinforced)
		return
	new /obj/effect/temp_visual/ratvar/wall(get_turf(src))
	visible_message("<span class='warning'>The [src] glows brightly, it's cracks dissapearing and it's structure seeming a lot stronger!</span>", vision_distance = 3)
	update_icon()
	return

/turf/closed/wall/clockwork/proc/make_weak()
	if(reinforced)
		return
	playsound(src, 'sound/machines/clockcult/steam_whoosh.ogg', 30)
	if(prob(10))
		new /obj/effect/temp_visual/steam_release(get_turf(src))
	visible_message("<span class='warning'>The [src] shudders slightly, cracking open and appearing much weaker than before!</span>", vision_distance = 3)
	update_icon()
	return

//========Deconstruction Handled Here=======
/turf/closed/wall/clockwork/deconstruction_hints(mob/user)
	switch(d_state)
		if(INTACT)
			if(reinforced)
				return "<span class='notice'>There seems to be a metal cover <b>welded</b> in place.</span>"
			else
				return "<span class='notice'>The wall looks weak enough to <b>weld</b> the brass plates off.</span>"
		if(COG_COVER)
			return "<span class='notice'>The outer cover has been <i>welded</i> open, and an inner plate secured by <b>screws</b> is visable.</span>"
		if(COG_PLATING)
			return "<span class='notice'>The inner plating has been <i>unscrewed</i>, and it looks like it can be <b>pried</b> out!</span>"
		if(COG_EXPOSED)
			return "<span class='notice'>The inner plating has been <i>pried</i> open. The exterior plating is <b>welded</b> in place</span>"
		if(OUTER_BRASS)
			return "<span class='notice'>The exterior plating has been <i>welded</i> out and could be easily <b>pried</b> open!</span>"
		if(COG_WHEEL)
			return "<span class='notice'>The exterior plating has been <i>pried</i> open and only a couple of <b>screws</b> hold the frame together.</span>"

/turf/closed/wall/clockwork/try_decon(obj/item/I, mob/user, turf/T)
	if(is_servant_of_ratvar(user) || !reinforced)
		if(I.tool_behaviour != TOOL_WELDER)
			return 0
		if(!I.tool_start_check(user, amount=0))
			return 0
		to_chat(user, "<span class='warning'>You begin to weld apart the [src].</span>")
		if(I.use_tool(src, user, 40, volume=100))
			if(!istype(src, /turf/closed/wall/clockwork) || d_state != INTACT)
				return 0
			to_chat(user, "<span class='warning'>You weld the [src] apart!</span>")
			dismantle_wall()
			return 1
		return
	else
		return do_tooluse(I, user, d_state, COGWALL_DECON_TOOLS[d_state+1], d_state+1, d_state != INTACT ? COGWALL_DECON_TOOLS[d_state] : "nothing", d_state-1)

/turf/closed/wall/clockwork/proc/do_tooluse(obj/item/I, mob/user, wall_state, decon_tool, decon_state, recon_tool, recon_state)
	if(I.tool_behaviour == decon_tool)
		if(decon_tool == TOOL_WELDER && !I.tool_start_check(user, amount=0))
			return 0
		to_chat(user, "<span class='warning'>[COGWALL_START_DECON_MESSAGES[d_state+1]]</span>")
		if(I.use_tool(src, user, 40, volume=100))
			if(!istype(src, /turf/closed/wall/clockwork) || d_state != wall_state)
				return 0
			if(wall_state == COG_WHEEL)
				dismantle_wall()
			to_chat(user, "<span class='warning'>[COGWALL_END_DECON_MESSAGES[d_state+1]]</span>")
			d_state = decon_state
			update_icon()
			return 1
	else if(I.tool_behaviour == recon_tool)
		if(recon_tool == TOOL_WELDER && !I.tool_start_check(user, amount=0))
			return 0
		to_chat(user, "<span class='warning'>[COGWALL_START_RECON_MESSAGES[d_state]]</span>")
		if(I.use_tool(src, user, 60, volume=100))
			if(!istype(src, /turf/closed/wall/clockwork) || d_state != wall_state)
				return 0
			to_chat(user, "<span class='warning'>[COGWALL_END_RECON_MESSAGES[d_state]]</span>")
			d_state = recon_state
			update_icon()
			return 1
	return 0

/turf/closed/wall/clockwork/update_icon()
	. = ..()
	if(!reinforced)
		realappearence.icon_state = "clockwork_wall_crack"
		smooth = SMOOTH_TRUE
		queue_smooth_neighbors(src)
		queue_smooth(src)
	else if(d_state == INTACT)
		realappearence.icon_state = "clockwork_wall"
		smooth = SMOOTH_TRUE
		queue_smooth_neighbors(src)
		queue_smooth(src)
	else
		realappearence.icon_state = "clockwork_wall-[d_state]"
		smooth = SMOOTH_FALSE
		clear_smooth_overlays()
	realappearence.update_icon()
	return

//=================================================
//Clockwork floor: Slowly heals toxin damage on nearby servants.
//=================================================
/turf/open/floor/clockwork
	name = "clockwork floor"
	desc = "Tightly-pressed brass tiles. They emit minute vibration."
	icon_state = "plating"
	baseturfs = /turf/open/floor/clockwork
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	var/dropped_brass
	var/uses_overlay = TRUE
	var/obj/effect/clockwork/overlay/floor/realappearence

/turf/open/floor/clockwork/Bless() //Who needs holy blessings when you have DADDY RATVAR?
	return

/turf/open/floor/clockwork/Initialize()
	. = ..()
	if(uses_overlay)
		new /obj/effect/temp_visual/ratvar/floor(src)
		new /obj/effect/temp_visual/ratvar/beam(src)
		realappearence = new /obj/effect/clockwork/overlay/floor(src)
		realappearence.linked = src

/turf/open/floor/clockwork/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(uses_overlay && realappearence)
		QDEL_NULL(realappearence)
	return ..()

/turf/open/floor/clockwork/ReplaceWithLattice()
	. = ..()
	for(var/obj/structure/lattice/L in src)
		L.ratvar_act()

/turf/open/floor/clockwork/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/clockwork/crowbar_act(mob/living/user, obj/item/I)
	if(islist(baseturfs))
		if(type in baseturfs)
			return TRUE
	else if(baseturfs == type)
		return TRUE
	user.visible_message("<span class='notice'>[user] begins slowly prying up [src]...</span>", "<span class='notice'>You begin painstakingly prying up [src]...</span>")
	if(I.use_tool(src, user, 70, volume=80))
		user.visible_message("<span class='notice'>[user] pries up [src]!</span>", "<span class='notice'>You pry up [src]!</span>")
		make_plating()
	return TRUE

/turf/open/floor/clockwork/make_plating()
	if(!dropped_brass)
		new /obj/item/stack/tile/brass(src)
		dropped_brass = TRUE
	if(islist(baseturfs))
		if(type in baseturfs)
			return
	else if(baseturfs == type)
		return
	return ..()

/turf/open/floor/clockwork/narsie_act()
	..()
	if(istype(src, /turf/open/floor/clockwork)) //if we haven't changed type
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/turf/open/floor/clockwork/ratvar_act(force, ignore_mobs)
	return 0

/turf/open/floor/clockwork/reebe
	name = "cogplate"
	desc = "Warm brass plating. You can feel it gently vibrating, as if machinery is on the other side."
	icon_state = "reebe"
	baseturfs = /turf/open/floor/clockwork/reebe
	uses_overlay = FALSE
	planetary_atmos = TRUE

//=================================================
//Clockwork Lattice: It's a lattice for the ratvar
//=================================================

/obj/structure/lattice/clockwork
	name = "cog lattice"
	desc = "A lightweight support lattice. These hold the Justicar's station together."
	icon = 'icons/obj/smooth_structures/lattice_clockwork.dmi'

/obj/structure/lattice/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()
	if(is_reebe(z))
		resistance_flags |= INDESTRUCTIBLE

/obj/structure/lattice/clockwork/ratvar_act()
	if(ISODD(x+y))
		icon = 'icons/obj/smooth_structures/lattice_clockwork_large.dmi'
		pixel_x = -9
		pixel_y = -9
	else
		icon = 'icons/obj/smooth_structures/lattice_clockwork.dmi'
		pixel_x = 0
		pixel_y = 0
	return TRUE

//=================================================
//Clockwork Catwalk: Ratvarians choice of catwalk
//=================================================

/obj/structure/lattice/catwalk/clockwork
	name = "clockwork catwalk"
	icon = 'icons/obj/smooth_structures/catwalk_clockwork.dmi'
	canSmoothWith = list(/obj/structure/lattice,
	/turf/open/floor,
	/turf/closed/wall,
	/obj/structure/falsewall)
	smooth = SMOOTH_MORE

/obj/structure/lattice/catwalk/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()
	if(!mapload)
		new /obj/effect/temp_visual/ratvar/floor/catwalk(loc)
		new /obj/effect/temp_visual/ratvar/beam/catwalk(loc)
	if(is_reebe(z))
		resistance_flags |= INDESTRUCTIBLE

/obj/structure/lattice/catwalk/clockwork/ratvar_act()
	if(ISODD(x+y))
		icon = 'icons/obj/smooth_structures/catwalk_clockwork_large.dmi'
		pixel_x = -9
		pixel_y = -9
	else
		icon = 'icons/obj/smooth_structures/catwalk_clockwork.dmi'
		pixel_x = 0
		pixel_y = 0
	return TRUE

//=================================================
//Pinion airlocks: Clockwork doors that only let servants of Ratvar through.
//=================================================
/obj/machinery/door/airlock/clockwork
	name = "pinion airlock"
	desc = "A massive cogwheel set into two heavy slabs of brass. Contains tiny vents for allowing the flow of pressure."
	icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi'
	overlays_file = 'icons/obj/doors/airlocks/clockwork/overlays.dmi'
	hackProof = TRUE
	aiControlDisabled = 1
	req_access = list(ACCESS_CLOCKCULT)
	use_power = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	damage_deflection = 30
	normal_integrity = 240
	air_tight = FALSE
	CanAtmosPass = ATMOS_PASS_YES
	var/construction_state = GEAR_SECURE //Pinion airlocks have custom deconstruction

/obj/machinery/door/airlock/clockwork/Initialize()
	. = ..()
	new /obj/effect/temp_visual/ratvar/door(loc)
	new /obj/effect/temp_visual/ratvar/beam/door(loc)

/obj/machinery/door/airlock/clockwork/Destroy()
	return ..()

/obj/machinery/door/airlock/clockwork/examine(mob/user)
	. = ..()
	var/gear_text = "The cogwheel is flickering and twisting wildly. Report this to a coder."
	switch(construction_state)
		if(GEAR_SECURE)
			gear_text = "<span class='brass'>The cogwheel is solidly <b>wrenched</b> to the brass around it.</span>"
		if(GEAR_LOOSE)
			gear_text = "<span class='alloy'>The cogwheel has been <i>loosened</i>, but remains <b>connected loosely</b> to the door!</span>"
	. += gear_text

/obj/machinery/door/airlock/clockwork/emp_act(severity)
	if(prob(80/severity))
		open()

/obj/machinery/door/airlock/clockwork/narsie_act()
	..()
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/obj/machinery/door/airlock/clockwork/ratvar_act()
	return 0

/obj/machinery/door/airlock/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(!attempt_construction(I, user))
		return ..()

/obj/machinery/door/airlock/clockwork/allowed(mob/M)
	return 0

/obj/machinery/door/airlock/clockwork/hasPower()
	return TRUE //yes we do have power

/obj/machinery/door/airlock/clockwork/obj_break(damage_flag)
	return

/obj/machinery/door/airlock/clockwork/deconstruct(disassembled = TRUE)
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(src)
		if(disassembled)
			new/obj/item/stack/tile/brass(T, 4)
		else
			new/obj/item/clockwork/alloy_shards(T)
	qdel(src)

/obj/machinery/door/airlock/clockwork/proc/attempt_construction(obj/item/I, mob/living/user)
	if(!I || !user || !user.canUseTopic(src))
		return 0
	else if(I.tool_behaviour == TOOL_WRENCH)
		if(construction_state == GEAR_SECURE)
			user.visible_message("<span class='notice'>[user] begins loosening [src]'s cogwheel...</span>", "<span class='notice'>You begin loosening [src]'s cogwheel...</span>")
			if(!I.use_tool(src, user, 75, volume=50) || construction_state != GEAR_SECURE)
				return 1
			user.visible_message("<span class='notice'>[user] loosens [src]'s cogwheel!</span>", "<span class='notice'>[src]'s cogwheel pops off and dangles loosely.</span>")
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			construction_state = GEAR_LOOSE
		else if(construction_state == GEAR_LOOSE)
			user.visible_message("<span class='notice'>[user] begins tightening [src]'s cogwheel...</span>", "<span class='notice'>You begin tightening [src]'s cogwheel into place...</span>")
			if(!I.use_tool(src, user, 75, volume=50) || construction_state != GEAR_LOOSE)
				return 1
			user.visible_message("<span class='notice'>[user] tightens [src]'s cogwheel!</span>", "<span class='notice'>You firmly tighten [src]'s cogwheel into place.</span>")
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			construction_state = GEAR_SECURE
		return 1
	else if(I.tool_behaviour == TOOL_CROWBAR)
		if(construction_state == GEAR_SECURE)
			to_chat(user, "<span class='warning'>[src]'s cogwheel is too tightly secured! Your [I.name] can't reach under it!</span>")
			return 1
		else if(construction_state == GEAR_LOOSE)
			user.visible_message("<span class='notice'>[user] begins slowly lifting off [src]'s cogwheel...</span>", "<span class='notice'>You slowly begin lifting off [src]'s cogwheel...</span>")
			if(!I.use_tool(src, user, 75, volume=50) || construction_state != GEAR_LOOSE)
				return 1
			user.visible_message("<span class='notice'>[user] lifts off [src]'s cogwheel, causing it to fall apart!</span>", \
			"<span class='notice'>You lift off [src]'s cogwheel, causing it to fall apart!</span>")
			deconstruct(TRUE)
		return 1
	return 0

/obj/machinery/door/airlock/clockwork/brass
	glass = TRUE
	opacity = 0

//=================================================
//Servant Blocker: Doesn't allow servants to pass
//=================================================
/obj/effect/clockwork/servant_blocker
	name = "Servant Blocker"
	desc = "You shall not pass."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "servant_blocker"

/obj/effect/clockwork/servant_blocker/CanPass(atom/movable/mover, turf/target)
	if(is_servant_of_ratvar(mover))
		return FALSE
	return ..()
