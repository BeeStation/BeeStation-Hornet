/// below these levels trigger the special sprites
#define PAINTER_MOST 0.76
#define PAINTER_MID 0.5
#define PAINTER_LOW 0.2


/obj/item/airlock_painter
	name = "airlock painter"
	desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks. Use it on an airlock during or after construction to change the paintjob. Alt-Click to remove the ink cartridge."
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint_sprayer"
	item_state = "paint_sprayer"

	w_class = WEIGHT_CLASS_SMALL

	materials = list(/datum/material/iron=50, /datum/material/glass=50)

	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	usesound = 'sound/effects/spray2.ogg'

	/// The ink cartridge to pull charges from.
	var/obj/item/toner/ink = null
	/// The type path to instantiate for the ink cartridge the device initially comes with, eg. /obj/item/toner
	var/initial_ink_type = /obj/item/toner
	/// Associate list of all paint jobs the airlock painter can apply. The key is the name of the airlock the user will see. The value is the type path of the airlock
	var/list/available_paint_jobs = list(
		"Public" = /obj/machinery/door/airlock/public,
		"Engineering" = /obj/machinery/door/airlock/engineering,
		"Atmospherics" = /obj/machinery/door/airlock/atmos,
		"Security" = /obj/machinery/door/airlock/security,
		"Command" = /obj/machinery/door/airlock/command,
		"Medical" = /obj/machinery/door/airlock/medical,
		"Research" = /obj/machinery/door/airlock/research,
		"Freezer" = /obj/machinery/door/airlock/freezer,
		"Science" = /obj/machinery/door/airlock/science,
		"Mining" = /obj/machinery/door/airlock/mining,
		"Maintenance" = /obj/machinery/door/airlock/maintenance,
		"External" = /obj/machinery/door/airlock/external,
		"External Maintenance"= /obj/machinery/door/airlock/maintenance/external,
		"Virology" = /obj/machinery/door/airlock/virology,
		"Standard" = /obj/machinery/door/airlock
	)

/obj/item/airlock_painter/Initialize(mapload)
	. = ..()
	ink = new initial_ink_type(src)

/obj/item/airlock_painter/update_icon()
	var/base = initial(icon_state)
	if(!istype(ink))
		icon_state = "[base]_none"
		return
	switch(ink.charges/ink.max_charges)
		if(0.001 to PAINTER_LOW)
			icon_state = "[base]_low"
		if(PAINTER_LOW to PAINTER_MID)
			icon_state = "[base]_mid"
		if(PAINTER_MID to PAINTER_MOST)
			icon_state = "[base]_most"
		if(PAINTER_MOST to INFINITY)
			icon_state = base
		else
			icon_state = "[base]_empty"


//This proc doesn't just check if the painter can be used, but also uses it.
//Only call this if you are certain that the painter will be used right after this check!
/obj/item/airlock_painter/proc/use_paint(mob/user)
	if(can_use(user))
		ink.charges--
		update_icon()
		playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1)
		return TRUE
	else
		return FALSE

//This proc only checks if the painter can be used.
//Call this if you don't want the painter to be used right after this check, for example
//because you're expecting user input.
/obj/item/airlock_painter/proc/can_use(mob/user)
	if(!ink)
		to_chat(user, "<span class='notice'>There is no toner cartridge installed in [src]!</span>")
		return FALSE
	else if(ink.charges < 1)
		to_chat(user, "<span class='notice'>[src] is out of ink!</span>")
		return FALSE
	else
		return TRUE

