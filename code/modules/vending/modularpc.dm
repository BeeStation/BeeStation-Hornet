/obj/machinery/vending/modularpc
	name = "\improper Deluxe Silicate Selections"
	desc = "All the parts you need to build your own custom pc."
	icon_state = "modularpc"
	icon_deny = "modularpc-deny"
	light_mask = "modular-light-mask"
	product_ads = "Get your gamer gear!;The best GPUs for all of your space-crypto needs!;The most robust cooling!;The finest RGB in space!"
	vend_reply = "Game on!"
	light_color = LIGHT_COLOR_WHITE

	product_categories = list(

		list(
			"name" = "Devices & Kits",
			"icon" = "toolbox",
			"products" = list(
					/obj/item/paicard = 2,
					/obj/item/modular_computer/laptop = 3,
					/obj/item/modular_computer/tablet = 3,
					/obj/item/storage/box/tablet4dummies = 6,
					/obj/item/storage/box/tabletcolorizer = 3,
					/obj/item/computer_hardware/identifier = 6,
			),
		),

		list(
			"name" = "Processors",
			"icon" = "microchip",
			"products" = list(
					/obj/item/computer_hardware/processor_unit/small = 6,
					/obj/item/computer_hardware/processor_unit = 6,
					/obj/item/computer_hardware/processor_unit/photonic/small = 3,
					/obj/item/computer_hardware/processor_unit/photonic = 3,
			),
		),

		list(
			"name" = "Power",
			"icon" = "battery-half",
			"products" = list(
					/obj/item/computer_hardware/battery/tiny = 6,
					/obj/item/computer_hardware/battery/small = 6,
					/obj/item/computer_hardware/battery/standard = 3,
					/obj/item/computer_hardware/battery/large = 3,
					/obj/item/computer_hardware/battery/huge = 3,
			),
		),

		list(
			"name" = "Storage",
			"icon" = "hard-drive",
			"products" = list(
					/obj/item/computer_hardware/hard_drive/micro = 3,
					/obj/item/computer_hardware/hard_drive/small = 3,
					/obj/item/computer_hardware/hard_drive = 3,
					/obj/item/computer_hardware/hard_drive/advanced = 3,
					/obj/item/computer_hardware/hard_drive/super = 3,
			),
		),

		list(
			"name" = "Disks",
			"icon" = "floppy-disk",
			"products" = list(
					/obj/item/computer_hardware/hard_drive/portable = 2,
					/obj/item/computer_hardware/hard_drive/portable/advanced = 2,
					/obj/item/computer_hardware/hard_drive/portable/super = 2,
					/obj/item/computer_hardware/hard_drive/role/antivirus = 2,
			),
		),

		list(
			"name" = "Networking",
			"icon" = "signal",
			"products" = list(
					/obj/item/computer_hardware/network_card = 6,
					/obj/item/computer_hardware/network_card/advanced = 3,
					/obj/item/computer_hardware/radio_card = 6,
			),
		),

		list(
			"name" = "Peripherals",
			"icon" = "address-card",
			"products" = list(
					/obj/item/computer_hardware/card_slot = 6,
					/obj/item/computer_hardware/card_slot/secondary = 3,
					/obj/item/computer_hardware/ai_slot = 3,
					/obj/item/computer_hardware/sensorpackage = 6,
					/obj/item/computer_hardware/printer/mini = 6,
					/obj/item/computer_hardware/printer = 3,
			),
		),

		list(
			"name" = "Skins",
			"icon" = "spray-can",
			"products" = list(
					/obj/item/colorizer/tablet/gw = 6,
					/obj/item/colorizer/tablet/rugged = 6,
					/obj/item/colorizer/tablet/clearp = 6,
					/obj/item/colorizer/tablet/clearb = 6,
					/obj/item/colorizer/tablet/cat = 6,
			),
		)
	)

	contraband = list(
					/obj/item/computer_hardware/recharger/APC = 2,
					/obj/item/storage/box/hacking4dummies = 4,
					/obj/item/computer_hardware/radio_card = 1,
					/obj/item/colorizer/tablet/syndi = 2,
					/obj/item/colorizer/tablet/contractor = 2,
					/obj/item/colorizer/tablet/emag = 2
	)

	refill_canister = /obj/item/vending_refill/modularpc
	default_price = PAYCHECK_MEDIUM

/obj/item/vending_refill/modularpc
	machine_name = "Deluxe Silicate Selections"
	icon_state = "refill_engi"
