//DEFINITIONS FOR ASSET DATUMS START HERE.

/datum/asset/simple/tgui
	keep_local_name = TRUE
	assets = list(
		"tgui.bundle.js" = file("tgui/public/tgui.bundle.js"),
		"tgui.bundle.css" = file("tgui/public/tgui.bundle.css"),
	)

/datum/asset/simple/tgui_panel
	keep_local_name = TRUE
	assets = list(
		"tgui-panel.bundle.js" = file("tgui/public/tgui-panel.bundle.js"),
		"tgui-panel.bundle.css" = file("tgui/public/tgui-panel.bundle.css"),
	)

//For development purposes only
/datum/asset/simple/tgui_say
	keep_local_name = TRUE
	assets = list(
		"tgui-say.bundle.js" = file("tgui/public/tgui-say.bundle.js"),
		"tgui-say.bundle.css" = file("tgui/public/tgui-say.bundle.css"),
	)

/datum/asset/simple/headers
	assets = list(
		"alarm_green.gif" = 'icons/program_icons/alarm_green.gif',
		"alarm_red.gif" = 'icons/program_icons/alarm_red.gif',
		"batt_5.gif" = 'icons/program_icons/batt_5.gif',
		"batt_20.gif" = 'icons/program_icons/batt_20.gif',
		"batt_40.gif" = 'icons/program_icons/batt_40.gif',
		"batt_60.gif" = 'icons/program_icons/batt_60.gif',
		"batt_80.gif" = 'icons/program_icons/batt_80.gif',
		"batt_100.gif" = 'icons/program_icons/batt_100.gif',
		"charging.gif" = 'icons/program_icons/charging.gif',
		"downloader_finished.gif" = 'icons/program_icons/downloader_finished.gif',
		"downloader_running.gif" = 'icons/program_icons/downloader_running.gif',
		"ntnrc_idle.gif" = 'icons/program_icons/ntnrc_idle.gif',
		"ntnrc_new.gif" = 'icons/program_icons/ntnrc_new.gif',
		"power_norm.gif" = 'icons/program_icons/power_norm.gif',
		"power_warn.gif" = 'icons/program_icons/power_warn.gif',
		"sig_high.gif" = 'icons/program_icons/sig_high.gif',
		"sig_low.gif" = 'icons/program_icons/sig_low.gif',
		"sig_lan.gif" = 'icons/program_icons/sig_lan.gif',
		"sig_none.gif" = 'icons/program_icons/sig_none.gif',
		"smmon_0.gif" = 'icons/program_icons/smmon_0.gif',
		"smmon_1.gif" = 'icons/program_icons/smmon_1.gif',
		"smmon_2.gif" = 'icons/program_icons/smmon_2.gif',
		"smmon_3.gif" = 'icons/program_icons/smmon_3.gif',
		"smmon_4.gif" = 'icons/program_icons/smmon_4.gif',
		"smmon_5.gif" = 'icons/program_icons/smmon_5.gif',
		"smmon_6.gif" = 'icons/program_icons/smmon_6.gif',
		"borg_self_monitor.gif" = 'icons/program_icons/borg_self_monitor.gif'
	)

/datum/asset/simple/circuit_assets
	assets = list(
		"grid_background.png" = 'icons/ui_icons/tgui/grid_background.png'
	)

/datum/asset/simple/radar_assets
	assets = list(
		"ntosradarbackground.png"	= 'icons/ui_icons/tgui/ntosradar_background.png',
		"ntosradarpointer.png"		= 'icons/ui_icons/tgui/ntosradar_pointer.png',
		"ntosradarpointerS.png"		= 'icons/ui_icons/tgui/ntosradar_pointer_S.png'
	)

