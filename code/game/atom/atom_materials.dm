/**
 * should probably port these:
 * https://github.com/tgstation/tgstation/pull/86901
 * https://github.com/tgstation/tgstation/pull/87498
 */

/atom
	/// The custom materials this atom is made of, used by a lot of things like furniture, walls, and floors (if I finish the functionality, that is.)
	/// The list referenced by this var can be shared by multiple objects and should not be directly modified. Instead, use [set_custom_materials][/atom/proc/set_custom_materials].
	var/list/custom_materials
	/// Bitfield for how the atom handles materials.
	var/material_flags = NONE
	/// Modifier that raises/lowers the effect of the amount of a material, prevents small and easy to get items from being death machines.
	var/material_modifier = 1

///Sets the custom materials for an item.
/atom/proc/set_custom_materials(list/materials, multiplier = 1)

	if(custom_materials) //Only runs if custom materials existed at first. Should usually be the case but check anyways
		for(var/i in custom_materials)
			var/datum/material/custom_material = SSmaterials.GetMaterialRef(i)
			custom_material.on_removed(src, custom_materials[i], material_flags) //Remove the current materials

	if(!length(materials))
		custom_materials = null
		return

	if(material_flags & MATERIAL_EFFECTS)
		for(var/x in materials)
			var/datum/material/custom_material = SSmaterials.GetMaterialRef(x)
			custom_material.on_applied(src, materials[x] * multiplier * material_modifier, material_flags)

	custom_materials = SSmaterials.FindOrCreateMaterialCombo(materials, multiplier)

/**Returns the material composition of the atom.
  *
  * Used when recycling items, specifically to turn alloys back into their component mats.
  *
  * Exists because I'd need to add a way to un-alloy alloys or otherwise deal
  * with people converting the entire stations material supply into alloys.
  *
  * Arguments:
  * - flags: A set of flags determining how exactly the materials are broken down.
  */
/atom/proc/get_material_composition(breakdown_flags=NONE)
	. = list()
	var/list/cached_materials = custom_materials
	for(var/mat in cached_materials)
		var/datum/material/material = SSmaterials.GetMaterialRef(mat)
		var/list/material_comp = material.return_composition(cached_materials[material], breakdown_flags)
		for(var/comp_mat in material_comp)
			.[comp_mat] += material_comp[comp_mat]
