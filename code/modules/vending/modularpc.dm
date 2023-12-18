/obj/machinery/vending/modularpc
	name = "\improper Deluxe Silicate Selections"
	desc = "All the parts you need to build your own custom pc."
	icon_state = "modularpc"
	icon_deny = "modularpc-deny"
	product_ads = "Get your gamer gear!;The best GPUs for all of your space-crypto needs!;The most robust cooling!;The finest RGB in space!"
	vend_reply = "Game on!"
	light_color = LIGHT_COLOR_WHITE
	products = list(/obj/item/modular_computer/laptop = 3,
					/obj/item/modular_computer/tablet = 5,
					/obj/item/storage/box/tablet4dummies = 4,
					/obj/item/computer_hardware/identifier = 4,
					/obj/item/computer_hardware/card_slot = 4,
					/obj/item/computer_hardware/hard_drive/micro = 8,
					/obj/item/computer_hardware/hard_drive/small = 4,
					/obj/item/computer_hardware/hard_drive = 3,
					/obj/item/computer_hardware/hard_drive/advanced = 2,
					/obj/item/computer_hardware/hard_drive/super = 1,
					/obj/item/computer_hardware/network_card = 8,
					/obj/item/computer_hardware/network_card/advanced = 4,
					/obj/item/computer_hardware/hard_drive/portable = 8,
					/obj/item/computer_hardware/hard_drive/portable/advanced = 4,
					/obj/item/computer_hardware/hard_drive/portable/super = 2,
					/obj/item/computer_hardware/battery = 8,
					/obj/item/stock_parts/cell/computer/nano = 8,
					/obj/item/stock_parts/cell/computer/micro = 4,
					/obj/item/stock_parts/cell/computer = 3,
					/obj/item/stock_parts/cell/computer/advanced = 2,
					/obj/item/stock_parts/cell/computer/super = 1,
					/obj/item/computer_hardware/processor_unit/small = 4,
					/obj/item/computer_hardware/processor_unit = 3,
					/obj/item/computer_hardware/processor_unit/photonic/small = 2,
					/obj/item/computer_hardware/processor_unit/photonic = 1,
					/obj/item/computer_hardware/sensorpackage = 4,
					/obj/item/computer_hardware/printer/mini = 2,
					/obj/item/computer_hardware/camera_component = 4,
					/obj/item/storage/box/tabletcolorizer = 5)
	premium = list(/obj/item/colorizer/tablet/gw = 2,
					/obj/item/colorizer/tablet/rugged = 2,
					/obj/item/colorizer/tablet/clearp = 2,
					/obj/item/colorizer/tablet/clearb = 2,
					/obj/item/colorizer/tablet/cat = 2,
					/obj/item/computer_hardware/ai_slot = 2,
					/obj/item/computer_hardware/recharger/APC = 2,
					/obj/item/computer_hardware/radio_card = 1,
					/obj/item/paicard = 2)
	contraband = list(/obj/item/computer_hardware/card_slot/secondary = 1,
					/obj/item/colorizer/tablet/syndi = 2,
					/obj/item/colorizer/tablet/contractor = 2,
					/obj/item/colorizer/tablet/emag = 2)
	refill_canister = /obj/item/vending_refill/modularpc
	default_price = 30
	extra_price = 100
	dept_req_for_free = ACCOUNT_SCI_BITFLAG

/obj/item/vending_refill/modularpc
	machine_name = "Deluxe Silicate Selections"
	icon_state = "refill_engi"
