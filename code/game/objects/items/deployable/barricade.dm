
#define METAL 1
#define WOOD 2
#define SAND 3

//Largely unutilized subtype, add some more types of barricades!
/obj/item/deployable/barricade
	name = "Generic Barricade"
	desc = "You should never see this"
	time_to_deploy = 3 SECONDS

/obj/item/deployable/barricade/security
	name = "security barricade"
	desc = "A very sturdy barricade for use by Nanotrasen security personnel."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"
	deployed_object = /obj/structure/barricade/security
	time_to_deploy = 3 SECONDS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/box/sec_barricades
	name = "box of barricades"
	desc = "A box full of sturdy security barricades"
	icon_state = "secbox"
	illustration = "syndiesuit"

/obj/item/storage/box/sec_barricades/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/deployable/barricade/security(src)

//Barricades in structure form
/obj/structure/barricade
	name = "chest high wall"
	desc = "Looks like this would make good cover."
	anchored = TRUE
	density = TRUE
	max_integrity = 100
	///probability that projectiles will pass the cover
	var/proj_pass_rate = 50
	///determines how and if the barricade can be repaired
	var/bar_material = METAL
	///How long it takes to collect the barricade
	var/pickup_delay = 8 SECONDS
	///Whether the barricade can be picked up while damaged, resulting in reduced recovery of materials
	var/pickup_damaged = TRUE
	///Set to TRUE if the barricade can be ID locked
	var/locked_down
	///How many materials are returned if the barricade is picked up at full integrity
	var/drop_amount = 1

/obj/structure/barricade/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		make_debris()
	qdel(src)

/obj/structure/barricade/proc/make_debris()
	return

/obj/structure/barricade/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM && bar_material == METAL)
		if(obj_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=0))
				return

			to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
			if(I.use_tool(src, user, 40, volume=40))
				obj_integrity = CLAMP(obj_integrity + 20, 0, max_integrity)

	else if(I.GetID() && initial(locked_down))
		if(allowed(user))
			locked_down = !locked_down
			to_chat(user, "<span class='notice'>You [locked_down ? "lock" : "unlock"] the release mechanism.</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	else
		return ..()

/obj/structure/barricade/CanAllowThrough(atom/movable/mover, turf/target)//So bullets will fly over and stuff.
	. = ..()
	if(locate(/obj/structure/barricade) in get_turf(mover))
		return TRUE
	else if(istype(mover, /obj/projectile))
		if(!anchored)
			return TRUE
		var/obj/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return TRUE
		if(prob(proj_pass_rate))
			return TRUE
		return FALSE

/obj/structure/barricade/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
			return
		if(!pickup_damaged && obj_integrity < max_integrity)
			to_chat(usr, "<span class='warning'>[src] is damaged! You'll have to repair it before you can relocate it.</span>")
			return
		if(locked_down)
			to_chat(usr, "<span class='warning'>[src] is still locked down! Swipe your ID to unlock it.</span>")
			return

		usr.visible_message("<span class='notice'>[usr] begins breaking down [src]</span>", "<span class='notice'>You begin breaking down [src].</span>")
		if(do_after(usr, pickup_delay, src))

			//If the barricade is made of parts, some of them are damaged when the barricade is damaged so we set how many are being returned here
			if(initial(drop_amount) > 1)
				drop_amount = round(drop_amount * (obj_integrity/max_integrity))
			//If we are only picking up one item at most, it has a chance to fall apart based on damage the barricade accrued. Will always succeed if pickup_damaged is false.
			else if(!prob(round((obj_integrity/max_integrity), 0.01) * 100))
				usr.visible_message("<span class='notice'>[usr] tries to pick up [src] but it falls apart!</span>", "<span class='notice'>[src] is too damaged and falls apart!</span>")
				qdel(src)
				return

			usr.visible_message("<span class='notice'>[usr] picks up [src].</span>", "<span class='notice'>You pick up [src].</span>")
			qdel(src)
			pick_up_barricade()

/obj/structure/barricade/proc/pick_up_barricade()

//Barricade types
/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	bar_material = WOOD
	pickup_delay = 15 SECONDS
	drop_amount = 5

/obj/structure/barricade/wooden/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/W = I
		if(W.amount < 5)
			to_chat(user, "<span class='warning'>You need at least five wooden planks to make a wall!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You start adding [I] to [src]...</span>")
			if(do_after(user, 50, target=src))
				W.use(5)
				var/turf/T = get_turf(src)
				T.PlaceOnTop(/turf/closed/wall/mineral/wood/nonmetal)
				transfer_fingerprints_to(T)
				qdel(src)
				return
	return ..()

/obj/structure/barricade/wooden/pick_up_barricade()
	var/obj/item/stack/sheet/wood/planks = new(loc, drop_amount)
	usr.put_in_hands(planks)

/obj/structure/barricade/wooden/crude
	name = "crude plank barricade"
	desc = "This space is blocked off by a crude assortment of planks."
	icon_state = "woodenbarricade-old"
	drop_amount = 3
	max_integrity = 50
	proj_pass_rate = 65
	pickup_delay = 8 SECONDS

/obj/structure/barricade/wooden/crude/snow
	desc = "This space is blocked off by a crude assortment of planks. It seems to be covered in a layer of snow."
	icon_state = "woodenbarricade-snow-old"
	max_integrity = 75

/obj/structure/barricade/wooden/make_debris()
	new /obj/item/stack/sheet/wood(get_turf(src), drop_amount)

/obj/structure/barricade/sandbags
	name = "sandbag barricade"
	desc = "Bags of sand. Self explanatory."
	icon = 'icons/obj/smooth_structures/sandbags.dmi'
	icon_state = "sandbags-0"
	base_icon_state = "sandbags"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_SANDBAGS)
	canSmoothWith = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_SECURITY_BARRICADE, SMOOTH_GROUP_SANDBAGS)
	max_integrity = 280
	proj_pass_rate = 20
	pass_flags_self = LETPASSTHROW
	bar_material = SAND

/obj/structure/barricade/sandbags/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)

/obj/structure/barricade/sandbags/pick_up_barricade()
	var/obj/item/stack/sheet/sandbags/sandbag = new(loc)
	usr.put_in_hands(sandbag)

/obj/structure/barricade/security
	name = "security barrier"
	desc = "A deployable barrier. Provides good cover in fire fights.\nCan be repaired with a welding tool."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier1"
	max_integrity = 180
	proj_pass_rate = 20
	armor = list(MELEE = 10,  BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 100, RAD = 100, FIRE = 10, ACID = 0, STAMINA = 0)
	req_access = list(ACCESS_SECURITY)
	pickup_damaged = FALSE
	locked_down = TRUE

/obj/structure/barricade/security/pick_up_barricade()
	var/obj/item/deployable/barricade/security/carryable = new(loc)
	usr.put_in_hands(carryable)

#undef METAL
#undef WOOD
#undef SAND
