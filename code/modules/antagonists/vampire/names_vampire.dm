/datum/antagonist/vampire/proc/return_full_name()
	var/fullname = vampire_name ? vampire_name : owner.current.name
	if(vampire_title)
		fullname = "[vampire_title] [fullname]"

	fullname += " the [get_rank_string(vampire_level)]"

	return fullname

///Returns a First name for the Vampire.
/datum/antagonist/vampire/proc/select_first_name()
	if(owner.current.gender == MALE)
		vampire_name = pick(
			"Desmond","Rudolph","Dracula","Vlad","Pyotr","Gregor",
			"Cristian","Christoff","Marcu","Andrei","Constantin",
			"Gheorghe","Grigore","Ilie","Iacob","Luca","Mihail","Pavel",
			"Vasile","Octavian","Sorin","Sveyn","Aurel","Alexe","Iustin",
			"Theodor","Dimitrie","Octav","Damien","Magnus","Caine","Abel", // Romanian/Ancient
			"Lucius","Gaius","Otho","Balbinus","Arcadius","Romanos","Alexios","Vitellius", // Latin
			"Melanthus","Teuthras","Orchamus","Amyntor","Axion", // Greek
			"Thoth","Thutmose","Osorkon,","Nofret","Minmotu","Khafra", // Egyptian
			"Dio",
		)
	else
		vampire_name = pick(
			"Islana","Tyrra","Greganna","Pytra","Hilda",
			"Andra","Crina","Viorela","Viorica","Anemona",
			"Camelia","Narcisa","Sorina","Alessia","Sophia",
			"Gladda","Arcana","Morgan","Lasarra","Ioana","Elena",
			"Alina","Rodica","Teodora","Denisa","Mihaela",
			"Svetla","Stefania","Diyana","Kelssa","Lilith", // Romanian/Ancient
			"Alexia","Athanasia","Callista","Karena","Nephele","Scylla","Ursa", // Latin
			"Alcestis","Damaris","Elisavet","Khthonia","Teodora", // Greek
			"Nefret","Ankhesenpep", // Egyptian
		)

///Returns a Title for the Vampire.
/datum/antagonist/vampire/proc/select_title()
	// Already have Title
	if(!isnull(vampire_title))
		return
	if(owner.current.gender == MALE)
		vampire_title = pick(
			"Count",
			"Baron",
			"Viscount",
			"Prince",
			"Duke",
			"Tzar",
			"Dreadlord",
			"Lord",
			"Master",
		)
	else
		vampire_title = pick(
			"Countess",
			"Baroness",
			"Viscountess",
			"Princess",
			"Duchess",
			"Tzarina",
			"Dreadlady",
			"Lady",
			"Mistress",
		)
	to_chat(owner, span_announce("You have earned a title! You are now known as <i>[return_full_name()]</i>!"))
