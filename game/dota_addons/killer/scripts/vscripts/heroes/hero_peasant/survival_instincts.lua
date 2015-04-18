--[[Increases the model size of the caster]]
function survival_instincts( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local size = ability:GetLevelSpecialValueFor("size", ability_level)

	caster:SetModelScale(size)
end

--[[Reverts the model size to the standard size]]
function survival_instincts_end( keys )
	local caster = keys.caster

	caster:SetModelScale(1.0)
end