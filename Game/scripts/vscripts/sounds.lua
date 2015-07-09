
function mine_sound( keys )
	local activator = keys.activator
	local player = activator:GetPlayerOwner()

	EmitSoundOnClient("Killer.Mine_one", player)
end

function graveyard_sound( keys )
	local activator = keys.activator
	local player = activator:GetPlayerOwner()

	EmitSoundOnClient("Killer.Graveyard", player)
end

function stump_sound( keys )
	local activator = keys.activator
	local player = activator:GetPlayerOwner() 

	EmitSoundOnClient("Killer.Stumps", player)
end

function camp_sound( keys )
	local activator = keys.activator
	local player = activator:GetPlayerOwner() 

	EmitSoundOnClient("Killer.Camp_coins", player)
end

function small_boat_sound( keys )
	local activator = keys.activator
	local player = activator:GetPlayerOwner() 

	EmitSoundOnClient("Killer.Small_boat", player)
end

function big_boat_sound( keys )
	local activator = keys.activator
	local player = activator:GetPlayerOwner() 

	EmitSoundOnClient("Killer.Big_boat", player)
end

function forest_run_sound( keys )
	local activator = keys.activator
	local player = activator:GetPlayerOwner() 

	EmitSoundOnClient("Killer.Forest_run", player)
end