/obj/item/airlock_painter/suicide_act(mob/user)
	var/obj/item/organ/lungs/L = user.getorganslot(ORGAN_SLOT_LUNGS)

	if(can_use(user) && L)
		user.visible_message("<span class='suicide'>[user] is inhaling toner from [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		use(user)

		// Once you've inhaled the toner, you throw up your lungs
		// and then die.

		// Find out if there is an open turf in front of us,
		// and if not, pick the turf we are standing on.
		var/turf/T = get_step(get_turf(src), user.dir)
		if(!isopenturf(T))
			T = get_turf(src)

		// they managed to lose their lungs between then and
		// now. Good job.
		if(!L)
			return OXYLOSS

		L.Remove(user)

		// make some colorful reagent, and apply it to the lungs
		L.create_reagents(10)
		L.reagents.add_reagent(/datum/reagent/colorful_reagent, 10)
		L.reagents.reaction(L, TOUCH, 1)

		// TODO maybe add some colorful vomit?

		user.visible_message("<span class='suicide'>[user] vomits out [user.p_their()] [L]!</span>")
		playsound(user.loc, 'sound/effects/splat.ogg', 50, 1)

		L.forceMove(T)

		return (TOXLOSS|OXYLOSS)
	else if(can_use(user) && !L)
		user.visible_message("<span class='suicide'>[user] is spraying toner on [user.p_them()]self from [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
		user.reagents.add_reagent(/datum/reagent/colorful_reagent, 1)
		user.reagents.reaction(user, TOUCH, 1)
		return TOXLOSS

	else
		user.visible_message("<span class='suicide'>[user] is trying to inhale toner from [src]! It might be a suicide attempt if [src] had any toner.</span>")
		return SHAME


/obj/item/airlock_painter/examine(mob/user)
	. = ..()
	if(!ink)
		. += "<span class='notice'>The ink compartment hangs open.</span>"
		return
	var/ink_level = "high"
	switch(ink.charges/ink.max_charges)
		if(0.001 to PAINTER_LOW)
			ink_level = "extremely low"
		if(PAINTER_LOW to PAINTER_MID)
			ink_level = "low"
		if(PAINTER_MID to 1)
			ink_level = "high"
		if(1 to INFINITY) //Over 100% (admin var edit)
			ink_level = "dangerously high"
	if(ink.charges <= 0)
		ink_level = "empty"

	. += "<span class='notice'>Its ink levels look [ink_level].</span>"


/obj/item/airlock_painter/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toner))
		if(ink)
			to_chat(user, "<span class='notice'>[src] already contains \a [ink].</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return
		to_chat(user, "<span class='notice'>You install [W] into [src].</span>")
		ink = W
		update_icon()
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	else
		return ..()

/obj/item/airlock_painter/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(ink)
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		ink.forceMove(user.drop_location())
		user.put_in_hands(ink)
		to_chat(user, "<span class='notice'>You remove [ink] from [src].</span>")
		ink = null
		update_icon()

/obj/item/airlock_painter/decal
	name = "decal painter"
	desc = "An airlock painter, reprogramed to use a different style of paint in order to apply decals for floor tiles as well, in addition to repainting doors. Decals break when the floor tiles are removed. Alt-Click to remove the ink cartridge."
	icon = 'icons/obj/objects.dmi'
	icon_state = "decal_sprayer"
	item_state = "decal_sprayer"
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=50)
	initial_ink_type = /obj/item/toner/large
	/// The current direction of the decal being printed
	var/stored_dir = SOUTH
	/// The current color of the decal being printed.
	var/stored_color = "yellow"
	/// The current base icon state of the decal being printed.
	var/stored_decal = "warningline"
	/// The full icon state of the decal being printed.
	var/stored_decal_total = "warningline"
	/// The type path of the spritesheet being used for the frontend.
	var/spritesheet_type = /datum/asset/spritesheet/decals // spritesheet containing previews
	/// Does this printer implementation support custom colors?
	var/supports_custom_color = FALSE
	/// Current custom color
	var/stored_custom_color
	/// List of color options as list(user-friendly label, color value to return)
	var/color_list = list(
		list("Yellow", "yellow"),
		list("Red", "red"),
		list("White", "white"),
	)
	/// List of direction options as list(user-friendly label, dir value to return)
	var/dir_list = list(
		list("North", NORTH),
		list("South", SOUTH),
		list("East", EAST),
		list("West", WEST),
	)
	/// List of decal options as list(user-friendly label, icon state base value to return)
	var/decal_list = list(
		list("Warning Line", "warningline"),
		list("Warning Line Corner", "warninglinecorner"),
		list("Caution Label", "caution"),
		list("Directional Arrows", "arrows"),
		list("Stand Clear Label", "stand_clear"),
		list("Bot", "bot"),
		list("Box", "box"),
		list("Box Corner", "box_corners"),
		list("Delivery Marker", "delivery"),
		list("Warning Box", "warn_full"),
	)
	// These decals only have a south sprite.
	var/nondirectional_decals = list(
		"bot",
		"box",
		"delivery",
		"warn_full",
	)

/obj/item/airlock_painter/decal/Initialize(mapload)
	. = ..()
	stored_custom_color = stored_color

/obj/item/airlock_painter/decal/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		to_chat(user, "<span class='notice'>You need to get closer!</span>")
		return

	if(isfloorturf(target) && use_paint(user))
		paint_floor(target)

