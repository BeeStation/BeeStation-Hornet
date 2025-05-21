/*
	Hey, dingus.
	This is the autowiki for artifact traits!
*/
/datum/autowiki/artifact_traits
	page = "Template:Autowiki/Content/ArtifactTraits"

/datum/autowiki/artifact_traits/generate()
	var/output = ""

	//Go through all the traits and generate wiki entry shit for them
	var/list/standard_traits = typesof(/datum/xenoartifact_trait) - list(/datum/xenoartifact_trait, /datum/xenoartifact_trait/activator, /datum/xenoartifact_trait/minor, /datum/xenoartifact_trait/major, /datum/xenoartifact_trait/malfunction)
	for (var/datum/xenoartifact_trait/trait as anything in sort_list(standard_traits, GLOBAL_PROC_REF(cmp_typepaths_asc)))
		//Instantiate the trait so we can grab stuff from it. We don't have to do this, but I might want to call functions in the future.
		var/datum/xenoartifact_trait/new_trait = new trait()
		if(new_trait.flags & XENOA_HIDE_TRAIT)
			continue
		//Populate icon shit
		var/artifact_icons = ""
			//Bluespace
		if(new_trait.flags & XENOA_BLUESPACE_TRAIT)
			artifact_icons = "[artifact_icons] \[\[File:artifact_bluespace.png\]\]"
			//Plasma
		if(new_trait.flags & XENOA_PLASMA_TRAIT)
			artifact_icons = "[artifact_icons] \[\[File:artifact_plasma.png\]\]"
			//Uranium
		if(new_trait.flags & XENOA_URANIUM_TRAIT)
			artifact_icons = "[artifact_icons] \[\[File:artifact_uranium.png\]\]"
			//Bananium
		if(new_trait.flags & XENOA_BANANIUM_TRAIT)
			artifact_icons = "[artifact_icons] \[\[File:artifact_bananium.png\]\]"
			//Pearl
		//if(new_trait.flags & XENOA_PEARL_TRAIT)
		//	artifact_icons = "[artifact_icons] \[\[File:artifact_pearl.png\]\]"
		//Special name stuff
		var/name_fixed = new_trait.label_name
		name_fixed = replacetext(name_fixed, "Δ", "(delta)")
		name_fixed = replacetext(name_fixed, "Σ", "(sigma)")
		name_fixed = replacetext(name_fixed, "Ω", "(omega)")
		//Special description stuff - I could probably micro optimize this with loops, but I can't be assed
		var/desc_fixed = new_trait.label_desc
		desc_fixed = replacetext(desc_fixed, "Δ", "(delta)")
		desc_fixed = replacetext(desc_fixed, "Σ", "(sigma)")
		desc_fixed = replacetext(desc_fixed, "Ω", "(omega)")
		//Throw our cool info into the wiki template
		output += include_template("Autowiki/ArtifactTraits", list(
			"label_name" = escape_value(format_text(name_fixed)),
			"label_desc"= escape_value(format_text(desc_fixed)),
			"priority" = escape_value(format_text(new_trait.priority)), //Trait type
			"weight" = new_trait.weight,
			"conductivity" = new_trait.conductivity,
			"icons" = escape_value(artifact_icons),
		))
		qdel(new_trait)

	rustg_file_write(output, "data/autowiki_edits.txt")
	return output
