/*! Material datum

Simple datum which is instanced once per type and is used for every object of said material. It has a variety of variables that define behavior. Subtyping from this makes it easier to create your own materials.

*/


/datum/material
	var/name = "material"
	var/desc = "its..stuff."
	///Base color of the material, is used for greyscale. Item isn't changed in color if this is null.
	///Deprecated, use greyscale_color instead.
	var/color
	///Determines the color palette of the material. Formatted the same as atom/var/greyscale_colors
	var/greyscale_colors
	///Base alpha of the material, is used for greyscale icons.
	var/alpha
	///Materials "Traits". its a map of key = category | Value = Bool. Used to define what it can be used for
	var/list/categories = list()
	///The type of sheet this material creates. This should be replaced as soon as possible by greyscale sheets
	var/obj/item/stack/sheet_type
	///This is a modifier for force, and resembles the strength of the material
	var/strength_modifier = 1
	///This is a modifier for integrity, and resembles the strength of the material
	var/integrity_modifier = 1
	///This is the amount of value per 1 unit of the material
	var/value_per_unit = 0
	/*
	///Armor modifiers, multiplies an items normal armor vars by these amounts.
	var/armor_modifiers = list("melee" = 1, "bullet" = 1, "laser" = 1, "energy" = 1, "bomb" = 1, "bio" = 1, "rad" = 1, "fire" = 1, "acid" = 1)
	///How beautiful is this material per unit
	var/beauty_modifier = 0
	*/
	///Can be used to override the sound items make, lets add some SLOSHing.
	var/item_sound_override
	///Can be used to override the stepsound a turf makes. MORE SLOOOSH
	var/turf_sound_override
	///what texture icon state to overlay
	var/texture_layer_icon_state
	///a cached icon for the texture filter
	var/cached_texture_filter_icon

/datum/material/New()
	. = ..()
	if(texture_layer_icon_state)
		cached_texture_filter_icon = icon('icons/materials/composite.dmi', texture_layer_icon_state)



///This proc is called when the material is added to an object.
/datum/material/proc/on_applied(atom/source, amount, material_flags)
	if(material_flags & MATERIAL_COLOR) //Prevent changing things with pre-set colors, to keep colored toolboxes their looks for example
		if(color) //Do we have a custom color?
			source.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
		if(alpha)
			source.alpha = alpha
		if(texture_layer_icon_state)
			ADD_KEEP_TOGETHER(source, MATERIAL_SOURCE(src))
			source.add_filter("material_texture_[name]",1,layering_filter(icon=cached_texture_filter_icon,blend_mode=BLEND_INSET_OVERLAY))

	if(material_flags & MATERIAL_GREYSCALE)
		var/config_path = get_greyscale_config_for(source.greyscale_config)
		source.set_greyscale(greyscale_colors, config_path)

	if(alpha < 255)
		source.opacity = FALSE
	if(material_flags & MATERIAL_ADD_PREFIX)
		source.name = "[name] [source.name]"

	//if(beauty_modifier)
	//	source.AddElement(/datum/element/beauty, beauty_modifier * amount)

	if(istype(source, /obj)) //objs
		on_applied_obj(source, amount, material_flags)

	if(istype(source, /turf)) //turfs
		on_applied_turf(source, amount, material_flags)

	source.mat_update_desc(src)

///This proc is called when a material updates an object's description
/atom/proc/mat_update_desc(/datum/material/mat)
	return

///This proc is called when the material is added to an object specifically.
/datum/material/proc/on_applied_obj(obj/o, amount, material_flags)
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/new_max_integrity = CEILING(o.max_integrity * integrity_modifier, 1)
		o.modify_max_integrity(new_max_integrity)
		o.force *= strength_modifier
		o.throwforce *= strength_modifier

		/*
		var/list/temp_armor_list = list() //Time to add armor modifiers!

		if(!istype(o.armor))
			return

		var/list/current_armor = o.armor?.getList()

		for(var/i in current_armor)
			temp_armor_list[i] = current_armor[i] * armor_modifiers[i]
		o.armor = getArmor(arglist(temp_armor_list))
		*/

	if(!isitem(o))
		return
	var/obj/item/item = o

	if(material_flags & MATERIAL_GREYSCALE)
		var/worn_path = get_greyscale_config_for(item.greyscale_config_worn)
		var/lefthand_path = get_greyscale_config_for(item.greyscale_config_inhand_left)
		var/righthand_path = get_greyscale_config_for(item.greyscale_config_inhand_right)
		item.set_greyscale(
			new_worn_config = worn_path,
			new_inhand_left = lefthand_path,
			new_inhand_right = righthand_path
		)

	if(!item_sound_override)
		return
	item.hitsound = item_sound_override
	item.usesound = item_sound_override
	item.mob_throw_hit_sound = item_sound_override
	item.equip_sound = item_sound_override
	item.pickup_sound = item_sound_override
	item.drop_sound = item_sound_override