/datum/asset/spritesheet/simple/pda
	name = "pda"
	assets = list(
		"atmos" = 'icons/pda_icons/pda_atmos.png',
		"back" = 'icons/pda_icons/pda_back.png',
		"bell" = 'icons/pda_icons/pda_bell.png',
		"blank" = 'icons/pda_icons/pda_blank.png',
		"boom" = 'icons/pda_icons/pda_boom.png',
		"bucket" = 'icons/pda_icons/pda_bucket.png',
		"medbot" = 'icons/pda_icons/pda_medbot.png',
		"floorbot" = 'icons/pda_icons/pda_floorbot.png',
		"cleanbot" = 'icons/pda_icons/pda_cleanbot.png',
		"crate" = 'icons/pda_icons/pda_crate.png',
		"cuffs" = 'icons/pda_icons/pda_cuffs.png',
		"eject" = 'icons/pda_icons/pda_eject.png',
		"flashlight" = 'icons/pda_icons/pda_flashlight.png',
		"honk" = 'icons/pda_icons/pda_honk.png',
		"mail" = 'icons/pda_icons/pda_mail.png',
		"medical" = 'icons/pda_icons/pda_medical.png',
		"menu" = 'icons/pda_icons/pda_menu.png',
		"mule" = 'icons/pda_icons/pda_mule.png',
		"notes" = 'icons/pda_icons/pda_notes.png',
		"power" = 'icons/pda_icons/pda_power.png',
		"rdoor" = 'icons/pda_icons/pda_rdoor.png',
		"reagent" = 'icons/pda_icons/pda_reagent.png',
		"refresh" = 'icons/pda_icons/pda_refresh.png',
		"scanner" = 'icons/pda_icons/pda_scanner.png',
		"signaler"		= 'icons/pda_icons/pda_signaler.png',
		"status"		= 'icons/pda_icons/pda_status.png',
		"dronephone"	= 'icons/pda_icons/pda_dronephone.png',
		"emoji"			= 'icons/pda_icons/pda_emoji.png'
	)

/datum/asset/spritesheet/simple/paper
	name = "paper"
	assets = list(
		"stamp-clown" = 'icons/stamp_icons/large_stamp-clown.png',
		"stamp-deny" = 'icons/stamp_icons/large_stamp-deny.png',
		"stamp-ok" = 'icons/stamp_icons/large_stamp-ok.png',
		"stamp-void" = 'icons/stamp_icons/large_stamp-void.png',
		"stamp-hop" = 'icons/stamp_icons/large_stamp-hop.png',
		"stamp-cmo" = 'icons/stamp_icons/large_stamp-cmo.png',
		"stamp-ce" = 'icons/stamp_icons/large_stamp-ce.png',
		"stamp-hos" = 'icons/stamp_icons/large_stamp-hos.png',
		"stamp-rd" = 'icons/stamp_icons/large_stamp-rd.png',
		"stamp-cap" = 'icons/stamp_icons/large_stamp-cap.png',
		"stamp-qm" = 'icons/stamp_icons/large_stamp-qm.png',
		"stamp-law" = 'icons/stamp_icons/large_stamp-law.png',
		"stamp-chap" = 'icons/stamp_icons/large_stamp-chap.png',
		"stamp-mime" = 'icons/stamp_icons/large_stamp-mime.png',
		"stamp-cent" = 'icons/stamp_icons/large_stamp-cent.png',
		"stamp-syndicate" = 'icons/stamp_icons/large_stamp-syndicate.png',
	)


/datum/asset/simple/irv
	assets = list(
		"jquery-ui.custom-core-widgit-mouse-sortable-min.js" = 'html/IRV/jquery-ui.custom-core-widgit-mouse-sortable-min.js',
	)

/datum/asset/group/irv
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/irv
	)

/datum/asset/simple/fuckywucky
	assets = list(
		"fuckywucky.png" = 'html/fuckywucky.png'
	)

/datum/asset/simple/namespaced/changelog
	assets = list(
		"88x31.png" = 'html/88x31.png',
		"bug-minus.png" = 'html/bug-minus.png',
		"cross-circle.png" = 'html/cross-circle.png',
		"hard-hat-exclamation.png" = 'html/hard-hat-exclamation.png',
		"image-minus.png" = 'html/image-minus.png',
		"image-plus.png" = 'html/image-plus.png',
		"music-minus.png" = 'html/music-minus.png',
		"music-plus.png" = 'html/music-plus.png',
		"tick-circle.png" = 'html/tick-circle.png',
		"wrench-screwdriver.png" = 'html/wrench-screwdriver.png',
		"spell-check.png" = 'html/spell-check.png',
		"burn-exclamation.png" = 'html/burn-exclamation.png',
		"chevron.png" = 'html/chevron.png',
		"chevron-expand.png" = 'html/chevron-expand.png',
		"scales.png" = 'html/scales.png',
		"coding.png" = 'html/coding.png',
		"ban.png" = 'html/ban.png',
		"chrome-wrench.png" = 'html/chrome-wrench.png',
		"changelog.css" = 'html/changelog.css'
	)
	parents = list("changelog.html" = 'html/changelog.html')


/datum/asset/simple/jquery
	legacy = TRUE
	assets = list(
		"jquery.min.js" = 'html/jquery.min.js',
	)

