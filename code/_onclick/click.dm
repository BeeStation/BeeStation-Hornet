/*
	Click code cleanup
	~Sayu
*/

// 1 decisecond click delay (above and beyond mob/next_move)
//This is mainly modified by click code, to modify click delays elsewhere, use next_move and changeNext_move()
/mob/var/next_click	= 0

// THESE DO NOT EFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK
/mob/var/next_move_adjust = 0 //Amount to adjust action/click delays by, + or -
/mob/var/next_move_modifier = 1 //Value to multiply action/click delays by


//Delays the mob's next click/action by num deciseconds
// eg: 10-3 = 7 deciseconds of delay
// eg: 10*0.5 = 5 deciseconds of delay
// DOES NOT EFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK

/mob/proc/changeNext_move(num)
	next_move = world.time + ((num+next_move_adjust)*next_move_modifier)

/mob/living/changeNext_move(num)
	var/mod = next_move_modifier
	var/adj = next_move_adjust
	for(var/i in status_effects)
		var/datum/status_effect/S = i
		mod *= S.nextmove_modifier()
		adj += S.nextmove_adjust()
	next_move = world.time + ((num + adj)*mod)

/**
  * Before anything else, defer these calls to a per-mobtype handler.  This allows us to
  * remove istype() spaghetti code, but requires the addition of other handler procs to simplify it.
  *
  * Alternately, you could hardcode every mob's variation in a flat [/mob/proc/ClickOn] proc; however,
  * that's a lot of code duplication and is hard to maintain.
  *
  * Note that this proc can be overridden, and is in the case of screen objects.
  */
/atom/Click(location,control,params)
	if(flags_1 & INITIALIZED_1)
		SEND_SIGNAL(src, COMSIG_CLICK, location, control, params, usr)
		usr.ClickOn(src, params)

/atom/DblClick(location,control,params)
	if(flags_1 & INITIALIZED_1)
		usr.DblClickOn(src,params)

/atom/MouseWheel(delta_x,delta_y,location,control,params)
	if(flags_1 & INITIALIZED_1)
		usr.MouseWheelOn(src, delta_x, delta_y, params)

/**
  * Standard mob ClickOn()
  * Handles exceptions: Buildmode, middle click, modified clicks, mech actions
  *
  * After that, mostly just check your state, check whether you're holding an item,
  * check whether you're adjacent to the target, then pass off the click to whoever
  * is receiving it.
  * The most common are:
  * * [mob/proc/UnarmedAttack] (atom,adjacent) - used here only when adjacent, with no item in hand; in the case of humans, checks gloves
  * * [atom/proc/attackby] (item,user) - used only when adjacent
  * * [obj/item/proc/afterattack] (atom,user,adjacent,params) - used both ranged and adjacent
  * * [mob/proc/RangedAttack] (atom,params) - used only ranged, only used for tk and laser eyes but could be changed
  */
/mob/proc/ClickOn( atom/A, params )
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(check_click_intercept(params,A))
		return

	if(notransform)
		return

	if(SEND_SIGNAL(src, COMSIG_MOB_CLICKON, A, params) & COMSIG_MOB_CANCEL_CLICKON)
		return

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		if(LAZYACCESS(modifiers, MIDDLE_CLICK))
			ShiftMiddleClickOn(A, params)
			return
		if(LAZYACCESS(modifiers, CTRL_CLICK))
			CtrlShiftClickOn(A)
			return
		ShiftClickOn(A)
		return
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		if(LAZYACCESS(modifiers, CTRL_CLICK))
			CtrlMiddleClickOn(A)
			return
		MiddleClickOn(A, params)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK)) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClickOn(A)
		return

	if(incapacitated(ignore_restraints = 1))
		return

	face_atom(A)

	if(next_move > world.time) // in the year 2000...
		return

	if(!LAZYACCESS(modifiers, "catcher") && A.IsObscured())
		return

	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		changeNext_move(CLICK_CD_HANDCUFFED)   //Doing shit in cuffs shall be vey slow
		UnarmedAttack(A)
		return

	if(throw_mode && throw_item(A))
		changeNext_move(CLICK_CD_THROW)
		return

	var/obj/item/W = get_active_held_item()

	if(W == A)
		W.attack_self(src)
		update_inv_hands()
		return

	//These are always reachable.
	//User itself, current loc, and user inventory
	if(HasDirectAccess(A))
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A)
		return

	//Can't reach anything else in lockers or other weirdness
	if(!loc.AllowClick())
		return

	//Standard reach turf to turf or reaching inside storage
	if(CanReach(A,W))
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A,1)
	else
		if(W)
			W.afterattack(A,src,0,params)
		else
			RangedAttack(A,params)

