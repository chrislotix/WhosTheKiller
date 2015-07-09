-- Sound durations
-- 1 - 3
-- 2 - 7
-- 3 - 9
-- 4 - 5
-- 5 - 11
-- 6 - 9
-- 7 - 11
-- 8 - 10
-- 9 - 10
-- 10 - 5
-- 11 - 14
-- 12 - 6
function spook_lala( keys )
	local caster = keys.caster
	local target = keys.target
	local lala_modifier = keys.lala_modifier
	local ability = keys.ability
	local duration

	local sound = RandomInt(1, 12)

	if sound == 1 then
		duration = 3
	elseif sound == 4 or sound == 10 then
		duration = 5
	elseif sound == 2 then
		duration = 7
	elseif sound == 3 or sound == 6 then
		duration = 9
	elseif sound == 5 or sound == 7 then
		duration = 11
	elseif sound == 8 or sound == 9 then
		duration = 10
	elseif sound == 12 then
		duration = 6
	else
		duration = 14
	end

	if not target:HasModifier(lala_modifier) then
		ability:ApplyDataDrivenModifier(caster, target, lala_modifier, {duration = duration})

		local player = target:GetPlayerOwner()
		EmitSoundOnClient("Killer.Spook" .. sound, player)
	end
end