/datum/asset/simple/namespaced/fontawesome
	legacy = TRUE
	assets = list(
		"fa-regular-400.ttf" = 'html/font-awesome/webfonts/fa-regular-400.ttf',
		"fa-solid-900.ttf" = 'html/font-awesome/webfonts/fa-solid-900.ttf',
		"fa-v4compatibility.ttf" = 'html/font-awesome/webfonts/fa-v4compatibility.ttf',
		"v4shim.css" = 'html/font-awesome/css/v4-shims.min.css',
	)
	parents = list("font-awesome.css" = 'html/font-awesome/css/all.min.css')

/datum/asset/simple/namespaced/tgfont
	assets = list(
		"tgfont.eot" = file("tgui/packages/tgfont/dist/tgfont.eot"),
		"tgfont.woff2" = file("tgui/packages/tgfont/dist/tgfont.woff2"),
	)
	parents = list(
		"tgfont.css" = file("tgui/packages/tgfont/dist/tgfont.css"),
	)

/datum/asset/spritesheet_batched/emoji
	name = "emoji"

/datum/asset/spritesheet_batched/emoji/create_spritesheets()
	for (var/icon_state_name in icon_states('icons/emoji.dmi'))
		var/datum/universal_icon/u_icon = uni_icon('icons/emoji.dmi', icon_state_name, SOUTH)
		u_icon.scale(48, 48)
		insert_icon("[icon_state_name]", u_icon)

/datum/asset/simple/lobby
	assets = list(
		"playeroptions.css" = 'html/browser/playeroptions.css'
	)

/datum/asset/simple/namespaced/common
	assets = list("padlock.png"	= 'html/padlock.png')
	parents = list("common.css" = 'html/browser/common.css')

/datum/asset/simple/permissions
	assets = list(
		"search.js" = 'html/admin/search.js',
		"panels.css" = 'html/admin/panels.css'
	)

/datum/asset/group/permissions
	children = list(
		/datum/asset/simple/permissions,
		/datum/asset/simple/namespaced/common
	)

/datum/asset/simple/notes
	assets = list(
		"high_button.png" = 'html/high_button.png',
		"medium_button.png" = 'html/medium_button.png',
		"minor_button.png" = 'html/minor_button.png',
		"none_button.png" = 'html/none_button.png',
	)

/datum/asset/simple/arcade
	assets = list(
		"boss1.gif" = 'icons/ui_icons/Arcade/boss1.gif',
		"boss2.gif" = 'icons/ui_icons/Arcade/boss2.gif',
		"boss3.gif" = 'icons/ui_icons/Arcade/boss3.gif',
		"boss4.gif" = 'icons/ui_icons/Arcade/boss4.gif',
		"boss5.gif" = 'icons/ui_icons/Arcade/boss5.gif',
		"boss6.gif" = 'icons/ui_icons/Arcade/boss6.gif',
		)

/datum/asset/spritesheet/simple/achievements
	name ="achievements"
	assets = list(
		"default" = 'icons/ui_icons/Achievements/default.png'
	)

/datum/asset/spritesheet/simple/condiments
	name = "condiments"
	assets = list(
		CONDIMASTER_STYLE_FALLBACK = 'icons/ui_icons/condiments/bottle.png',
		"flour" = 'icons/ui_icons/condiments/flour.png',
		"rice" = 'icons/ui_icons/condiments/rice.png',
		"sugar" = 'icons/ui_icons/condiments/sugar.png',
		"milk" = 'icons/ui_icons/condiments/milk.png',
		"enzyme" = 'icons/ui_icons/condiments/enzyme.png',
		"capsaicin" = 'icons/ui_icons/condiments/hotsauce.png',
		"frostoil" = 'icons/ui_icons/condiments/coldsauce.png',
		"bbqsauce" = 'icons/ui_icons/condiments/bbqsauce.png',
		"soymilk" = 'icons/ui_icons/condiments/soymilk.png',
		"soysauce" = 'icons/ui_icons/condiments/soysauce.png',
		"ketchup" = 'icons/ui_icons/condiments/ketchup.png',
		"mayonnaise" = 'icons/ui_icons/condiments/mayonnaise.png',
		"oliveoil" = 'icons/ui_icons/condiments/oliveoil.png',
		"cooking_oil" = 'icons/ui_icons/condiments/cookingoil.png',
		"peanut_butter" = 'icons/ui_icons/condiments/peanutbutter.png',
		"cherryjelly" = 'icons/ui_icons/condiments/cherryjelly.png',
		"honey" = 'icons/ui_icons/condiments/honey.png',
		"blackpepper" = 'icons/ui_icons/condiments/peppermillsmall.png',
		"sodiumchloride" = 'icons/ui_icons/condiments/saltshakersmall.png',
	)

