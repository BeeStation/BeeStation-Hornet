
///how much paper it takes from the printer to create a canvas.
#define CANVAS_PAPER_COST 10

/**
 * ## portrait printer!
 *
 * Program that lets the curator browse all of the portraits in the database
 * They are free to print them out as they please.
 */
/datum/computer_file/program/portrait_printer
	filename = "PortraitPrinter"
	filedesc = "Marlowe Treeby's Art Galaxy"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "dummy"
	extended_desc = "This program connects to a Spinward Sector community art site for viewing and printing art."
	transfer_access = list(ACCESS_LIBRARY)
	usage_flags = PROGRAM_CONSOLE
	requires_ntnet = TRUE
	size = 9
	tgui_id = "NtosPortraitPrinter"
	program_icon = "print"

/datum/computer_file/program/portrait_printer/ui_data(mob/user)
	var/list/data = list()
	data["library"] = SSpersistence.paintings["library"] ? SSpersistence.paintings["library"] : 0
	data["library_secure"] = SSpersistence.paintings["library_secure"] ? SSpersistence.paintings["library_secure"] : 0
	data["library_private"] = SSpersistence.paintings["library_private"] ? SSpersistence.paintings["library_private"] : 0 //i'm gonna regret this, won't i?
	return data

/datum/computer_file/program/portrait_printer/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/portraits/library),
		get_asset_datum(/datum/asset/simple/portraits/library_secure),
		get_asset_datum(/datum/asset/simple/portraits/library_private)
	)

/datum/computer_file/program/portrait_printer/ui_act(action, params)
	. = ..()
	if(.)
		return

	//printer check!
	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]
	if(!printer)
		to_chat(usr, "<span class='notice'>Hardware error: A printer is required to print a canvas.</span>")
		return
	if(printer.stored_paper < CANVAS_PAPER_COST)
		to_chat(usr, "<span class='notice'>Printing error: Your printer needs at least [CANVAS_PAPER_COST] paper to print a canvas.</span>")
		return
	printer.stored_paper -= CANVAS_PAPER_COST

	//canvas printing!
	var/list/tab2key = list(TAB_LIBRARY = "library", TAB_SECURE = "library_secure", TAB_PRIVATE = "library_private")
	var/folder = tab2key[params["tab"]]
	var/list/current_list = SSpersistence.paintings[folder]
	var/list/chosen_portrait = current_list[params["selected"]]
	var/author = chosen_portrait["author"]
	var/title = chosen_portrait["title"]
	var/png = "data/paintings/[folder]/[chosen_portrait["md5"]].png"
	var/icon/art_icon = new(png)
	var/obj/item/canvas/printed_canvas
	var/art_width = art_icon.Width()
	var/art_height = art_icon.Height()
	for(var/canvas_type in typesof(/obj/item/canvas))
		printed_canvas = canvas_type
		if(initial(printed_canvas.width) == art_width && initial(printed_canvas.height) == art_height)
			printed_canvas = new canvas_type(get_turf(computer.physical))
			break
	printed_canvas.fill_grid_from_icon(art_icon)
	printed_canvas.generated_icon = art_icon
	printed_canvas.icon_generated = TRUE
	printed_canvas.finalized = TRUE
	printed_canvas.painting_name = title
	printed_canvas.author_ckey = author
	printed_canvas.name = "painting - [title]"
	///this is a copy of something that is already in the database- it should not be able to be saved.
	printed_canvas.no_save = TRUE
	printed_canvas.update_icon()
	to_chat(usr, "<span class='notice'>You have printed [title] onto a new canvas.</span>")
	playsound(computer.physical, 'sound/items/poster_being_created.ogg', 100, TRUE)
