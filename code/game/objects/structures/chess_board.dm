//Basically the same logic as wall closets but cut down a bit and with more restrictions

/obj/structure/chess_board
	name = "chess board"
	desc = "It's a checkered board, made for playing chess."
	anchored = TRUE
	icon = 'icons/obj/chess_board.dmi'
	icon_state = "chess_board"
	var/list/chess_board_contents
	var/populated = FALSE
	var/folded_type = /obj/item/chess_board

/obj/structure/chess_board/checkers
	name = "checkers board"
	desc = "It's a checkered board, made for playing checkers, obviously."
	folded_type = /obj/item/chess_board/checkers

/obj/structure/chess_board/Initialize(mapload)
	. = ..()
	initalize_chess_board_storage()
	update_contents_icons()
	if(mapload)
		pupulate_chess_board()

/obj/structure/chess_board/proc/initalize_chess_board_storage()
	chess_board_contents = list()
	for(var/I in 1 to 64)
		var/list/item_entry = list()
		chess_board_contents += list(item_entry)

/obj/structure/chess_board/proc/pupulate_chess_board()
	for(var/I in 1 to 64)
		var/inserting_piece
		switch(I)
			if(1, 8) //black rooks
				inserting_piece = /obj/item/chess_piece/black/rook

			if(2, 7) //black knights
				inserting_piece = /obj/item/chess_piece/black/knight

			if(3, 6) //black bishops
				inserting_piece = /obj/item/chess_piece/black/bishop

			if(4) //black queen
				inserting_piece = /obj/item/chess_piece/black/queen

			if(5) //black king
				inserting_piece = /obj/item/chess_piece/black/king

			if(9 to 16) //black pawns
				inserting_piece = /obj/item/chess_piece/black/pawn

			if(57, 64) //white rooks
				inserting_piece = /obj/item/chess_piece/white/rook

			if(58, 63) //white knights
				inserting_piece = /obj/item/chess_piece/white/knight

			if(59, 62) //white bishops
				inserting_piece = /obj/item/chess_piece/white/bishop

			if(60) //white queen
				inserting_piece = /obj/item/chess_piece/white/queen

			if(61) //white king
				inserting_piece = /obj/item/chess_piece/white/king

			if(49 to 56) //white pawns
				inserting_piece = /obj/item/chess_piece/white/pawn

		if(inserting_piece)
			inserting_piece = new inserting_piece()
			chess_board_insert_item(inserting_piece, I)
	populated = TRUE

/obj/structure/chess_board/checkers/pupulate_chess_board()
	for(var/I in 1 to 64)
		var/inserting_piece
		switch(I)

			if(1, 3, 5, 7, 10, 12, 14, 16, 17, 19, 21, 23)
				inserting_piece = /obj/item/chess_piece/checkers/black

			if(42, 44, 46, 48, 49, 51, 53, 55, 58, 60, 62, 64)
				inserting_piece = /obj/item/chess_piece/checkers/white

		if(inserting_piece)
			inserting_piece = new inserting_piece()
			chess_board_insert_item(inserting_piece, I)
	populated = TRUE


/obj/structure/chess_board/proc/chess_board_insert_item(obj/item/inserted_item, ui_index)
	if(istype(inserted_item, /obj/item/chess_piece) || istype(inserted_item, /obj/item/toy/figure))
		if(contents.len >= 64)
			return FALSE
		if(!ui_index)
			for(var/index in 1 to chess_board_contents.len)
				var/list/L = list()
				L = chess_board_contents[index]
				if(L.len <= 0)
					ui_index = index
					break
		chess_board_contents[ui_index]["item"] = inserted_item
		inserted_item.forceMove(src)
		update_contents_icons()
		return TRUE

/obj/structure/chess_board/proc/update_contents_icons()
	for(var/list/list_item in chess_board_contents)
		if(!list_item.len <= 0)
			var/obj/item/current_item = list_item["item"]
			list_item["icon"] = current_item.icon
			list_item["icon_state"] = current_item.icon_state
			list_item["name"] = current_item.name
			list_item["show"] = TRUE

