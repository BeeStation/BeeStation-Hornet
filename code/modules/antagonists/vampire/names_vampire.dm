GLOBAL_VAR_INIT(vampire_names_male, shuffle(list(
	"Desmond","Rudolph","Dracula","Vlad","Pyotr","Gregor",
	"Cristian","Christoff","Marcu","Andrei","Constantin",
	"Gheorghe","Grigore","Ilie","Iacob","Luca","Mihail","Pavel",
	"Vasile","Octavian","Sorin","Sveyn","Aurel","Alexe","Iustin",
	"Theodor","Dimitrie","Octav","Damien","Magnus","Caine","Abel", // Romanian/Ancient
	"Lucius","Gaius","Otho","Balbinus","Arcadius","Romanos","Alexios","Vitellius", // Latin
	"Melanthus","Teuthras","Orchamus","Amyntor","Axion", // Greek
	"Thoth","Thutmose","Osorkon,","Nofret","Minmotu","Khafra", // Egyptian
	"Dio",
)))

GLOBAL_VAR_INIT(vampire_names, shuffle(list(
	"Islana","Tyrra","Greganna","Pytra","Hilda",
	"Andra","Crina","Viorela","Viorica","Anemona",
	"Camelia","Narcisa","Sorina","Alessia","Sophia",
	"Gladda","Arcana","Morgan","Lasarra","Ioana","Elena",
	"Alina","Rodica","Teodora","Denisa","Mihaela",
	"Svetla","Stefania","Diyana","Kelssa","Lilith", // Romanian/Ancient
	"Alexia","Athanasia","Callista","Karena","Nephele","Scylla","Ursa", // Latin
	"Alcestis","Damaris","Elisavet","Khthonia","Teodora", // Greek
	"Nefret","Ankhesenpep", // Egyptian
)))

/datum/antagonist/vampire/proc/return_full_name()
	var/fullname = vampire_name || owner.name || owner.current.real_name || owner.current.name

	fullname += " the [get_rank_string(vampire_level)]"

	return fullname

///Returns a First name for the Vampire.
/datum/antagonist/vampire/proc/select_first_name()
	var/list/name_list // blah blah blah lists are references
	if(owner.current.gender == MALE)
		name_list = GLOB.vampire_names_male
	else
		name_list = GLOB.vampire_names
	// as the list is shuffled initially, we can just pick the first name, then move it to the back.
	// in theory, as long as there's not a morbillion vampires, we should never have any duplicate names
	vampire_name = popleft(name_list)
	name_list += vampire_name
