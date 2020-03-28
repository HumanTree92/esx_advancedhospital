Config = {}
Config.Locale = 'en'

Config.DrawDistance = 100
Config.HospMarker = {Type = 1, r = 102, g = 102, b = 204, x = 2.5, y = 2.5, z = 1.0} -- Hospital Marker | Blue w/Medium Size
Config.BlipHospital = {Sprite = 403, Color = 2, Display = 2, Scale = 1.0}
Config.SurgMarker = {Type = 1, r = 102, g = 102, b = 204, x = 2.5, y = 2.5, z = 1.0} -- Surgery Marker | Blue w/Medium Size
Config.BlipSurgery = {Sprite = 403, Color = 0, Display = 2, Scale = 1.0}

Config.UseHospital = true -- Allows players to Heal Themselves
Config.HealingPrice = 100

Config.UseSurgeon = true -- Allows players to edit their Character
Config.SurgeryPrice = 3700

Config.EnablePeds = true -- Will show Peds on Markers

Config.HealingLocations = {
	Healing_Location1 = {
		Coords  = vector3(338.8, -1394.5, 31.5),
		Heading = 49.404
	},
	Healing_Location2 = {
		Coords  = vector3(-449.6, -340.8, 33.5),
		Heading = 82.17
	},
	Healing_Location3 = {
		Coords  = vector3(246.4, -1365.7, 28.6),
		Heading = 221.25
	},
	Healing_Location4 = {
		Coords  = vector3(-874.7, -307.5, 38.5),
		Heading = 350.95
	},
	Healing_Location5 = {
		Coords  = vector3(-496.9, -336.1, 33.5),
		Heading = 253.92
	},
	Healing_Location6 = {
		Coords  = vector3(1829.2, 3667.1, 33.2),
		Heading = 214.90
	},
	Healing_Location7 = {
		Coords  = vector3(-240.3, 6324.1, 31.4),
		Heading = 221.37
	},
	Healing_Location8 = { -- Pillbox Hill | Use if not using Pillbox Hill MLO
		Coords  = vector3(298.7, -584.6, 42.2),
		Heading = 75.49
	},
	--[[Healing_Location9 = { -- Pillbox Hill MLO (In Lobby)
		Coords  = vector3(347.0, -586.8, 27.7),
		Heading = 78.32
	},]]--
	Healing_Location10 = { -- Pillbox Hill MLO (Behind Counter)
		Coords  = vector3(338.5, -586.0, 27.7),
		Heading = 226.23
	}
}

Config.SurgeryLocations = {
	Surgery_Location1 = { -- esx_ambulancejob Default Hospital
		Coords  = vector3(260.3, -1343.6, 23.5),
		Heading = 257.66
	},
	Surgery_Location2 = { -- Pillbox Hill MLO (Behind Counter)
		Coords  = vector3(340.0, -581.9, 27.7),
		Heading = 281.39
	}
}