/obj/structure/chess_board/proc/chess_board_remove_item(ui_index)
	var/obj/item/removed_item = chess_board_contents[ui_index]["item"]
	usr.put_in_hands(removed_item)
	var/list/L = list()
	L = chess_board_contents[ui_index]
	L.Cut()

/obj/structure/chess_board/attackby(obj/item/I, mob/living/user)
	if(!user.combat_mode)
		if(checkmate(I, user))
			return
		if(chess_board_insert_item(I))
			to_chat(user, span_notice("you chuck \the [I.name] onto \the [src.name]"))
		ui_update()
		return
	return ..()

/obj/structure/chess_board/proc/checkmate(obj/item/grenade, mob/user) // the fabled grenade gambit
	if(!istype(grenade, /obj/item/grenade))
		return FALSE
	SStgui.close_uis(src)
	var/obj/item/grenade/nade = grenade
	nade.forceMove(loc)
	nade.pixel_y = 7
	nade.anchored = TRUE
	balloon_alert_to_viewers("Checkmate!")
	if(!nade.active)
		nade.preprime(user, 20)
	return TRUE


/obj/structure/chess_board/MouseDrop(over_object)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
			return FALSE
		usr.visible_message("[usr] folds \the [src.name].", span_notice("You fold \the [src.name]."))
		var/obj/item/chess_board/board = new folded_type ()
		board.populated = populated
		board.sorted_contents = chess_board_contents
		for(var/obj/item/I in contents)
			I.forceMove(board)
		usr.put_in_hands(board)
		qdel(src)

/obj/structure/chess_board/ui_interact(mob/user, datum/tgui/ui, datum/ui_state/state)
	update_contents_icons()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChessBoard")
		ui.set_autoupdate(FALSE)
		ui.open()
		if(!isliving(user))
			return


/obj/structure/chess_board/attack_robot(mob/user)
	if(!Adjacent(user))
		return
	ui_interact(user)
	return

/obj/structure/chess_board/ui_data(mob/user)
	var/list/data = list()
	data["contents"] = chess_board_contents
	return data

/obj/structure/chess_board/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(istype(usr, /mob/living/silicon))
		return
	switch(action)
		if("ItemClick")
			var/ui_index = params["SlotKey"]
			if(chess_board_contents[ui_index]["item"])
				chess_board_remove_item(ui_index)
				return TRUE

			if(usr.get_active_held_item())
				var/obj/item/I = usr.get_active_held_item()
				if(checkmate(I, usr))
					return TRUE
				chess_board_insert_item(I, ui_index)

			return TRUE

/obj/structure/chess_board/ui_status(mob/user)
	if(!in_range(user,src))
		return UI_CLOSE
	return ..()

/obj/structure/chess_board/Destroy()
	dump_contents()
	chess_board_contents = null
	return ..()

/obj/structure/chess_board/dump_contents()
	var/atom/L = drop_location()
	for(var/obj/item/I in src)
		I.forceMove(L)

//folded up chess board

/obj/item/chess_board
	name = "folded chess board"
	desc = "Foldable, for gaming on the go. Place on a table for optimal playing experience."
	icon = 'icons/obj/chess_board.dmi'
	icon_state = "chess_board_folded"
	w_class = WEIGHT_CLASS_LARGE
	var/list/sorted_contents
	var/populated = FALSE
	var/unfolded_type = /obj/structure/chess_board

/obj/item/chess_board/checkers
	name = "folded checkers board"
	desc = "Foldable, for gaming on the go. Place on a table for optimal playing experience."
	unfolded_type = /obj/structure/chess_board/checkers

/obj/item/chess_board/pre_attack(atom/target, mob/user, proximity)
	if(!istype(target, /obj/structure/table))
		return ..()
	if(!proximity)
		return ..()
	if(locate(/obj/structure/chess_board) in get_turf(target))
		balloon_alert(user, "no room!")
		return
	var/obj/structure/chess_board/board = new unfolded_type (target.loc)
	board.populated = populated
	board.pixel_y = 5
	if(!populated)
		board.pupulate_chess_board()
	else
		board.chess_board_contents = sorted_contents
		for(var/obj/item/I in contents)
			I.forceMove(board)
	qdel(src)

/obj/item/chess_board/Destroy()
	dump_contents()
	sorted_contents = null
	return ..()

