/obj/item/disk/turtle_cartridge
	name = "TSL v1.2 Cartridge"
	desc = "A cartridge for holding Turtle Scripting Language programs. Can be popped into a TurtleBot."

	var/list/lines = list()

	var/memory_limit = 16 //how many variables they can have set at a time
	var/storage_limit = 1024 //how many lines of code they can write to this cartridge

	var/running = FALSE

	var/regex/varname_regex = new("^\[a-z\]+$")

	var/list/variables = list()
	var/line = 1
	var/stack = list()

	var/mob/living/simple_animal/bot/turtle/turtle

/obj/item/disk/turtle_cartridge/proc/attach(mob/living/simple_animal/bot/turtle/T)
	turtle = T

/obj/item/disk/turtle_cartridge/proc/detach()
	stop()
	turtle = null

/obj/item/disk/turtle_cartridge/proc/execute()
	set waitfor = FALSE

	reset()
	if(!turtle)
		return

	turtle?.speak("EXECUTING PROGRAM")
	turtle?.beep("start")

	running = TRUE

	while(running && turtle)
		process_line()

/obj/item/disk/turtle_cartridge/proc/stop()
	running = FALSE

	turtle?.speak("PROGRAM TERMINATED")
	turtle?.beep("stop")

	reset()

/obj/item/disk/turtle_cartridge/proc/reset()
	line = 1
	variables = list()

/obj/item/disk/turtle_cartridge/proc/throw_error(err, part)
	turtle?.speak("[err]:[part ? " " : ""][part ? part : ""] ON LINE [line]")
	turtle?.beep("error")
	stop()

/obj/item/disk/turtle_cartridge/proc/is_varname(varname)
	return varname_regex.Find(varname) && length(varname) <= 16

/obj/item/disk/turtle_cartridge/proc/format_string(S)
	for(var/varname in variables)
		S = replacetext(S, "\[[varname]\]", "[variables[varname]]")
	return S

/obj/item/disk/turtle_cartridge/proc/process_val(val)
	if(!isnull(text2num(val)))
		return text2num(val)
	if(val in variables)
		return variables[val]
	if(text2dir(val)) //direction vars are builtin, but can be overidden, see two lines above
		return text2dir(val)

	if(is_varname(val))
		throw_error("UNDEFINED VAR", val)
	else
		throw_error("SYNTAX ERROR", val)

/obj/item/disk/turtle_cartridge/proc/process_line()
	if(!lines[line])
		stop()
		return

	turtle?.speak("PROCESSING LINE [lines[line]]")

	var/list/arguments = splittext(lines[line], " ")
	if(!arguments.len) return

	var/command = arguments[1]
	arguments.Cut(1,2)
	var/full_input = jointext(arguments, " ")

	var/wait = 1

	switch(command)
		if("MOVE", "GOTO", "WAIT")
			if(arguments.len != 1) throw_error("INVALID ARG AMOUNT", arguments.len)
			process_val(arguments[1])
		if("SET")
			if(arguments.len != 2) throw_error("INVALID ARG AMOUNT", arguments.len)
			if(!is_varname(arguments[1])) throw_error("INVALID VAR NAME", arguments[1])
			if(!(arguments[1] in variables) && variables.len == memory_limit) throw_error("OUT OF MEMORY")
			process_val(arguments[2])
		if("ADD","MUL")
			if(arguments.len != 2) throw_error("INVALID ARG AMOUNT", arguments.len)
			if(!(arguments[1] in variables)) throw_error("UNDEFINED VAR", arguments[1])
			process_val(arguments[2])

	if(!running) return //dont run any of this if we have stopped the program due to an error

	switch(command)
		if("SAY")
			if(full_input) turtle?.speak(format_string(full_input))
			wait = 10
		if("BEEP")
			turtle.beep("ping")
			wait = 10
		if("MOVE")
			turtle?.Move(get_step(get_turf(turtle), process_val(arguments[1])))
			wait = 2
		if("GOTO")
			line = process_val(arguments[1])
		if("WAIT")
			wait = process_val(arguments[1])
		if("SET")
			variables[arguments[1]] = process_val(arguments[2])
		if("ADD")
			variables[arguments[1]] += process_val(arguments[2])
		if("MUL")
			variables[arguments[1]] *= process_val(arguments[2])
		if("STOP")
			stop()
		if("#")
			wait = 0 //basically ignore this line since it's a comment
		else
			return throw_error("INVALID COMMAND", command)

	if(wait) sleep(wait)
	if(command != "GOTO")
		line++
	if (line > lines.len)
		stop()

/obj/item/disk/turtle_cartridge/test
	name = "TurtleOS v1.2 Test Cartridge"
	lines = list(
		"WAIT 20",
		"BEEP",
		"SET n 0",
		"SAY Hello World! \[n\]",
		"BEEP",
		"ADD n 1",
		"MUL n n",
		"MOVE east",
		"MOVE north",
		"GOTO 4"
	)

/obj/item/disk/turtle_cartridge/test2
	name = "TurtleOS v1.2 Test Cartridge"
	lines = list(
		"MOVE east",
		"GOTO 1"
	)