/datum/asset/spritesheet_batched/medicine_containers
	name ="medicine_containers"

/datum/asset/spritesheet_batched/medicine_containers/create_spritesheets()
	var/dmi_file = 'icons/obj/medicine_containers.dmi'
	for(var/each_pill_shape in PILL_SHAPE_LIST_WITH_DUMMY)
		var/datum/universal_icon/target_icon = uni_icon(dmi_file, each_pill_shape)
		if(!target_icon)
			continue
		target_icon.crop(11,10, 21,20)
		target_icon.scale(22, 22)
		insert_icon(each_pill_shape, target_icon)
	for(var/each_patch_shape in PATCH_SHAPE_LIST)
		var/datum/universal_icon/target_icon = uni_icon(dmi_file, each_patch_shape)
		if(!target_icon)
			continue
		target_icon.crop(11,12, 21,22)
		target_icon.scale(22, 22)
		insert_icon(each_patch_shape, target_icon)

//this exists purely to avoid meta by pre-loading all language icons.
/datum/asset/language/register()
	for(var/path in subtypesof(/datum/language))
		set waitfor = FALSE
		var/datum/language/L = new path ()
		L.get_icon()

/datum/asset/spritesheet_batched/pipes
	name = "pipes"
	ignore_dir_errors = TRUE

/datum/asset/spritesheet_batched/pipes/create_spritesheets()
	for (var/each in list('icons/obj/atmospherics/pipes/pipe_item.dmi', 'icons/obj/atmospherics/pipes/disposal.dmi', 'icons/obj/atmospherics/pipes/transit_tube.dmi', 'icons/obj/plumbing/fluid_ducts.dmi'))
		insert_all_icons("", each, GLOB.alldirs)

/datum/asset/simple/genetics
	assets = list(
		"dna_discovered.gif" = 'html/dna_discovered.gif',
		"dna_undiscovered.gif" = 'html/dna_undiscovered.gif',
		"dna_extra.gif" = 'html/dna_extra.gif'
	)

/datum/asset/spritesheet_batched/supplypods
	name = "supplypods"

/datum/asset/spritesheet_batched/supplypods/create_spritesheets()
	for (var/style in 1 to length(GLOB.podstyles))
		var/icon_file = 'icons/obj/supplypods.dmi'
		var/states = icon_states(icon_file)
		if (style == STYLE_SEETHROUGH)
			insert_icon("pod_asset[style]", uni_icon(icon_file, "seethrough-icon", SOUTH))
			continue
		var/base = GLOB.podstyles[style][POD_BASE]
		if (!base)
			insert_icon("pod_asset[style]", uni_icon(icon_file, "invisible-icon", SOUTH))
			continue
		var/datum/universal_icon/pod_icon = uni_icon(icon_file, base, SOUTH)

		var/door = GLOB.podstyles[style][POD_DOOR]
		if (door && ("[base]_door" in states))
			pod_icon.blend_icon(uni_icon(icon_file, "[base]_door", SOUTH), ICON_OVERLAY)

		var/shape = GLOB.podstyles[style][POD_SHAPE]
		if (shape != POD_SHAPE_NORML)
			insert_icon("pod_asset[style]", pod_icon)
			continue
		var/decal = GLOB.podstyles[style][POD_DECAL]
		if (decal && (decal in states))
			pod_icon.blend_icon(uni_icon(icon_file, decal, SOUTH), ICON_OVERLAY)

		var/glow = GLOB.podstyles[style][POD_GLOW]
		if (glow && ("pod_glow_[glow]" in states))
			pod_icon.blend_icon(uni_icon(icon_file, "pod_glow_[glow]", SOUTH), ICON_OVERLAY)

		insert_icon("pod_asset[style]", pod_icon)


// Representative icons for each research design
/datum/asset/spritesheet_batched/research_designs
	name = "design"