/datum/material/proc/on_applied_turf(var/turf/T, amount, material_flags)
	if(isopenturf(T))
		if(!turf_sound_override)
			return
		var/turf/open/O = T
		O.footstep = turf_sound_override
		O.barefootstep = turf_sound_override
		O.clawfootstep = turf_sound_override
		O.heavyfootstep = turf_sound_override
	if(alpha < 255) //We can see through you, so we want to see stuff happening below you. Either space, or multi-z
		T.enable_zmimic()
		if(isspaceturf(T.baseturfs[1]))
			T.fullbright_type = FULLBRIGHT_STARLIGHT
			T.luminosity = 2

	return

/datum/material/proc/get_greyscale_config_for(datum/greyscale_config/config_path)
	if(!config_path)
		return
	for(var/datum/greyscale_config/path as anything in subtypesof(config_path))
		if(type != initial(path.material_skin))
			continue
		return path

///This proc is called when the material is removed from an object.
/datum/material/proc/on_removed(atom/source, material_flags)
	if(material_flags & MATERIAL_COLOR) //Prevent changing things with pre-set colors, to keep colored toolboxes their looks for example
		if(color)
			source.remove_atom_colour(FIXED_COLOUR_PRIORITY, color)
		if(texture_layer_icon_state)
			source.remove_filter("material_texture_[name]")
			REMOVE_KEEP_TOGETHER(source, MATERIAL_SOURCE(src))
		source.alpha = initial(source.alpha)

	if(material_flags & MATERIAL_GREYSCALE)
		source.set_greyscale(initial(source.greyscale_colors), initial(source.greyscale_config))

	if(material_flags & MATERIAL_ADD_PREFIX)
		source.name = initial(source.name)

	if(istype(source, /obj)) //objs
		on_removed_obj(source, material_flags)

	if(istype(source, /turf)) //turfs
		on_removed_turf(source, material_flags)

///This proc is called when the material is removed from an object specifically.
/datum/material/proc/on_removed_obj(obj/o, material_flags)
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/new_max_integrity = initial(o.max_integrity)
		o.modify_max_integrity(new_max_integrity)
		o.force = initial(o.force)
		o.throwforce = initial(o.throwforce)

	if(isitem(o) && (material_flags & MATERIAL_GREYSCALE))
		var/obj/item/item = o
		item.set_greyscale(
			new_worn_config = initial(item.greyscale_config_worn),
			new_inhand_left = initial(item.greyscale_config_inhand_left),
			new_inhand_right = initial(item.greyscale_config_inhand_right)
		)

/datum/material/proc/on_removed_turf(turf/T, material_flags)
	if(alpha < 255)
		T.disable_zmimic()
		if(ispath(READ_BASETURF(T), /turf/open/space))
			T.fullbright_type = FULLBRIGHT_DEFAULT
			T.luminosity = 1

/**
 * This proc is called when the mat is found in an item that's consumed by accident. see /obj/item/proc/on_accidental_consumption.
 * Arguments
 * * M - person consuming the mat
 * * S - (optional) item the mat is contained in (NOT the item with the mat itself)
 */
/datum/material/proc/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	return FALSE

/// Returns GLOB.recipes of a material to modify the recipes.
/// This will be only called once from SSMaterials.
/datum/material/proc/get_material_recipes()
	if(!initial(sheet_type.material_type) || !categories[MAT_CATEGORY_BASE_RECIPES])
		return
	var/obj/item/stack/dummy_stack = new sheet_type(null) // we make a fake object here
	if(!dummy_stack)
		return
	. = dummy_stack.get_recipes() // because we need to get the global list.
	// NOTE: returning a GLOB.recipes from each subtype can be a way, but that should override all procs. This is simple.
	qdel(dummy_stack)