/obj/item/chess_board/dump_contents()
	var/atom/L = drop_location()
	for(var/obj/item/I in src)
		I.forceMove(L)

//chess pieces

/obj/item/chess_piece
	name = "chess piece"
	desc = "how did you get your hands on this?"
	icon = 'icons/obj/chess_board.dmi'
	icon_state = "pawn_white"
	w_class = WEIGHT_CLASS_TINY
	pickup_sound = 'sound/items/handling/screwdriver_pickup.ogg'
	drop_sound = 'sound/items/handling/standard_stamp.ogg'

/obj/item/chess_piece/white/pawn
	name = "white pawn"
	desc = "Don't underestimate the pawn"
	icon_state = "pawn_white"

/obj/item/chess_piece/white/rook
	name = "white rook"
	desc = "Sturdy as a brick wall"
	icon_state = "rook_white"

/obj/item/chess_piece/white/bishop
	name = "white bishop"
	desc = "Very dedicated to staying on one color"
	icon_state = "bishop_white"

/obj/item/chess_piece/white/knight
	name = "white knight"
	desc = "The horsey jumps in an L"
	icon_state = "knight_white"

/obj/item/chess_piece/white/queen
	name = "white queen"
	desc = "Girl power"
	icon_state = "queen_white"

/obj/item/chess_piece/white/king
	name = "white king"
	desc = "The 1% which you have to protect"
	icon_state = "king_white"

/obj/item/chess_piece/black/pawn
	name = "black pawn"
	desc = "Don't underestimate the pawn"
	icon_state = "pawn_black"

/obj/item/chess_piece/black/rook
	name = "black rook"
	desc = "Sturdy as a brick wall"
	icon_state = "rook_black"

/obj/item/chess_piece/black/bishop
	name = "black bishop"
	desc = "Very dedicated to staying on one color"
	icon_state = "bishop_black"

/obj/item/chess_piece/black/knight
	name = "black knight"
	desc = "The horsey jumps in an L"
	icon_state = "knight_black"

/obj/item/chess_piece/black/queen
	name = "black queen"
	desc = "Girl power"
	icon_state = "queen_black"

/obj/item/chess_piece/black/king
	name = "black king"
	desc = "The 1% which you have to protect"
	icon_state = "king_black"

//checkers pieces

/obj/item/chess_piece/checkers
	name = "checkers piece"
	desc = "how did you get your hands on this?"
	icon_state = "checkers_white"
	var/king_type = null
	var/piece_type = null

/obj/item/chess_piece/checkers/attackby(obj/item/I, mob/living/user)
	if(I.type == type)
		var/obj/item/chess_piece/checkers/king = new king_type ()
		qdel(I)
		user.put_in_hands(king)
		qdel(src)
	return ..()

/obj/item/chess_piece/checkers/attack_self(mob/user)
	if(piece_type)
		forceMove(user.loc)
		for(var/I in 1 to 2)
			var/obj/item/chess_piece/checkers/piece = new piece_type ()
			user.put_in_hands(piece)
		qdel(src)
	return ..()

/obj/item/chess_piece/checkers/white
	name = "white checkers piece"
	desc = "A small, disc shaped, checkers piece. Waiting patiently to execute that 10 jump combo."
	icon_state = "checkers_white"
	king_type = /obj/item/chess_piece/checkers/white/king

/obj/item/chess_piece/checkers/white/king
	name = "white checkers king"
	desc = "Two small, disc shaped checkers pieces, stacked on top of eachother. With their powers combined, they can now move backward."
	icon_state = "checkers_king_white"
	piece_type = /obj/item/chess_piece/checkers/white

/obj/item/chess_piece/checkers/black
	name = "black checkers piece"
	desc = "A small, disc shaped, checkers piece. Waiting patiently to execute that 10 jump combo."
	icon_state = "checkers_black"
	king_type = /obj/item/chess_piece/checkers/black/king

/obj/item/chess_piece/checkers/black/king
	name = "black checkers king"
	desc = "Two small, disc shaped checkers pieces, stacked on top of eachother. With their powers combined, they can now move backward."
	icon_state = "checkers_king_black"
	piece_type = /obj/item/chess_piece/checkers/black
