/*
	material datums
*/

/datum/xenoartifact_material
	var/name = "debugium"
	///What color we associate with this material
	var/material_color = "#ff4800"

	///Trait info, how many of each trait are we allowed / start with
	var/trait_activators = 1
	var/trait_minors = 3
	var/trait_majors = 1
	var/trait_malfunctions = 0 //How many malfunctions we start with

	///How many malfunctions can we gain, maximum
	var/max_trait_malfunctions = 1

	///How much we increase artifact instability by for every use
	var/instability_step = 0

	///Custom price we use if the item doesn't have its own
	var/custom_price = 100

	///Artifact textures
	var/texture_icon = 'icons/obj/xenoarchaeology/xenoartifact.dmi'
	var/list/texture_icon_states = list("texture-debug1", "texture-debug2", "texture-debug3")
	///Artifact masks
	var/mask_icon = 'icons/obj/xenoarchaeology/xenoartifact.dmi'
	var/list/mask_icon_states = list("map_editor")

	///What rate do we convert custom price to discovery points to?
	var/dp_rate = 0.1
	///What rate do we convert custom price to research points to?
	var/rnd_rate = 0.5

	///What traits flags are we associated with
	var/trait_flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT

	///What icon we use in the labeler
	var/label_icon = "circle"

	///Parent path - Use this if you're making a material subtype and don't change the traits
	var/material_parent

/datum/xenoartifact_material/proc/get_activators()
	var/datum/xenoa_material_info_holder/traits = SSxenoarchaeology.material_info_list[material_parent || type]
	if(!traits)
		CRASH("Unable to find activator traits, for [material_parent || type]. Cosmic rays have fucked your device!")
	return traits.activators

/datum/xenoartifact_material/proc/get_minors()
	var/datum/xenoa_material_info_holder/traits = SSxenoarchaeology.material_info_list[material_parent || type]
	if(!traits)
		CRASH("Unable to find minor traits, for [material_parent || type]. Cosmic rays have fucked your device!")
	return traits.minors

/datum/xenoartifact_material/proc/get_majors()
	var/datum/xenoa_material_info_holder/traits = SSxenoarchaeology.material_info_list[material_parent || type]
	if(!traits)
		CRASH("Unable to find major traits, for [material_parent || type]. Cosmic rays have fucked your device!")
	return traits.majors

/datum/xenoartifact_material/proc/get_malfunctions()
	var/datum/xenoa_material_info_holder/traits = SSxenoarchaeology.material_info_list[material_parent || type]
	if(!traits)
		CRASH("Unable to find malfunction traits, for [material_parent || type]. Cosmic rays have fucked your device!")
	return traits.malfunctions

/datum/xenoartifact_material/proc/get_texture()
	return icon(texture_icon, pick(texture_icon_states))

/datum/xenoartifact_material/proc/get_mask()
	return mutable_appearance(mask_icon, pick(mask_icon_states))

/datum/xenoartifact_material/bananium
	name = "bananium"
	material_color = "#f2ff00"
	instability_step = 0.5
	texture_icon_states = list("texture-bananium1", "texture-bananium2", "texture-bananium3")
	mask_icon_states = list("mask-bananium1", "mask-bananium2", "mask-bananium3")
	custom_price = 600
	trait_flags = XENOA_BANANIUM_TRAIT
	label_icon = "circle"

/datum/xenoartifact_material/uranium
	name = "uranium"
	material_color = "#88ff00"
	instability_step = 25
	texture_icon_states = list("texture-uranium1", "texture-uranium2", "texture-uranium3")
	mask_icon_states = list("mask-uranium1", "mask-uranium2", "mask-uranium2")
	custom_price = 450
	trait_malfunctions = 1
	max_trait_malfunctions = 2
	trait_flags = XENOA_URANIUM_TRAIT
	label_icon = "certificate"

/datum/xenoartifact_material/plasma
	name = "plasma"
	material_color = "#f200ff"
	instability_step = 5
	texture_icon_states = list("texture-plasma1", "texture-plasma2", "texture-plasma3")
	mask_icon_states = list("mask-plasma1", "mask-plasma2", "mask-plasma3")
	custom_price = 250
	trait_flags = XENOA_PLASMA_TRAIT
	label_icon = "play"

/datum/xenoartifact_material/bluespace
	name = "bluespace"
	material_color = "#006aff"
	instability_step = 1
	texture_icon_states = list("texture-bluespace1", "texture-bluespace2", "texture-bluespace3")
	mask_icon_states = list("mask-bluespace1", "mask-bluespace2", "mask-bluespace3")
	trait_flags = XENOA_BLUESPACE_TRAIT
	label_icon = "star"

//Artificial
/datum/xenoartifact_material/pearl
	name = "pearl"
	material_color = "#f1ffca"
	instability_step = 50
	texture_icon_states = list("texture-pearl1", "texture-pearl2", "texture-pearl3")
	custom_price = 800
	trait_flags = XENOA_PEARL_TRAIT
	label_icon = "question"

/datum/xenoartifact_material/pearl/get_texture()
	var/icon/I = icon(texture_icon, pick(texture_icon_states))
	I.AddAlphaMask(icon('icons/obj/xenoarchaeology/xenoartifact.dmi', "feather"))
	return I

//Calcified
/datum/xenoartifact_material/calcified
	name = "calcified"
	material_color = "#726387"
	texture_icon_states = list("texture-calcified1", "texture-calcified2", "texture-calcified3")
