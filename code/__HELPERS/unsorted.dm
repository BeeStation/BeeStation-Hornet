//here lies unsorted.dm, bane of many coders, pain of lots of maintainers

//* 2005? / + 2022

/// identical alert proc, but without waiting for user input. It's useful when you shouldn't set your proc `waitfor = 0`
/proc/client_alert(client/C, message, title)
	set waitfor = 0
	alert(C, message, title)
