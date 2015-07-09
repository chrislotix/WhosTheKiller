-- Keep track of the people who voted correctly
function VotingDummy( keys )
	local caster = keys.caster
	local target = keys.target
	local player_owner = caster:GetPlayerOwner() -- Owning player of the voting dummy
	local player_id = caster:GetPlayerOwnerID() -- Player id of the voting dummy
	local player = target:GetPlayerOwner() -- Player of the target hero

	-- Set the player as voted
	player.voted = true

	-- Get the stone position
	local player_position = Entities:FindByName(nil, "stone" .. player_id)

	-- Set the target as the stone position
	target:SetOrigin(player_position:GetAbsOrigin())

	if player_owner.killer then
		player_owner.killer_table = player_owner.killer_table or {}
		table.insert(player_owner.killer_table, target)

		print(target:GetUnitName() .. "found the killer!")
	end

	--[[for _,v in ipairs(killer.player_table) do
		print("printing " .. tostring(v))
		if v.killer then
			v.killer_table = v.killer_table or {}

			table.insert(v.killer_table, target)

			
			break
		end
	end]]
end