/datum/asset/spritesheet_batched/research_designs/create_spritesheets()
	for (var/datum/design/D as() in subtypesof(/datum/design))
		var/icon_file
		var/icon_state
		var/datum/icon_transformer/transform = null

		if(initial(D.research_icon) && initial(D.research_icon_state)) //If the design has an icon replacement skip the rest
			icon_file = initial(D.research_icon)
			icon_state = initial(D.research_icon_state)
		else
			// construct the icon and slap it into the resource cache
			var/atom/item = initial(D.build_path)
			if (!ispath(item, /atom))
				// biogenerator outputs to beakers by default
				if (initial(D.build_type) & BIOGENERATOR)
					item = /obj/item/reagent_containers/cup/beaker/large
				else
					continue  // shouldn't happen, but just in case
					// hint^ it does fucking happen. this was giving me so much trouble

			// circuit boards become their resulting machines or computers
			if (ispath(item, /obj/item/circuitboard))
				var/obj/item/circuitboard/C = item
				var/machine = initial(C.build_path)
				if (machine)
					item = machine

			if (initial(item.greyscale_config) && initial(item.greyscale_colors))
				insert_icon(initial(D.id), gags_to_universal_icon(item))
				continue
			if(ispath(item, /obj/item/bodypart)) // mmm snowflake limbcode as usual
				var/obj/item/bodypart/body_part = item
				icon_file = initial(body_part.static_icon)
			else
				icon_file = initial(item.icon)

			icon_state = initial(item.icon_state)

			if(initial(item.color))
				transform = color_transform(initial(item.color))

			// computers (and snowflakes) get their screen and keyboard sprites
			if (ispath(item, /obj/machinery/computer) || ispath(item, /obj/machinery/power/solar_control))
				if(!transform)
					transform = new()
				var/obj/machinery/computer/C = item
				var/all_states = icon_states(icon_file)
				var/screen = initial(C.icon_screen)
				var/keyboard = initial(C.icon_keyboard)
				if (screen && (screen in all_states))
					transform.blend_icon(uni_icon(icon_file, screen), ICON_OVERLAY)
				if (keyboard && (keyboard in all_states))
					transform.blend_icon(uni_icon(icon_file, keyboard), ICON_OVERLAY)
		insert_icon(initial(D.id), uni_icon(icon_file, icon_state, transform=transform))

/datum/asset/spritesheet_batched/vending
	name = "vending"

/datum/asset/spritesheet_batched/vending/create_spritesheets()
	// initialising the list of items we need
	var/target_items = list()
	var/prize_dummy = list()
	for(var/obj/machinery/vendor/V as() in subtypesof(/obj/machinery/vendor))
		V = new V()
		prize_dummy |= V.prize_list // prize_list is added by Init()
		qdel(V)
	for(var/datum/data/vendor_equipment/V as() in prize_dummy)
		target_items |= V.equipment_path
	for(var/obj/machinery/vending/V as() in subtypesof(/obj/machinery/vending))
		V = new V() // It seems `initial(list var)` has nothing. need to make a type.
		for(var/O in list(V.products, V.premium, V.contraband))
			target_items |= O
		qdel(V)
	for(var/atom/item as() in target_items)
		if (!ispath(item, /atom))
			return FALSE

		var/overlay = initial(item.icon_state)
		var/icon_init = initial(item.icon)
		var/list/icon_states_available = icon_states(icon_init)
		if(!(overlay in icon_states_available))
			var/icon_file = "[icon_init]" || "Unknown Generated Icon"
			stack_trace("Invalid overlay: Icon object '[icon_file]' [REF(src)] used in '[src]' [type] is missing icon state [overlay].")
			continue

		var/imgid = replacetext(replacetext("[item]", "/obj/item/", ""), "/", "-")
		insert_icon(imgid, get_display_icon_for(item))

// basically admin debugging tool assets
/datum/asset/spritesheet_batched/tools
	name = "tools"

