/datum/autowiki/modsuits
	page = "Template:Autowiki/Content/Modsuits"

/datum/autowiki/modsuits/generate()
	var/output = "= Station MODsuit Themes =\n"

	for(var/theme_path in sort_list(subtypesof(/datum/mod_theme), GLOBAL_PROC_REF(cmp_typepaths_asc)))
		var/datum/mod_theme/theme = new theme_path()

		// Skip themes that shouldn't be shown
		if(!should_include_theme(theme))
			qdel(theme)
			continue

		var/filename = SANITIZE_FILENAME(escape_value(format_text(theme.name)))

		// Create armor datum to get actual values
		var/datum/armor/armor_data = new theme.armor_type()

		output += include_template("Autowiki/ModsuitTheme", list(
			"name" = escape_value(theme.name),
			"description" = escape_value(theme.desc),
			"icon" = escape_value(filename),
			"melee" = armor_data.get_rating(MELEE),
			"bullet" = armor_data.get_rating(BULLET),
			"laser" = armor_data.get_rating(LASER),
			"energy" = armor_data.get_rating(ENERGY),
			"bomb" = armor_data.get_rating(BOMB),
			"bio" = armor_data.get_rating(BIO),
			"fire" = armor_data.get_rating(FIRE),
			"acid" = armor_data.get_rating(ACID),
			"bleed" = armor_data.get_rating(BLEED),
			"charge_drain" = theme.charge_drain || 5, // Default fallback
			"complexity_max" = theme.complexity_max || 15, // Default fallback
			"slowdown_deployed" = theme.slowdown_deployed || 0.5, // Default fallback
			"background_color" = get_theme_background_color(theme.name),
			"variants" = generate_variants(theme),
			"inbuilt_modules" = generate_inbuilt_modules(theme)
		))

		// Upload the main theme icon
		var/obj/item/mod/control/temp_suit = new()
		temp_suit.theme = theme
		temp_suit.skin = theme.default_skin
		upload_icon(getFlatIcon(temp_suit, no_anim = TRUE), filename)

		// Upload variant icons if they exist
		upload_variant_icons(theme)

		qdel(temp_suit)
		qdel(armor_data)
		qdel(theme)

	return output

/datum/autowiki/modsuits/proc/should_include_theme(datum/mod_theme/theme)
	// Skip debug, admin, or other special themes
	if(findtext(theme.name, "debug") || findtext(theme.name, "admin"))
		return FALSE
	return TRUE

/datum/autowiki/modsuits/proc/get_theme_background_color(theme_name)
	// Match the background colors from the original page
	switch(theme_name)
		if("engineering", "atmospheric", "advanced")
			return "#FFF7E6"
		if("medical", "rescue")
			return "#E6F7FF"
		if("security", "safeguard")
			return "#FFE6E6"
		if("research")
			return "#F0E6FF"
		else
			return "#F2F2F2"

/datum/autowiki/modsuits/proc/generate_variants(datum/mod_theme/theme)
	var/output = ""

	// Check if theme has variants property, if not return empty
	if(!theme.variants || !length(theme.variants))
		return output

	for(var/skin_name in theme.variants)
		if(skin_name == theme.default_skin)
			continue // Skip the default skin

		var/filename = SANITIZE_FILENAME("[theme.name]_[skin_name]")
		output += include_template("Autowiki/ModsuitVariant", list(
			"name" = capitalize(skin_name),
			"icon" = escape_value(filename)
		))

	return output

/datum/autowiki/modsuits/proc/generate_inbuilt_modules(datum/mod_theme/theme)
	var/output = ""

	// Check if theme has inbuilt_modules property, if not return empty
	if(!theme.inbuilt_modules || !length(theme.inbuilt_modules))
		return output

	for(var/module_path in theme.inbuilt_modules)
		var/obj/item/mod/module/module = new module_path()
		output += include_template("Autowiki/ModsuitModule", list(
			"name" = escape_value(module.name)
		))
		qdel(module)

	return output

/datum/autowiki/modsuits/proc/upload_variant_icons(datum/mod_theme/theme)
	if(!theme.variants || !length(theme.variants))
		return

	for(var/skin_name in theme.variants)
		if(skin_name == theme.default_skin)
			continue

		var/obj/item/mod/control/temp_suit = new()
		temp_suit.theme = theme
		temp_suit.skin = skin_name

		var/filename = SANITIZE_FILENAME("[theme.name]_[skin_name]")
		upload_icon(getFlatIcon(temp_suit, no_anim = TRUE), filename)

		qdel(temp_suit)
