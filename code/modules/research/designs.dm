/***************************************************************
**						Design Datums						  **
**	All the data for building stuff.						  **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a $ to denote that they aren't reagents.
The currently supporting non-reagent materials. All material amounts are set as the define MINERAL_MATERIAL_AMOUNT, which defaults to 2000

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from iron). Only add raw materials.

Design Guidelines
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 2000 units of material. Materials besides iron/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to
*/

//DESIGNS ARE GLOBAL. DO NOT CREATE OR DESTROY THEM AT RUNTIME OUTSIDE OF INIT, JUST REFERENCE THEM TO WHATEVER YOU'RE DOING! //why are you yelling?
//DO NOT REFERENCE OUTSIDE OF SSRESEARCH. USE THE PROCS IN SSRESEARCH TO OBTAIN A REFERENCE.

/datum/design //Datum for object designs, used in construction
	abstract_type = /datum/design

	/// Name of the created object
	var/name = "Name"
	/// Description of the created object
	var/desc = null
	/// The ID of the design. Used for quick reference. Alphanumeric, lower-case, no symbols
	var/id = DESIGN_ID_IGNORE
	/// Bitflags indicating what machines this design is compatable with. See: [code\__DEFINES\machines.dm]
	var/build_type = null
	/// List of materials required to create one unit of the product. Format is: id -> amount
	var/list/materials = list()
	/// The amount of time required to create one unit of the product.
	var/construction_time
	/// The typepath of the object produced by this design
	var/build_path = null
	/// What categories this design falls under. Used for sorting in production machines.
	var/list/category = list()
	//Reagents produced. Format: "id" = amount. Currently only supported by the biogenerator.
	var/list/make_reagents = list()
	/// List of reagents. Format: "id" = amount.
	var/list/reagents_list = list()
	/// How many times faster than normal is this to build on the protolathe
	var/lathe_time_factor = 1
	/// Notify and log for admin investigations if this is printed.
	var/dangerous_construction = FALSE
	/// Bitflags indicating what departmental lathes should be allowed to process this design.
	var/departmental_flags = ALL
	/// What techwebs nodes unlock this design. Constructed by SSresearch
	var/list/datum/techweb_node/unlocked_by = list()
	/// Override for the automatic icon generation used for the research console.
	var/research_icon
	/// Override for the automatic icon state generation used for the research console.
	var/research_icon_state
	/// Appears to be unused.
	var/icon_cache
	/// Optional string that interfaces can use as part of search filters. See- item/borg/upgrade/ai and the Exosuit Fabs.
	var/search_metadata

/datum/design/error_design
	name = "ERROR"
	desc = "This usually means something in the database has corrupted. If this doesn't go away automatically, inform Central Comamnd so their techs can fix this ASAP(tm)"

/datum/design/Destroy()
	SSresearch.techweb_designs -= id
	return ..()

/datum/design/proc/InitializeMaterials()
	var/list/temp_list = list()
	for(var/i in materials) //Go through all of our materials, get the subsystem instance, and then replace the list.
		var/amount = materials[i]
		if(!istext(i)) //Not a category, so get the ref the normal way
			var/datum/material/M = SSmaterials.GetMaterialRef(i)
			temp_list[M] = amount
		else
			temp_list[i] = amount
	materials = temp_list

/datum/design/proc/icon_html(client/user)
	var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/research_designs)
	sheet.send(user)
	return sheet.icon_tag(id)

/// Returns the description of the design
/datum/design/proc/get_description()
	var/obj/object_build_item_path = build_path

	return isnull(desc) ? initial(object_build_item_path.desc) : desc

/**
 * Serializes designs into the shape the shared fabricator browser expects, so any machine backed by `/datum/design` can drive the same UI.
 *
 * Arguments:
 * * designs - `/datum/design` instances, or design ids to look up.
 * * coefficient - multiplier applied to every material cost.
 * * coefficient_override - invoked with a design to get a cost multiplier for
 *   it specifically, for machines whose efficiency does not apply uniformly.
 */
