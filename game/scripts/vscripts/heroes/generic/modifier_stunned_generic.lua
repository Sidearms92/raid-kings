modifier_stunned_generic = modifier_stunned_generic or class({})

if IsServer() then
	function modifier_stunned_generic:OnCreated(kv)
		if kv.delay == nil or toboolean(kv.delay) == true then
			self.delay = true
			self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
		end
	end
	
	function modifier_stunned_generic:OnDestroy()
		if self.delay then self:GetAbility():EndDelayedCooldown() end
	end
end

function modifier_stunned_generic:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_stunned_generic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_stunned_generic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_stunned_generic:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_stunned_generic:IsPurgable()
	return true
end

function modifier_stunned_generic:IsStunDebuff()
	return true
end

function modifier_stunned_generic:IsPurgeException()
	return true
end