/**
 * Actually add current decal to the floor.
 *
 * Responsible for actually adding the element to the turf for maximum flexibility.area
 * Can be overriden for different decal behaviors.
 * Arguments:
 * * target - The turf being painted to
*/
/obj/item/airlock_painter/decal/proc/paint_floor(turf/open/floor/target)
	target.AddElement(/datum/element/decal, 'icons/turf/decals.dmi', stored_decal_total, stored_dir, FALSE, color, null, null, alpha)

/**
 * Return the final icon_state for the given decal options
 *
 * Arguments:
 * * decal - the selected decal base icon state
 * * color - the selected color
 * * dir - the selected dir
 */
/obj/item/airlock_painter/decal/proc/get_decal_path(decal, color, dir)
	// Special case due to icon_state names
	if(color == "yellow")
		color = ""

	return "[decal][color ? "_" : ""][color]"

/obj/item/airlock_painter/decal/proc/update_decal_path()
	stored_decal_total = get_decal_path(stored_decal, stored_color, stored_dir)

/obj/item/airlock_painter/decal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DecalPainter", name)
		ui.open()

/obj/item/airlock_painter/decal/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(spritesheet_type)

/obj/item/airlock_painter/decal/ui_static_data(mob/user)
	. = ..()
	var/datum/asset/spritesheet/icon_assets = get_asset_datum(spritesheet_type)

	.["icon_prefix"] = "[icon_assets.name]32x32"
	.["supports_custom_color"] = supports_custom_color
	.["decal_list"] = list()
	.["color_list"] = list()
	.["dir_list"] = list()
	.["nondirectional_decals"] = nondirectional_decals

	for(var/decal in decal_list)
		.["decal_list"] += list(list(
			"name" = decal[1],
			"decal" = decal[2],
		))
	for(var/color in color_list)
		.["color_list"] += list(list(
			"name" = color[1],
			"color" = color[2],
		))
	for(var/dir in dir_list)
		.["dir_list"] += list(list(
			"name" = dir[1],
			"dir" = dir[2],
		))

/obj/item/airlock_painter/decal/ui_data(mob/user)
	. = ..()
	.["current_decal"] = stored_decal
	.["current_color"] = stored_color
	.["current_dir"] = stored_dir
	.["current_custom_color"] = stored_custom_color

/obj/item/airlock_painter/decal/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		//Lists of decals and designs
		if("select decal")
			var/selected_decal = params["decal"]
			var/selected_dir = text2num(params["dir"])
			stored_decal = selected_decal
			stored_dir = selected_dir
		if("select color")
			var/selected_color = params["color"]
			stored_color = selected_color
		if("pick custom color")
			if(supports_custom_color)
				var/chosen_color = tgui_color_picker(usr, "Pick new color", "[src]", COLOR_YELLOW)
				if(!chosen_color || QDELETED(src) || usr.incapacitated() || !usr.is_holding(src))
					return
				stored_custom_color = chosen_color
				stored_color = chosen_color
	update_decal_path()
	. = TRUE

/datum/asset/spritesheet/decals
	name = "floor_decals"
	cross_round_cachable = TRUE

	/// The floor icon used for blend_preview_floor()
	var/preview_floor_icon = 'icons/turf/floors.dmi'
	/// The floor icon state used for blend_preview_floor()
	var/preview_floor_state = "floor"
	/// The associated decal painter type to grab decals, colors, etc from.
	var/painter_type = /obj/item/airlock_painter/decal

/**
 * Underlay an example floor for preview purposes, and return the new icon.
 *
 * Arguments:
 * * decal - the decal to place over the example floor tile
 */
/datum/asset/spritesheet/decals/proc/blend_preview_floor(icon/decal)
	var/icon/final = icon(preview_floor_icon, preview_floor_state)
	final.Blend(decal, ICON_OVERLAY)
	return final

/**
 * Insert a specific state into the spritesheet.
 *
 * Arguments:
 * * decal - the given decal base state.
 * * dir - the given direction.
 * * color - the given color.
 */
/datum/asset/spritesheet/decals/proc/insert_state(decal, dir, color)
	// Special case due to icon_state names
	var/icon_state_color = color == "yellow" ? "" : color

	var/icon/final = blend_preview_floor(icon('icons/turf/decals.dmi', "[decal][icon_state_color ? "_" : ""][icon_state_color]", dir))
	Insert("[decal]_[dir]_[color]", final)

/datum/asset/spritesheet/decals/create_spritesheets()
	// Must actually create because initial(type) doesn't work for /lists for some reason.
	var/obj/item/airlock_painter/decal/painter = new painter_type()

	for(var/list/decal in painter.decal_list)
		for(var/list/dir in painter.dir_list)
			for(var/list/color in painter.color_list)
				insert_state(decal[2], dir[2], color[2])
			if(painter.supports_custom_color)
				insert_state(decal[2], dir[2], "custom")

	qdel(painter)

