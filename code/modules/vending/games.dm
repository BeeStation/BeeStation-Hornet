/obj/machinery/vending/games
	name = "\improper Good Clean Fun"
	desc = "Vends things that the Captain and Head of Personnel are probably not going to appreciate you fiddling with instead of your job..."
	product_ads = "Escape to a fantasy world!;Fuel your gambling addiction!;Ruin your friendships!;Roll for initiative!;Elves and dwarves!;Paranoid computers!;Totally not satanic!;Fun times forever!"
	icon_state = "games"
	light_color = LIGHT_COLOR_ORANGE
	products = list(
		/obj/item/storage/crayons = 2,
		/obj/item/toy/cards/deck = 5,
		/obj/item/chess_board = 1,
		/obj/item/chess_board/checkers = 1,
		/obj/item/storage/pill_bottle/dice = 10,
		/obj/item/storage/box/yatzy = 3,
		/obj/item/toy/cards/deck/cas = 3,
		/obj/item/toy/cards/deck/cas/black = 3,
		/obj/item/toy/cards/deck/unum = 3,
		/obj/item/toy/cards/deck/tarot = 3,
		/obj/item/hourglass = 2,
		/obj/item/camera = 3,
		/obj/item/camera_film = 5,
		/obj/item/razor=3,
		/obj/item/canvas/nineteen_nineteen = 5,
		/obj/item/canvas/twentythree_nineteen = 5,
		/obj/item/canvas/twentythree_twentythree = 5,
		/obj/item/paint_palette = 3
	)
	contraband = list(
		/obj/item/dice/fudge = 9,
		/obj/item/instrument/musicalmoth = 1
		)
	premium = list(
		/obj/item/melee/skateboard/pro = 3,
		/obj/item/canvas/twentyfour_twentyfour = 5,
		/obj/item/airlock_painter = 1,
		/obj/item/melee/skateboard/hoverboard = 1
	)
	refill_canister = /obj/item/vending_refill/games
	default_price = 10
	extra_price = 25
	dept_req_for_free = ACCOUNT_SRV_BITFLAG
	light_mask = "games-light-mask"

/obj/item/vending_refill/games
	machine_name = "\improper Good Clean Fun"
	icon_state = "refill_games"
