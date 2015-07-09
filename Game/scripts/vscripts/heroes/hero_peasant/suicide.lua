--[[Kills the caster]]
function suicide( keys )
	local caster = keys.caster

	caster:ForceKill(true)
	caster:SetTimeUntilRespawn(0.1)
end

function suicide_death( keys )
	local target = keys.unit
	local sound = keys.sound
	local player = target:GetPlayerOwner()
	local player_id = target:GetPlayerOwnerID()
	local player_name = PlayerResource:GetPlayerName(player_id)
	local team = target:GetTeamNumber()
	local color = nil

	-- Teams
	-- 2	Green
	-- 3	Red
	-- 6	Blue
	-- 7	Orange
	-- 8 	Purple
	-- 9	Cyan
	-- 10	Yellow
	-- 11	Brown
	-- 12	Magneta
	-- 13	Teal

	if team == 2 then
		color = "green"
	elseif team == 3 then
		color = "red"
	elseif team == 6 then
		color = "blue"
	elseif team == 7 then
		color = "orange"
	elseif team == 8 then
		color = "purple"
	elseif team == 9 then
		color = "cyan"
	elseif team == 10 then
		color = "yellow"
	elseif team == 11 then
		color = "brown"
	elseif team == 12 then
		color = "magneta"
	elseif team == 13 then
		color = "teal"
	end

	local line = ColorIt(player_name, color) .. " has been killed!"

	EmitGlobalSound(sound)

	GameRules:SendCustomMessage(line, 0, 0)
end