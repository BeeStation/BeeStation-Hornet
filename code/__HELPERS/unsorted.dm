//here lies unsorted.dm, bane of many coders, pain of lots of maintainers

//* 2005? / + 2022
/proc/_client_alert(client/C, message, title)
	alert(C, message, title)

/proc/client_alert(client/C, message, title)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/_client_alert, C, message, title), 0)