/// Is the atom obscured by a PREVENT_CLICK_UNDER_1 object above it
/atom/proc/IsObscured()
	SHOULD_BE_PURE(TRUE)
	if(!isturf(loc)) //This only makes sense for things directly on turfs for now
		return FALSE
	var/turf/T = get_turf_pixel(src)
	if(!T)
		return FALSE
	for(var/atom/movable/AM in T)
		if(AM.flags_1 & PREVENT_CLICK_UNDER_1 && AM.density && AM.layer > layer)
			return TRUE
	return FALSE

/turf/IsObscured()
	for(var/atom/movable/AM in src)
		if(AM.flags_1 & PREVENT_CLICK_UNDER_1 && AM.density)
			return TRUE
	return FALSE

/**
  * A backwards depth-limited breadth-first-search to see if the target is
  * logically "in" anything adjacent to us.
  */
/atom/movable/proc/CanReach(atom/ultimate_target, obj/item/tool, view_only = FALSE)
	var/depth = 1 + (view_only ? STORAGE_VIEW_DEPTH : INVENTORY_DEPTH)

	var/list/closed = list()
	var/list/checking = list(ultimate_target)
	while (checking.len && depth > 0)
		var/list/next = list()
		--depth

		for(var/atom/target in checking)  // will filter out nulls
			if(closed[target] || isarea(target))  // avoid infinity situations
				continue
			if(isturf(target) || isturf(target.loc) || HasDirectAccess(target) || (isobj(target) && target.flags_1 & IS_ONTOP_1)) //Directly accessible atoms
				if(Adjacent(target) || (tool && CheckToolReach(src, target, tool.reach))) //Adjacent or reaching attacks
					return TRUE

			closed[target] = TRUE

			if (!target.loc)
				continue

			//Storage and things with reachable internal atoms need add to next here. Or return COMPONENT_ALLOW_REACH.
			if(SEND_SIGNAL(target.loc, COMSIG_ATOM_CANREACH, next) & COMPONENT_ALLOW_REACH)
				next += target.loc

		checking = next
	return FALSE

/atom/movable/proc/HasDirectAccess(atom/target)
	// We can always directly access ourselves
	if (target == src)
		return TRUE
	// We can directly access our location if it lets us touch it from the contents
	if (target == loc && !(target.flags_1 & NO_DIRECT_ACCESS_FROM_CONTENTS_1))
		return TRUE
	return FALSE

/mob/HasDirectAccess(atom/target)
	if (..())
		return TRUE
	if (istype(target, /atom/movable/screen))
		return TRUE
	// We can directly access things that are inside of us
	if (target.loc == src)
		return TRUE
	return FALSE

/mob/living/HasDirectAccess(atom/target)
	if (..())
		return TRUE
	// We can directly access things that are recursively inside of us
	var/atom/current = target
	while (current && !isturf(current))
		if (current == src)
			return TRUE
		current = current.loc
	return FALSE

/atom/proc/AllowClick()
	return FALSE

/turf/AllowClick()
	return TRUE

/proc/CheckToolReach(atom/movable/here, atom/movable/there, reach)
	if(!here || !there)
		return
	switch(reach)
		if(0)
			return FALSE
		if(1)
			return FALSE //here.Adjacent(there)
		if(2 to INFINITY)
			var/obj/dummy = new(get_turf(here))
			dummy.pass_flags |= PASSTABLE
			dummy.invisibility = INVISIBILITY_ABSTRACT
			for(var/i in 1 to reach) //Limit it to that many tries
				var/turf/T = get_step(dummy, get_dir(dummy, there))
				if(dummy.CanReach(there))
					qdel(dummy)
					return TRUE
				if(!dummy.Move(T)) //we're blocked!
					qdel(dummy)
					return
			qdel(dummy)

/// Default behavior: ignore double clicks (the second click that makes the doubleclick call already calls for a normal click)
/mob/proc/DblClickOn(atom/A, params)
	return