/proc/fabricator_ui_designs(list/designs, coefficient = 1, datum/callback/coefficient_override)
	var/list/output = list()
	var/datum/asset/spritesheet_batched/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet_batched/research_designs)
	var/default_size = "[spritesheet.name]32x32"

	for(var/entry in designs)
		var/datum/design/design = astype(entry, /datum/design) || SSresearch.techweb_design_by_id(entry)
		if(!istype(design))
			continue

		var/design_coefficient = coefficient_override ? coefficient_override.Invoke(design) : coefficient
		var/list/cost = list()
		for(var/material_key in design.materials)
			// A key is either a material datum or, for designs that let the
			// user pick, the name of a material category.
			var/datum/material/material = material_key
			cost[istext(material_key) ? material_key : material.name] = design.materials[material_key] * design_coefficient

		// Reagents are poured in by hand from a container, and no efficiency applies to them.
		var/list/reagent_cost = list()
		for(var/datum/reagent/reagent as anything in design.reagents_list)
			reagent_cost[initial(reagent.name)] = design.reagents_list[reagent]

		var/icon_size = spritesheet.icon_size_id(design.id)
		output[design.id] = list(
			"name" = design.name,
			"desc" = design.get_description(),
			"cost" = cost,
			"reagentCost" = reagent_cost,
			"id" = design.id,
			"categories" = design.category,
			"icon" = "[icon_size == default_size ? "" : "[icon_size] "][design.id]",
			"constructionTime" = design.construction_time,
		)

	return output

/**
 * Nudges a freshly printed item off dead centre, so an order of several does
 * not land as one sprite stacked on itself. Offsets are relative to whatever
 * base the item already defines, so items drawn deliberately off-tile keep
 * their intended position.
 *
 * Arguments
 * * atom/movable/printed - the item that has just landed on the output tile
 */
/proc/scatter_printed_item(atom/movable/printed)
	printed.pixel_x = printed.base_pixel_x + rand(-6, 6)
	printed.pixel_y = printed.base_pixel_y + rand(-6, 6)

/**
 * A mech's tab is only worth showing when the exosuit itself can be printed
 * so equipment that a mech is linked to wont be shown until the chassis is researched
 *
 * Arguments
 * * list/designs - UI design data, modified in place
 */
/proc/hide_unbuildable_chassis(list/designs)
	var/list/printable_chassis = list()
	for(var/design_id, design_data in designs)
		var/list/design_entry = design_data
		for(var/category in design_entry["categories"])
			var/split = findlasttext(category, "/")
			if(split > 1 && copytext(category, split) == RND_SUBCATEGORY_MECHFAB_CHASSIS)
				printable_chassis[copytext(category, 1, split)] = TRUE

	for(var/design_id, design_data in designs)
		var/list/design_entry = design_data
		var/list/categories = design_entry["categories"]
		var/list/kept
		for(var/category in categories)
			// Supported equipment nests its own subcategory underneath, so this
			// matches anywhere in the path rather than only at the end.
			var/split = findtext(category, RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT)
			if(split > 1 && !printable_chassis[copytext(category, 1, split)])
				// Never write back through the original: the serializer hands out the
				// design datum's own category list rather than a copy of it.
				kept ||= categories.Copy()
				kept -= category
		if(kept)
			design_entry["categories"] = kept


////////////////////////////////////////
//Disks for transporting design datums//
////////////////////////////////////////

/obj/item/disk/design_disk
	name = "Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon_state = "datadisk1"
	custom_materials = list(/datum/material/iron = 300, /datum/material/glass = 100)

	/// List of all `/datum/design` stored on the disk.
	var/list/blueprints = list()

/obj/item/disk/design_disk/Initialize(mapload)
	. = ..()
	if(!mapload)
		pixel_x = base_pixel_x + rand(-5, 5)
		pixel_y = base_pixel_y + rand(-5, 5)
