/*
	Hey, dingus.
	This is the autowiki for artifact traits!
*/
/datum/autowiki/artifact_traits
	page = "Template:Autowiki/Content/ArtifactTraits"

/datum/autowiki/artifact_traits/generate()
	var/output = ""

	//Go through all the traits and generate wiki entry shit for them
	for (var/datum/xenoartifact_trait/trait as anything in sort_list(subtypesof(/datum/xenoartifact_trait), GLOBAL_PROC_REF(cmp_typepaths_asc)))
		//Instantiate the trait so we can grab stuff from it.
		//We don't have to do this, but I might want to call functions in the future.
		var/datum/xenoartifact_trait/new_trait = new trait()
		//Throw our cool info into the wiki template
		//TODO: make a template for artifacts - Racc
		output += include_template("Autowiki/ArtifactTraits", list(
			"label_name" = escape_value(format_text(new_trait.label_name)),
			"label_desc"= escape_value(format_text(new_trait.label_desc)),
			"priority" = escape_value(format_text(new_trait.priority)), //Trait type
			"weight" = escape_value(format_text(new_trait.weight)),
			"conductivity" = escape_value(format_text(new_trait.conductivity)),
		))

	return output