/**
  * Translates into [atom/proc/attack_hand], etc.
  *
  * Note: proximity_flag here is used to distinguish between normal usage (flag=1),
  * and usage when clicking on things telekinetically (flag=0).  This proc will
  * not be called at ranged except with telekinesis.
  *
  * proximity_flag is not currently passed to attack_hand, and is instead used
  * in human click code to allow glove touches only at melee range.
  */
/mob/proc/UnarmedAttack(atom/A, proximity_flag)
	if(ismob(A))
		changeNext_move(CLICK_CD_MELEE)
	return

/**
  * Ranged unarmed attack:
  *
  * This currently is just a default for all mobs, involving
  * laser eyes and telekinesis.  You could easily add exceptions
  * for things like ranged glove touches, spitting alien acid/neurotoxin,
  * animals lunging, etc.
  */
/mob/proc/RangedAttack(atom/A, params)
	SEND_SIGNAL(src, COMSIG_MOB_ATTACK_RANGED, A, params)

/**
  * Middle click
  * Mainly used for swapping hands
  */
/mob/proc/MiddleClickOn(atom/A, params)
	. = SEND_SIGNAL(src, COMSIG_MOB_MIDDLECLICKON, A, params)
	if(. & COMSIG_MOB_CANCEL_CLICKON)
		return
	swap_hand()

/**
  * Shift click
  * For most mobs, examine.
  * This is overridden in ai.dm
  */
/mob/proc/ShiftClickOn(atom/A)
	A.ShiftClick(src)
	return
/atom/proc/ShiftClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_SHIFT, user)
	if(user.client && user.client.eye == user || user.client.eye == user.loc)
		user.examinate(src)
	return

/**
  * Ctrl click
  * For most objects, pull
  */
/mob/proc/CtrlClickOn(atom/A)
	A.CtrlClick(src)
	return

/atom/proc/CtrlClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL, user)
	var/mob/living/ML = user
	if(istype(ML))
		ML.pulled(src)

/mob/living/carbon/human/CtrlClick(mob/user)
	if(ishuman(user) && Adjacent(user) && !user.incapacitated())
		if(world.time < user.next_move)
			return FALSE
		var/mob/living/carbon/human/H = user
		H.dna.species.grab(H, src, H.mind.martial_art)
		H.changeNext_move(CLICK_CD_MELEE)
	else
		..()

/mob/proc/CtrlMiddleClickOn(atom/A)
	// specifically made for admin feature.
	if(check_rights_for(client, R_ADMIN))
		client.toggle_tag_datum(A)
		return
	A.CtrlClick(src) // this assumes you did CtrlClick instead of MiddleClick
	return

/**
  * Alt click
  * Unused except for AI
  */
/mob/proc/AltClickOn(atom/A)
	. = SEND_SIGNAL(src, COMSIG_MOB_ALTCLICKON, A)
	if(. & COMSIG_MOB_CANCEL_CLICKON)
		return
	A.AltClick(src)

/atom/proc/AltClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_ALT, user)
	var/turf/T = get_turf(src)
	if(T && user.TurfAdjacent(T))
		user.listed_turf = T
		user.set_stat_tab(T.name)

/// Use this instead of [/mob/proc/AltClickOn] where you only want turf content listing without additional atom alt-click interaction
/atom/proc/AltClickNoInteract(mob/user, atom/A)
	var/turf/T = get_turf(A)
	if(T && user.TurfAdjacent(T))
		user.listed_turf = T
		user.set_stat_tab(T.name)

/mob/proc/TurfAdjacent(turf/T)
	return T.Adjacent(src)

/**
  * Control+Shift click
  * Used for AI and Give code
  */
/mob/proc/CtrlShiftClickOn(atom/A)
	A.CtrlShiftClick(src)
	return

/mob/proc/ShiftMiddleClickOn(atom/A, params)
	src.pointed(A, params)
	return

/atom/proc/CtrlShiftClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL_SHIFT)
	return

/*
	Misc helpers

	Laser Eyes: as the name implies, handles this since nothing else does currently
	face_atom: turns the mob towards what you clicked on
*/
/mob/proc/LaserEyes(atom/A, params)
	return