/datum/asset/spritesheet_batched/tools/create_spritesheets()
	var/list/cache_targets = list(
		TOOL_CROWBAR = uni_icon('icons/obj/tools.dmi', "crowbar"),
		TOOL_MULTITOOL = uni_icon('icons/obj/device.dmi', "multitool"),
		TOOL_SCREWDRIVER = uni_icon('icons/obj/tools.dmi', "screwdriver_map"),
		TOOL_WIRECUTTER = uni_icon('icons/obj/tools.dmi', "cutters_map"),
		TOOL_WRENCH = uni_icon('icons/obj/tools.dmi', "wrench"),
		TOOL_WELDER = uni_icon('icons/obj/tools.dmi', "welder"),
		TOOL_ANALYZER = uni_icon('icons/obj/device.dmi', "analyzer"),
		"wires" = uni_icon('icons/obj/power.dmi', "coil"),

		TOOL_RETRACTOR = uni_icon('icons/obj/surgery.dmi', "retractor"),
		TOOL_HEMOSTAT = uni_icon('icons/obj/surgery.dmi', "hemostat"),
		TOOL_CAUTERY = uni_icon('icons/obj/surgery.dmi', "cautery"),
		TOOL_DRILL = uni_icon('icons/obj/surgery.dmi', "drill"),
		TOOL_SCALPEL = uni_icon('icons/obj/surgery.dmi', "scalpel"),
		TOOL_SAW = uni_icon('icons/obj/surgery.dmi', "saw"),
		TOOL_BLOODFILTER = uni_icon('icons/obj/surgery.dmi', "bloodfilter"),
		"drapes" = uni_icon('icons/obj/surgery.dmi', "surgical_drapes"),

		TOOL_MINING = uni_icon('icons/obj/mining.dmi', "minipick"),
		TOOL_SHOVEL = uni_icon('icons/obj/mining.dmi', "shovel"),
		"cultivator" = uni_icon('icons/obj/items_and_weapons.dmi', "cultivator"),
		"spade" = uni_icon('icons/obj/mining.dmi', "spade"),
		TOOL_RUSTSCRAPER = uni_icon('icons/obj/tools.dmi', "wirebrush"),
		TOOL_ROLLINGPIN = uni_icon('icons/obj/service/kitchen.dmi', "rolling_pin"),
		TOOL_BIKEHORN = uni_icon('icons/obj/items_and_weapons.dmi', "bike_horn"),
		"debug_placeholder" = uni_icon('icons/obj/device.dmi', "hypertool")
	)
	for(var/each in cache_targets)
		var/datum/universal_icon/entry = cache_targets[each]
		if(!entry)
			stack_trace("Error creating asset for '/datum/asset/spritesheet_batched/tools'. [each]'s icon entry is null.")
			continue
		entry.scale(32, 32)
		insert_icon(each, entry)

/datum/asset/simple/bee_antags
	assets = list(
		"traitor.png" = 'html/img/traitor.png',
		"bloodcult.png" = 'html/img/bloodcult.png',
		"cult-archives.gif" = 'html/img/cult-archives.gif',
		"cult-altar.gif" = 'html/img/cult-altar.gif',
		"cult-forge.gif" = 'html/img/cult-forge.gif',
		"cult-pylon.gif" = 'html/img/cult-pylon.gif',
		"cult-carve.png" = 'html/img/cult-carve.png',
		"cult-comms.png" = 'html/img/cult-comms.png',
		"dagger.png" = 'html/img/dagger.png',
		"sacrune.png" = 'html/img/sacrune.png',
		"archives.png" = 'html/img/archives.png',
		"xeno.png" = 'html/img/xeno.png',
		"xenoqueen.png" = 'html/img/xenoqueen.png',
		"facehugger.png" = 'html/img/facehugger.png',
		"xenolarva.png" = 'html/img/xenolarva.png',
		"blobcore.png" = 'html/img/blobcore.png',
		"blobnode.png" = 'html/img/blobnode.png',
		"blobresource.png" = 'html/img/blobresource.png',
		"blobfactory.png" = 'html/img/blobfactory.png',
		"changeling.gif" = 'html/img/changeling.gif',
		"emporium.gif" = 'html/img/emporium.gif',
		"absorb.png" = 'html/img/absorb.png',
		"tentacle.png" = 'html/img/tentacle.png',
		"hivemind.png" = 'html/img/hivemind.png',
		"sting_extract.png" = 'html/img/sting_extract.png',
		"wizard.png" = 'html/img/wizard.png',
		"nukie.png" = 'html/img/nukie.png',
		"ayylmao.png" = 'html/img/ayylmao.png',
		"headset.png" = 'html/img/headset.png',
		"pen.png" = 'html/img/pen.png',
		"pda.png" = 'html/img/pda.png',
		"spellbook.png" = 'html/img/spellbook.png',
		"scroll.png" = 'html/img/scroll.png',
		"disk.png" = 'html/img/disk.png',
		"nuke.png" = 'html/img/nuke.png',
		"eshield.png" = 'html/img/eshield.png',
		"mech.png" = 'html/img/mech.png',
		"abaton.png" = 'html/img/abaton.png',
		"atool.png" = 'html/img/atool.png',
		"apistol.png" = 'html/img/apistol.png',
		"scitool.png" = 'html/img/scitool.png',
		"alienorgan.png"= 'html/img/alienorgan.png',
		"abaton.png"= 'html/img/abaton.png',
		"spiderguard.png"= 'html/img/spiderguard.png',
		"spiderbroodmother.png"= 'html/img/spiderbroodmother.png',
		"spidernurse.png"= 'html/img/spidernurse.png',
		"spiderhunter.png"= 'html/img/spiderhunter.png',
		"spiderviper.png"= 'html/img/spiderviper.png',
		"spidertarantula.png"= 'html/img/spidertarantula.png',
	)

