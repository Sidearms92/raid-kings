sylph_rapid_fire = sylph_rapid_fire or class({})

function sylph_rapid_fire:OnSpellStart()
	self.caster = self:GetCaster()
	local as_mult = (1 + self.caster:GetIncreasedAttackSpeed())
	if as_mult > 14 then as_mult = 14 end
	local arrowAmount = math.ceil(self:GetSpecialValueFor("min_arrows") * as_mult)
	local fireDelay = self:GetSpecialValueFor("fire_duration") / arrowAmount
	local firesPerVolley = math.max(1,math.floor(FrameTime()/fireDelay))
	if fireDelay > FrameTime() then fireDelay = FrameTime() end
	local spread = self:GetTalentSpecialValueFor("spread_rad")
	local minspread = self:GetTalentSpecialValueFor("min_spread")
	local spreadDiff = (spread - minspread) * (self.caster:GetIdealSpeed()-self.caster:GetBaseMoveSpeed())/580
	print(spreadDiff)
	spread = math.max(minspread, spread - spreadDiff)
	
	self.arrows = self.arrows or 0
	self.arrows = self.arrows + arrowAmount
	Timers:CreateTimer(0, function()
		local fDir = self.caster:GetForwardVector()
		local rndAng = math.rad(RandomInt(-spread/2, spread/2))
		local dirX = fDir.x * math.cos(rndAng) - fDir.y * math.sin(rndAng); 
		local dirY = fDir.x * math.sin(rndAng) + fDir.y * math.cos(rndAng);
		self.caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, as_mult)
		EmitSoundOn( "Ability.Powershot", self.caster)
		for i = 1, firesPerVolley do
			self:ShootArrow( Vector( dirX, dirY, 0 ) )
			if not self.arrows or self.arrows < 1 then
				self.arrows = nil
				return nil
			end
		end
		return fireDelay
	end)
end

function sylph_rapid_fire:ShootArrow( vDir )
	if not self.arrows then return end
	if self.arrows >= 1 then
		local projectileTable = {
			Ability = self,
			EffectName = "particles/heroes/sylph/sylph_rapid_fire.vpcf",
			vSpawnOrigin = self.caster:GetAbsOrigin() + vDir * 128,
			fDistance = self.caster:GetAttackRange(),
			fStartRadius = 200,
			fEndRadius = 200,
			Source = self:GetCaster(),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bDeleteOnHit = false,
			vVelocity = vDir * self.caster:GetProjectileSpeed(),
		}
		ProjectileManager:CreateLinearProjectile( projectileTable )
		self.arrows = self.arrows - 1
	end
end

function sylph_rapid_fire:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		self.caster:PerformAttack( hTarget, true, true, true, true, false, false, false )
		EmitSoundOn("Hero_Windrunner.PowershotDamage", hTarget)
		return true
	end
end


LinkLuaModifier( "modifier_sylph_rapid_fire_talent_1", "heroes/sylph/sylph_rapid_fire.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_rapid_fire_talent_1 = modifier_sylph_rapid_fire_talent_1 or class({})

function modifier_sylph_rapid_fire_talent_1:IsHidden()
	return true
end

function modifier_sylph_rapid_fire_talent_1:RemoveOnDeath()
	return false
end