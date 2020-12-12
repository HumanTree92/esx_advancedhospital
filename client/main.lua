local CurrentActionData = {}
local HasAlreadyEnteredMarker, IsInMainMenu, HasPaid, WasInSergMenu = false, false, false, false
local LastZone, CurrentAction, CurrentActionMsg
local connectedMedic = 0
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- Medic Connected
RegisterNetEvent('esx_advancedhospital:connectedMedic')
AddEventHandler('esx_advancedhospital:connectedMedic', function(_connectedMedic)
	connectedMedic = _connectedMedic
end)

-- Open Surgery Menu
function OpenSurgeryMenu()
	IsInMainMenu = true
	HasPaid = false

	TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu) -- Not 100% sure what the difference is between openSaveableMenu & openRestrictedMenu
		menu.close()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'surgery_confirm', {
			title = _U('buy_surgery', ESX.Math.GroupDigits(Config.SurgeryPrice)),
			align = GetConvar('esx_MenuAlign', 'top-left'),
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
						WasInSergMenu = true
						HasPaid = true
						menu.close()
					else
						ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin) 
						end)

						ESX.ShowNotification(_U('not_enough_money'))
						IsInMainMenu = false
						WasInSergMenu = true
						HasPaid = false
						menu.close()
					end
				end)
			else
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin) 
				end)

				IsInMainMenu = false
				WasInSergMenu = true
				HasPaid = false
				menu.close()
			end
		end, function(data, menu)
			IsInMainMenu = false
			WasInSergMenu = true
			menu.close()
			CurrentAction = 'surgery_menu'
			CurrentActionData = {}
		end)
	end, function(data, menu)
		IsInMainMenu = false
		WasInSergMenu = true
		menu.close()
		CurrentAction = 'surgery_menu'
		CurrentActionData = {}
	end, {
		'sex', 'face', 'skin', 'age_1', 'age_2', 'beard_1', 'beard_2', 'beard_3', 'beard_4', 'hair_1', 'hair_2', 'hair_color_1', 'hair_color_2',
		'eye_color', 'eyebrows_1', 'eyebrows_2', 'eyebrows_3', 'eyebrows_4', 'makeup_1', 'makeup_2', 'makeup_3', 'makeup_4', 'lipstick_1',
		'lipstick_2', 'lipstick_3', 'lipstick_4', 'blemishes_1', 'blemishes_2', 'blush_1', 'blush_2', 'blush_3', 'complexion_1', 'complexion_2',
		'sun_1', 'sun_2', 'moles_1', 'moles_2', 'chest_1', 'chest_2', 'chest_3', 'bodyb_1', 'bodyb_2'
		--'tshirt_1', 'tshirt_2', 'torso_1', 'torso_2', 'decals_1', 'decals_2', 'arms', 'arms_2', 'pants_1', 'pants_2', 'shoes_1', 'shoes_2'
	})
end

-- Entered Marker
AddEventHandler('esx_advancedhospital:hasEnteredMarker', function(zone)
	if zone == 'HealingLocations' then
		CurrentAction = 'healing_menu'
		CurrentActionMsg = _U('healing_menu', ESX.Math.GroupDigits(Config.HealingPrice))
		CurrentActionData = {}
	elseif zone == 'SurgeryLocations' then
		CurrentAction = 'surgery_menu'
		CurrentActionMsg = _U('surgery_menu', ESX.Math.GroupDigits(Config.SurgeryPrice))
		CurrentActionData = {}
	end
end)

-- Exited Marker
AddEventHandler('esx_advancedhospital:hasExitedMarker', function(zone)
	if not IsInMainMenu or IsInMainMenu then
		ESX.UI.Menu.CloseAll()
	end

	if not HasPaid and WasInSergMenu then
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin) 
			WasInSergMenu = false
		end)
	end

	CurrentAction = nil
end)

-- Resource Stop
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
		for k,v in pairs(Config.Healer) do
			for i=1, #v.Coords, 1 do
				local blip = AddBlipForCoord(v.Coords[i])

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
	end

	if Config.UseSurgeon and Config.UseSurgeonBlips then
		for k,v in pairs(Config.Surgery) do
			for i=1, #v.Coords, 1 do
				local blip = AddBlipForCoord(v.Coords[i])

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
	end
end)

-- Enter / Exit marker events & Draw Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep, currentZone = false, true

		if Config.UseHospital then
			for k,v in pairs(Config.Healer) do
				for i=1, #v.Coords, 1 do
					local distance = #(playerCoords - v.Coords[i])

					if distance < Config.DrawDistance then
						letSleep = false

						if Config.HospMarker.Type ~= -1 then
							DrawMarker(Config.HospMarker.Type, v.Coords[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.HospMarker.x, Config.HospMarker.y, Config.HospMarker.z, Config.HospMarker.r, Config.HospMarker.g, Config.HospMarker.b, 100, false, true, 2, false, nil, nil, false)
						end

						if distance < Config.HospMarker.x then
							isInMarker, currentZone = true, 'HealingLocations'
						end
					end
				end
			end
		end

		if Config.UseSurgeon then
			for k,v in pairs(Config.Surgery) do
				for i=1, #v.Coords, 1 do
					local distance = #(playerCoords - v.Coords[i])

					if distance < Config.DrawDistance then
						letSleep = false

						if Config.SurgMarker.Type ~= -1 then
							DrawMarker(Config.SurgMarker.Type, v.Coords[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.SurgMarker.x, Config.SurgMarker.y, Config.SurgMarker.z, Config.SurgMarker.r, Config.SurgMarker.g, Config.SurgMarker.b, 100, false, true, 2, false, nil, nil, false)
						end

						if distance < Config.SurgMarker.x then
							isInMarker, currentZone = true, 'SurgeryLocations'
						end
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
					if Config.MedicRequired <= connectedMedic then
						ESX.ShowNotification(_U('medic_online'))
					else
						ESX.TriggerServerCallback('esx_advancedhospital:payHealing', function(success)
							if success then
								SetEntityHealth(GetPlayerPed(-1), 200)
							else
								ESX.ShowNotification(_U('not_enough_money'))
							end
						end)
					end
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