/datum/asset/simple/orbit
	assets = list(
		"ghost.png"	= 'html/ghost.png'
	)

/datum/asset/simple/vv
	assets = list(
		"view_variables.css" = 'html/admin/view_variables.css'
	)

/datum/asset/spritesheet_batched/sheetmaterials
	name = "sheetmaterials"

/datum/asset/spritesheet_batched/sheetmaterials/create_spritesheets()
	insert_all_icons("", 'icons/obj/stacks/minerals.dmi')

	// Special bee edit to handle Bluespace Crystals
	insert_icon("polycrystal", uni_icon('icons/obj/stacks/minerals.dmi', "refined_bluespace_crystal_3"))

/datum/asset/simple/pAI
	assets = list(
		"paigrid.png" = 'html/paigrid.png'
	)

/datum/asset/simple/portraits
	var/tab = "use subtypes of this please"
	assets = list()

/datum/asset/simple/portraits/library
	tab = "library"

/datum/asset/simple/portraits/library_secure
	tab = "library_secure"

/datum/asset/simple/portraits/library_private
	tab = "library_private"

/datum/asset/simple/portraits
	assets = list()

/datum/asset/simple/portraits/New()
	if(!length(SSpersistent_paintings.paintings))
		return
	for(var/datum/painting/portrait as anything in SSpersistent_paintings.paintings)
		var/png = "data/paintings/images/[portrait.md5].png"
		if(fexists(png))
			var/asset_name = "paintings_[portrait.md5]"
			assets[asset_name] = png
	..() //this is where it registers all these assets we added to the list

/datum/asset/simple/portraits/library
	tab = "library"

/datum/asset/simple/portraits/library_secure
	tab = "library_secure"

/datum/asset/simple/portraits/library_private
	tab = "library_private"

/datum/asset/spritesheet_batched/fish
	name = "fish"

/datum/asset/spritesheet_batched/fish/create_spritesheets()
	for (var/datum/aquarium_behaviour/fish/fish_type as() in subtypesof(/datum/aquarium_behaviour/fish))
		var/fish_icon = initial(fish_type.icon)
		var/fish_icon_state = initial(fish_type.icon_state)
		var/id = sanitize_css_class_name("[fish_icon][fish_icon_state]")
		if(entries[id]) //no dupes
			continue
		insert_icon(id, uni_icon(fish_icon, fish_icon_state))

/// Removes all non-alphanumerics from the text, keep in mind this can lead to id conflicts
/proc/sanitize_css_class_name(name)
	var/static/regex/regex = new(@"[^a-zA-Z0-9]","g")
	return replacetext(name, regex, "")

// NOTE: this must be below because bottom ones are loaded first in assets, and chat should be loaded or it causes just annoying runtime.
/datum/asset/spritesheet_batched/chat
	name = "chat"

/datum/asset/spritesheet_batched/chat/create_spritesheets()
	insert_all_icons("emoji", 'icons/emoji.dmi')
	insert_all_icons("badge", 'icons/badges.dmi')
	// pre-loading all lanugage icons also helps to avoid meta
	insert_all_icons("language", 'icons/misc/language.dmi')
	// catch languages which are pulling icons from another file
	for(var/datum/language/L as() in subtypesof(/datum/language))
		var/icon = initial(L.icon)
		if (icon != 'icons/misc/language.dmi')
			var/icon_state = initial(L.icon_state)
			insert_icon("language-[icon_state]", uni_icon(icon, icon_state))

/// Maps icon names to ref values
/datum/asset/json/icon_ref_map
	name = "icon_ref_map"
	early = TRUE

/datum/asset/json/icon_ref_map/generate()
	var/list/data = list() //"icons/obj/drinks.dmi" => "[0xc000020]"

	//var/start = "0xc000000"
	var/value = 0

	while(TRUE)
		value += 1
		var/ref = "\[0xc[num2text(value,6,16)]\]"
		var/mystery_meat = locate(ref)

		if(isicon(mystery_meat))
			if(!isfile(mystery_meat)) // Ignore the runtime icons for now
				continue
			var/path = get_icon_dmi_path(mystery_meat) //Try to get the icon path
			if(path)
				data[path] = ref
		else if(mystery_meat)
			continue //Some other non-icon resource, ogg/json/whatever
		else //Out of resources end this, could also try to end this earlier as soon as runtime generated icons appear but eh
			break

	return data
