//lavaland_surface_syndicate_base1.dmm

/obj/machinery/vending/syndichem
	name = "\improper SyndiChem"
	desc = "A vending machine full of grenades and grenade accessories. Sponsored by DonkCo(tm)."
	req_access = list(ACCESS_SYNDICATE)
	products = list(/obj/item/stack/cable_coil/random = 5,
					/obj/item/assembly/igniter = 20,
					/obj/item/assembly/prox_sensor = 5,
					/obj/item/assembly/signaler = 5,
					/obj/item/assembly/timer = 5,
					/obj/item/assembly/voice = 5,
					/obj/item/assembly/health = 5,
					/obj/item/assembly/infra = 5,
					/obj/item/grenade/chem_grenade = 5,
					/obj/item/grenade/chem_grenade/pyro = 5,
					/obj/item/grenade/chem_grenade/cryo = 5,
					/obj/item/grenade/chem_grenade/adv_release = 5,
					/obj/item/reagent_containers/cup/glass/bottle/holywater = 1)
	product_slogans = "It's not pyromania if you're getting paid!;You smell that? Plasma, son. Nothing else in the world smells like that.;I love the smell of Plasma in the morning."
	resistance_flags = FIRE_PROOF

/obj/item/paper/fluff/ruins/syndicomms
	name = "paper - 'Communication Frequencies'"
	default_raw_text = "Greetings, Agent. I see you have awaken from your cryogenic slumber. This either means that the new Nanotrasen space project is complete and operational in a nearby sector, or that Ashlanders have launched an assault on our base. We recommend you get rid of any pests and do not confuse them for humans.<br><br>In case you don't remember how to do your job, all you need is the equipment we provided; your Chameleon Mask, your Agent ID, and the intercom nearby. A nearby shelf contains all the names and jobs of the current Nanotrasen employees. Assign their name and job to your ID, and your Mask will mimic the voice of whoever you are impersonating.<br><br>Oh, one more thing. Here is a list of frequencies for you to troll on:<br><ul><li>145.9 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Service Channel</li><li>134.7 - Supply Channel</li><li>136.1 - Exploration Channel</li>"
