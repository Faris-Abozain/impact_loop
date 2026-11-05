Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "d:\StudioProjects\impact_loop\server"
WshShell.Run "node server.js", 0, False