///Representative icons for the contents of each crafting recipe
/datum/asset/spritesheet_batched/crafting
	name = "crafting"

/datum/asset/spritesheet_batched/crafting/create_spritesheets()
	var/id = 1
	for(var/atom in GLOB.crafting_recipes_atoms)
		add_atom_icon(atom, id++)
	add_tool_icons()

/datum/asset/spritesheet_batched/crafting/cooking
	name = "cooking"

/datum/asset/spritesheet_batched/crafting/cooking/create_spritesheets()
	var/id = 1
	for(var/atom in GLOB.cooking_recipes_atoms)
		add_atom_icon(atom, id++)

/**
 * Adds the ingredient icon to the spritesheet with given ID
 *
 * ingredient_typepath can be an obj typepath OR a reagent typepath
 *
 * If it a reagent, it will use the default container's icon state,
 * OR if it has a glass style associated, it will use that
 */
/datum/asset/spritesheet_batched/crafting/proc/add_atom_icon(ingredient_typepath, id)
	var/icon_file
	var/icon_state
	var/obj/preview_item = ingredient_typepath
	if(ispath(ingredient_typepath, /datum/reagent))
		var/datum/reagent/reagent = ingredient_typepath
		preview_item = initial(reagent.default_container)
		var/datum/glass_style/style = GLOB.glass_style_singletons[preview_item]?[reagent]
		if(istype(style))
			icon_file = style.icon
			icon_state = style.icon_state

	icon_file ||= initial(preview_item.icon_preview) || initial(preview_item.icon)
	icon_state ||= initial(preview_item.icon_state_preview) || initial(preview_item.icon_state)

	//if(PERFORM_ALL_TESTS(focus_only/bad_cooking_crafting_icons))
	//	if(!icon_exists(icon_file, icon_state, scream = TRUE))
	//		return

	insert_icon("a[id]", uni_icon(icon_file, icon_state, SOUTH))

///Adds tool icons to the spritesheet
/datum/asset/spritesheet_batched/crafting/proc/add_tool_icons()
	var/list/tool_icons = list(
		TOOL_CROWBAR = uni_icon('icons/obj/tools.dmi', "crowbar"),
		TOOL_MULTITOOL = uni_icon('icons/obj/device.dmi', "multitool"),
		TOOL_SCREWDRIVER = uni_icon('icons/obj/tools.dmi', "screwdriver_map"),
		TOOL_WIRECUTTER = uni_icon('icons/obj/tools.dmi', "cutters_map"),
		TOOL_WRENCH = uni_icon('icons/obj/tools.dmi', "wrench"),
		TOOL_WELDER = uni_icon('icons/obj/tools.dmi', "welder"),
		TOOL_ANALYZER = uni_icon('icons/obj/device.dmi', "analyzer"),
		TOOL_MINING = uni_icon('icons/obj/mining.dmi', "minipick"),
		TOOL_SHOVEL = uni_icon('icons/obj/mining.dmi', "spade"),
		TOOL_RETRACTOR = uni_icon('icons/obj/surgery.dmi', "retractor"),
		TOOL_HEMOSTAT = uni_icon('icons/obj/surgery.dmi', "hemostat"),
		TOOL_CAUTERY = uni_icon('icons/obj/surgery.dmi', "cautery"),
		TOOL_DRILL = uni_icon('icons/obj/surgery.dmi', "drill"),
		TOOL_SCALPEL = uni_icon('icons/obj/surgery.dmi', "scalpel"),
		TOOL_SAW = uni_icon('icons/obj/surgery.dmi', "saw"),
		TOOL_KNIFE = uni_icon('icons/obj/service/kitchen.dmi', "knife"),
		TOOL_BLOODFILTER = uni_icon('icons/obj/surgery.dmi', "bloodfilter"),
		TOOL_ROLLINGPIN = uni_icon('icons/obj/service/kitchen.dmi', "rolling_pin"),
		TOOL_RUSTSCRAPER = uni_icon('icons/obj/tools.dmi', "wirebrush"),
	)

	for(var/tool in tool_icons)
		insert_icon(replacetext(tool, " ", ""), tool_icons[tool])
