local CurrentActionData = {}
local HasAlreadyEnteredMarker, IsInMainMenu, HasPaid = false, false, false
local LastZone, CurrentAction, CurrentActionMsg
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- Open Healing Menu
function OpenHealingMenu()
	IsInMainMenu = true

	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'healing_confirm', {
		title = _U('buy_health', ESX.Math.GroupDigits(Config.HealingPrice)),
		align = Config.MenuAlign,
		elements = {
			{label = _U('no'), value = 'no'},
			{label = _U('yes'), value = 'yes'}
	}}, function(data, menu)
		if data.current.value == 'yes' then
			ESX.TriggerServerCallback('esx_advancedhospital:payHealing', function(success)
				if success then
					IsInMainMenu = false
					menu.close()
					SetEntityHealth(GetPlayerPed(-1), 200)
				else
					IsInMainMenu = false
					ESX.ShowNotification(_U('not_enough_money'))
					menu.close()
				end
			end)
		else
			IsInMainMenu = false
			menu.close()
		end
	end, function(data, menu)
		IsInMainMenu = false
		menu.close()

		CurrentAction = 'healing_menu'
		CurrentActionMsg = _U('healing_menu')
		CurrentActionData = {}
	end)
end

-- Open Surgery Menu
function OpenSurgeryMenu()
	IsInMainMenu = true
	HasPaid = false

	TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu) -- Not 100% sure what the difference is between openSaveableMenu & openRestrictedMenu
		menu.close()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'surgery_confirm', {
			title = _U('buy_surgery', ESX.Math.GroupDigits(Config.SurgeryPrice)),
			align = Config.MenuAlign,
			elements = {
				{label = _U('no'), value = 'no'},
				{label = _U('yes'), value = 'yes'}
		}}, function(data, menu)
			menu.close()

			if data.current.value == 'yes' then
				ESX.TriggerServerCallback('esx_advancedhospital:paySurgery', function(success)
					if success then
						TriggerEvent('skinchanger:getSkin', function(skin)
							TriggerServerEvent('esx_skin:save', skin)
						end)

						IsInMainMenu = false
						HasPaid = true
						menu.close()
					else
						ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin) 
						end)

						ESX.ShowNotification(_U('not_enough_money'))
						IsInMainMenu = false
						HasPaid = false
						menu.close()
					end
				end)
			else
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin) 
				end)

				IsInMainMenu = false
				HasPaid = false
				menu.close()
			end
		end, function(data, menu)
			IsInMainMenu = false
			menu.close()

			CurrentAction = 'surgery_menu'
			CurrentActionMsg = _U('surgery_menu')
			CurrentActionData = {}
		end)
	end, function(data, menu)
		IsInMainMenu = false
		menu.close()

		CurrentAction = 'surgery_menu'
		CurrentActionMsg = _U('surgery_menu')
		CurrentActionData = {}
	end)
end

-- Entered Marker
AddEventHandler('esx_advancedhospital:hasEnteredMarker', function(zone)
	if zone == 'HealingLocation' then
		CurrentAction = 'healing_menu'
		CurrentActionMsg = _U('healing_menu')
		CurrentActionData = {}
	elseif zone == 'SurgeryLocation' then
		CurrentAction = 'surgery_menu'
		CurrentActionMsg = _U('surgery_menu')
		CurrentActionData = {}
	end
end)

