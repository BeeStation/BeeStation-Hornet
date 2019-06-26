/datum/stack_item
	var/line
	var/skipping
	var/condition

/datum/stack_item/cmd_if
/datum/stack_item/cmd_while


/obj/item/disk/turtle_cartridge
	name = "TSL v1.2 Cartridge"
	desc = "A cartridge for holding Turtle Scripting Language programs. Can be popped into a TurtleBot."

	var/regex/varname_regex = new("^\[a-z\]+$")

	var/list/lines = list()
	var/memory_limit = 16 //how many variables they can have set at a time
	var/storage_limit = 1024 //how many lines of code they can write to this cartridge

	var/list/variables = list()
	var/list/stack = list()
	var/line = 1
	var/running = FALSE

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

/obj/item/disk/turtle_cartridge/proc/process_expression(list/args)
	if(args.len == 1)
		return process_val(args[1])
	else if(args.len == 2)
		switch(args[1])
			if("NOT")
				return !process_val(args[2])
			if("ABS")
				return abs(process_val(args[2]))
			if("FLOOR")
				return FLOOR(process_val(args[2]), 1)
			if("CEIL")
				return CEILING(process_val(args[2]), 1)
			if("ROUND")
				return round(process_val(args[2]))
			if("NEG")
				return -process_val(args[2])
			if("SQRT")
				return sqrt(process_val(args[2]))
			else
				throw_error("SYNTAX ERROR")
	else if(args.len == 3)
		switch(args[2])
			if("ADD")
				return process_val(args[1]) + process_val(args[3])
			if("SUB")
				return process_val(args[1]) - process_val(args[3])
			if("MUL")
				return process_val(args[1]) * process_val(args[3])
			if("DIV")
				if (process_val(args[3]) == 0) return throw_error("DIV BY 0")
				return process_val(args[1]) / process_val(args[3])
			if("MOD")
				if (process_val(args[3]) == 0) return throw_error("DIV BY 0")
				return process_val(args[1]) % process_val(args[3])
			if("POW")
				return process_val(args[1]) ** process_val(args[3])
			if("MIN")
				return min(process_val(args[1]), process_val(args[3]))
			if("MAX")
				return max(process_val(args[1]), process_val(args[3]))
			if("LT")
				return process_val(args[1]) < process_val(args[3])
			if("LE")
				return process_val(args[1]) <= process_val(args[3])
			if("GT")
				return process_val(args[1]) > process_val(args[3])
			if("GE")
				return process_val(args[1]) >= process_val(args[3])
			if("EQ")
				return process_val(args[1]) == process_val(args[3])
			if("NE")
				return process_val(args[1]) != process_val(args[3])
			if("OR")
				return process_val(args[1]) || process_val(args[3])
			if("AND")
				return process_val(args[1]) && process_val(args[3])
			else
				throw_error("SYNTAX ERROR")

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

	if (stack.len)
		var/datum/stack_item/I = stack[stack.len]
		if (command == "END")
			if (istype(I, /datum/stack_item/cmd_while))
				if(I.skipping)
					stack.len --
				else
					if(process_expression(I.condition))
						line = I.line
					else
						stack.len --
			else if(istype(I, /datum/stack_item/cmd_if))
				stack.len --
			else
				stack.len --

		else if (I.skipping)
			if(command == "IF" || command == "WHILE") //acount for if and while even if we're skipping so we match up ends
				var/datum/stack_item/NI = new
				NI.skipping = TRUE
				stack += NI

			line++
			if (line > lines.len)
				stop()
			return

	else if(command == "END")
		throw_error("MISMATCHED END")

	if(!running) return

	switch(command)
		if("MOVE", "GOTO", "WAIT")
			if(arguments.len < 1) throw_error("INVALID ARG AMOUNT", arguments.len)
			process_val(process_expression(arguments))
		if("SET")
			if(arguments.len < 2) throw_error("INVALID ARG AMOUNT", arguments.len)
			if(!is_varname(arguments[1])) throw_error("INVALID VAR NAME", arguments[1])
			if(!(arguments[1] in variables) && variables.len == memory_limit) throw_error("OUT OF MEMORY")
			process_expression(arguments.Copy(2))
		if("WHILE", "IF")
			if(arguments.len < 1) throw_error("CONDITION NOT SUPPLIED")
			process_expression(arguments)

	if(!running) return //dont run any of this if we have stopped the program due to an error

	switch(command)
		if("SAY")
			if(full_input) turtle?.speak(format_string(full_input))
			wait = 10
		if("BEEP")
			turtle.beep("ping")
			wait = 10
		if("MOVE")
			turtle?.Move(get_step(get_turf(turtle), process_expression(arguments)))
			wait = 2
		if("GOTO")
			line = process_expression(arguments)
		if("WAIT")
			wait = process_expression(arguments)
		if("SET")
			variables[arguments[1]] = process_expression(arguments.Copy(2))
		if("STOP")
			stop()
		if("IF")
			var/datum/stack_item/cmd_if/I = new
			I.condition = arguments
			I.line = line
			I.skipping = !process_expression(arguments)
			stack += I
		if("WHILE")
			var/datum/stack_item/cmd_while/I = new
			I.condition = arguments
			I.line = line
			I.skipping = !process_expression(arguments)
			stack += I

		if("#")
			wait = 0 //basically ignore this line since it's a comment
		if("END")
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
		"SET n n ADD 1",
		"SET n n MUL n",
		"MOVE east",
		"MOVE north",
		"GOTO 4"
	)

/obj/item/disk/turtle_cartridge/test2
	name = "TurtleOS v1.2 Test Cartridge"
	lines = list(
		"SET n 0",
		"WHILE n LT 20",
		"IF n MOD 2",
		"SAY \[n\] IS ODD",
		"IF n EQ 11",
		"SAY \[n\] IS ODD and 10",
		"END",
		"END",
		"END"
	)
