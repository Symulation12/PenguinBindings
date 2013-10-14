PenguinBindings
===============

I was looking for a keybind addon for WoW 5.4, but couldn't find one that I liked(updated), so I'm making one.

	How to use:
	/pb bind to enter bind mode
	If you mouse over a spell/item that has a tooltip, the binding will appear in the tooltip(if it has one)
		While moused over icon:
			Mouse scroll up: Set binding for that spell/item
			Mouse scroll down: Clear binding for that spell/item(if it has one)
	If you open the macro screen and mouse over the picture in the lower window, it will print the current binding into the chat box
		While moused over picture:
			Mouse scroll up: Set binding
			Mouse scroll down: clear binding
	
	Commands:
		/pb clear (all|items|macros|spells)
			-Clears all bindings of that type on current profile
		/pb profile (list|create|delete|select) 
			-list: Lists all profiles
			-create (name): Creates a profile with the name, (name)
			-delete (number in list): Deletes the profile that co-responds to the number,(number in list)
			-select (number in list): Sets current profile to profile that co-responds to (number in list)
			-If not given arguments, it will print the current profile
		/pb save (which)
			-Saves current profile to (which==1) Global bindings profile; (which==2) Character bindings profile
			-If given no argument, it defaults to 2
		/pb bind
			-Toggles bind mode

ToDo:
	Binding Tests(Maybe)

	