/mob/living/LaserEyes(atom/A, params)
	changeNext_move(CLICK_CD_RANGE)

	var/obj/projectile/beam/LE = new /obj/projectile/beam( loc )
	LE.icon = 'icons/effects/genetics.dmi'
	LE.icon_state = "eyelasers"
	playsound(usr.loc, 'sound/weapons/taser2.ogg', 75, 1)

	LE.firer = src
	LE.def_zone = ran_zone(get_combat_bodyzone(A))
	LE.preparePixelProjectile(A, src, params)
	LE.fire()

/// Simple helper to face what you clicked on, in case it should be needed in more than one place
/mob/proc/face_atom(atom/A)
	if( buckled || stat != CONSCIOUS || !A || !x || !y || !A.x || !A.y )
		return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy) // Wall items are graphically shifted but on the floor
		if(A.pixel_y > 16)
			setDir(NORTH)
		else if(A.pixel_y < -16)
			setDir(SOUTH)
		else if(A.pixel_x > 16)
			setDir(EAST)
		else if(A.pixel_x < -16)
			setDir(WEST)
		return

	if(abs(dx) < abs(dy))
		if(dy > 0)
			setDir(NORTH)
		else
			setDir(SOUTH)
	else
		if(dx > 0)
			setDir(EAST)
		else
			setDir(WEST)

//debug
/atom/movable/screen/proc/scale_to(x1,y1)
	if(!y1)
		y1 = x1
	var/matrix/M = new
	M.Scale(x1,y1)
	transform = M

/atom/movable/screen/click_catcher
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "catcher"
	plane = CLICKCATCHER_PLANE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	screen_loc = "CENTER"

#define MAX_SAFE_BYOND_ICON_SCALE_TILES (MAX_SAFE_BYOND_ICON_SCALE_PX / world.icon_size)
#define MAX_SAFE_BYOND_ICON_SCALE_PX (33 * 32)			//Not using world.icon_size on purpose.

/atom/movable/screen/click_catcher/proc/UpdateGreed(view_size_x = 15, view_size_y = 15)
	var/icon/newicon = icon('icons/mob/screen_gen.dmi', "catcher")
	var/ox = min(MAX_SAFE_BYOND_ICON_SCALE_TILES, view_size_x)
	var/oy = min(MAX_SAFE_BYOND_ICON_SCALE_TILES, view_size_y)
	var/px = view_size_x * world.icon_size
	var/py = view_size_y * world.icon_size
	var/sx = min(MAX_SAFE_BYOND_ICON_SCALE_PX, px)
	var/sy = min(MAX_SAFE_BYOND_ICON_SCALE_PX, py)
	newicon.Scale(sx, sy)
	icon = newicon
	screen_loc = "CENTER-[(ox-1)*0.5],CENTER-[(oy-1)*0.5]"
	var/matrix/M = new
	M.Scale(px/sx, py/sy)
	transform = M

/atom/movable/screen/click_catcher/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK) && iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.swap_hand()
	else
		var/turf/click_turf = parse_caught_click_modifiers(modifiers, get_turf(usr.client ? usr.client.eye : usr), usr.client)
		if (click_turf)
			modifiers["catcher"] = TRUE
			click_turf.Click(click_turf, control, list2params(modifiers))
	. = 1

/// MouseWheelOn
/mob/proc/MouseWheelOn(atom/A, delta_x, delta_y, params)
	SEND_SIGNAL(src, COMSIG_MOB_MOUSE_SCROLL_ON, A, delta_x, delta_y, params)
	if (!client)
		return
	// Send the hotkey action
	if (delta_y > 0)
		client.keyDown("ScrollUp")
		client.keyUp("ScrollUp")
	else if (delta_y < 0)
		client.keyDown("ScrollDown")
		client.keyUp("ScrollDown")

/mob/dead/observer/proc/mouse_wheeled(atom/A, delta_x, delta_y, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		var/view = 0
		if(delta_y > 0)
			view = -1
		else
			view = 1
		add_view_range(view)

/mob/proc/check_click_intercept(params,A)
	//Client level intercept
	if(client?.click_intercept)
		if(call(client.click_intercept, "InterceptClickOn")(src, params, A))
			return TRUE

	//Mob level intercept
	if(click_intercept)
		if(call(click_intercept, "InterceptClickOn")(src, params, A))
			return TRUE

	return FALSE