-- Exited Marker
AddEventHandler('esx_advancedhospital:hasExitedMarker', function(zone)
	if not IsInMainMenu or IsInMainMenu then
		ESX.UI.Menu.CloseAll()
	end

	if not HasPaid then
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin) 
		end)
	end

	CurrentAction = nil
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if IsInMainMenu then
			ESX.UI.Menu.CloseAll()
		end
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	if Config.UseHospital and Config.UseHospitalBlips then
		for k,v in pairs(Config.HealingLocations) do
			local blip = AddBlipForCoord(v.Coords)

			SetBlipSprite (blip, Config.BlipHospital.Sprite)
			SetBlipColour (blip, Config.BlipHospital.Color)
			SetBlipDisplay(blip, Config.BlipHospital.Display)
			SetBlipScale  (blip, Config.BlipHospital.Scale)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName(_U('healing_blip'))
			EndTextCommandSetBlipName(blip)
		end
	end

	if Config.UseSurgeon and Config.UseSurgeonBlips then
		for k,v in pairs(Config.SurgeryLocations) do
			local blip = AddBlipForCoord(v.Coords)

			SetBlipSprite (blip, Config.BlipSurgery.Sprite)
			SetBlipColour (blip, Config.BlipSurgery.Color)
			SetBlipDisplay(blip, Config.BlipSurgery.Display)
			SetBlipScale  (blip, Config.BlipSurgery.Scale)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName(_U('surgery_blip'))
			EndTextCommandSetBlipName(blip)
		end
	end
end)

-- Create Peds
Citizen.CreateThread(function()
	if Config.EnablePeds then
		if Config.UseHospital then
			RequestModel(GetHashKey("s_m_m_doctor_01"))

			while not HasModelLoaded(GetHashKey("s_m_m_doctor_01")) do
				Wait(1)
			end

			for k,v in pairs(Config.HealingLocations) do
				local npc = CreatePed(4, 0xd47303ac, v.Coords, v.Heading, false, true)

				SetEntityHeading(npc, v.Heading)
				FreezeEntityPosition(npc, true)
				SetEntityInvincible(npc, true)
				SetBlockingOfNonTemporaryEvents(npc, true)
			end
		end

		if Config.UseSurgeon then
			RequestModel(GetHashKey("s_m_y_autopsy_01"))

			while not HasModelLoaded(GetHashKey("s_m_y_autopsy_01")) do
				Wait(1)
			end

			for k,v in pairs(Config.SurgeryLocations) do
				local npc = CreatePed(4, 0xB2273D4E, v.Coords, v.Heading, false, true)

				SetEntityHeading(npc, v.Heading)
				FreezeEntityPosition(npc, true)
				SetEntityInvincible(npc, true)
				SetBlockingOfNonTemporaryEvents(npc, true)
			end
		end
	end
end)

-- Enter / Exit marker events & Draw Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep, currentZone = false, true

		if Config.UseHospital then
			for k,v in pairs(Config.HealingLocations) do
				local distance = #(playerCoords - v.Coords)

				if distance < Config.DrawDistance then
					letSleep = false

					if Config.HospMarker.Type ~= -1 then
						DrawMarker(Config.HospMarker.Type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.HospMarker.x, Config.HospMarker.y, Config.HospMarker.z, Config.HospMarker.r, Config.HospMarker.g, Config.HospMarker.b, 100, false, true, 2, false, nil, nil, false)
					end

					if distance < Config.HospMarker.x then
						isInMarker, currentZone = true, 'HealingLocation'
					end
				end
			end
		end

		if Config.UseSurgeon then
			for k,v in pairs(Config.SurgeryLocations) do
				local distance = #(playerCoords - v.Coords)

				if distance < Config.DrawDistance then
					letSleep = false

					if Config.SurgMarker.Type ~= -1 then
						DrawMarker(Config.SurgMarker.Type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.SurgMarker.x, Config.SurgMarker.y, Config.SurgMarker.z, Config.SurgMarker.r, Config.SurgMarker.g, Config.SurgMarker.b, 100, false, true, 2, false, nil, nil, false)
					end

					if distance < Config.SurgMarker.x then
						isInMarker, currentZone = true, 'SurgeryLocation'
					end
				end
			end
		end
		
		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker, LastZone = true, currentZone
			LastZone = currentZone
			TriggerEvent('esx_advancedhospital:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_advancedhospital:hasExitedMarker', LastZone)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'healing_menu' then
					OpenHealingMenu()
				elseif CurrentAction == 'surgery_menu' then
					OpenSurgeryMenu()
				end

				CurrentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)