/obj/item/airlock_painter/decal/debug
	name = "extreme decal painter"
	icon_state = "decal_sprayer_ex"
	initial_ink_type = /obj/item/toner/extreme

/obj/item/airlock_painter/decal/tile
	name = "tile sprayer"
	desc = "An airlock painter, reprogramed to use a different style of paint in order to spray colors on floor tiles as well, in addition to repainting doors. Decals break when the floor tiles are removed. Alt-Click to change design."
	icon_state = "tile_sprayer"
	stored_dir = 2
	stored_color = "#D4D4D432"
	stored_decal = "tile_corner"
	spritesheet_type = /datum/asset/spritesheet/decals/tiles
	supports_custom_color = TRUE
	color_list = list(
		list("Neutral", "#D4D4D432"),
		list("Dark", "#0e0f0f"),
		list("Bar Burgundy", "#791500"),
		list("Sec Red", "#DE3A3A"),
		list("Cargo Brown", "#A46106"),
		list("Engi Yellow", "#EFB341"),
		list("Service Green", "#9FED58"),
		list("Med Blue", "#52B4E9"),
		list("R&D Purple", "#D381C9"),
	)
	decal_list = list(
		list("Corner", "tile_corner"),
		list("Half", "tile_half_contrasted"),
		list("Opposing Corners", "tile_opposing_corners"),
		list("3 Corners", "tile_anticorner_contrasted"),
		list("4 Corners", "tile_fourcorners_contrasted"),
		list("Trimline Corner", "trimline_corner_fill"),
		list("Trimline Fill", "trimline_fill"),
		list("Trimline Fill L", "trimline_fill__8"), // This is a hack that lives in the spritesheet builder and paint_floor
		list("Trimline End", "trimline_end_fill"),
		list("Trimline Box", "trimline_box_fill"),
		list("Carat", "tile_carat"), // :^)
	)
	nondirectional_decals = list(
		"tile_fourcorners_contrasted",
		"trimline_box_fill",
	)

	/// Regex to split alpha out.
	var/stored_alpha = 110
	var/static/regex/rgba_regex = new(@"(#[0-9a-fA-F]{6})([0-9a-fA-F]{2})")

	/// Default alpha for /obj/effect/turf_decal/tile
	var/default_alpha = 110

/obj/item/airlock_painter/decal/tile/paint_floor(turf/open/floor/target)
	// Account for 8-sided decals.
	var/source_decal = stored_decal
	var/source_dir = stored_dir
	if(copytext(stored_decal, -3) == "__8")
		source_decal = splicetext(stored_decal, -3, 0, "")
		source_dir = turn(stored_dir, 45)

	var/decal_color = stored_color
	var/decal_alpha = default_alpha
	// Handle the RGBA case.
	if(rgba_regex.Find(decal_color))
		decal_color = rgba_regex.group[1]
		decal_alpha = text2num(rgba_regex.group[2], 16)

	target.AddElement(/datum/element/decal, 'icons/turf/decals.dmi', source_decal, source_dir, FALSE, decal_color, null, null, decal_alpha)

/datum/asset/spritesheet/decals/tiles
	name = "floor_tile_decals"
	painter_type = /obj/item/airlock_painter/decal/tile

/datum/asset/spritesheet/decals/tiles/insert_state(decal, dir, color)
	// Account for 8-sided decals.
	var/source_decal = decal
	var/source_dir = dir
	if(copytext(decal, -3) == "__8")
		source_decal = splicetext(decal, -3, 0, "")
		source_dir = turn(dir, 45)

	// Handle the RGBA case.
	var/obj/item/airlock_painter/decal/tile/tile_type = painter_type
	var/render_color = color
	var/render_alpha = initial(tile_type.default_alpha)
	if(tile_type.rgba_regex.Find(color))
		render_color = tile_type.rgba_regex.group[1]
		render_alpha = text2num(tile_type.rgba_regex.group[2], 16)

	var/icon/colored_icon = icon('icons/turf/decals.dmi', source_decal, dir=source_dir)
	colored_icon.ChangeOpacity(render_alpha * 0.008)
	if(color == "custom")
		colored_icon.Blend("#0e0f0f", ICON_MULTIPLY)
	else
		colored_icon.Blend(render_color, ICON_MULTIPLY)

	colored_icon = blend_preview_floor(colored_icon)
	Insert("[decal]_[dir]_[replacetext(color, "#", "")]", colored_icon)
