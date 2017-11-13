require("projectile")


if ProjectileHandler == nil then
  print ( 'creating projectile manager' )
  ProjectileHandler = {}
  ProjectileHandler.__index = ProjectileHandler
end

function ProjectileHandler:new( o )
  o = o or {}
  setmetatable( o, ProjectileHandler )
  return o
end

PROJECTILE_THINK = 0.01

function ProjectileHandler:start()
  ProjectileHandler = self
  self.projectiles = {}
  GameRules:GetGameModeEntity():SetThink("ProjectileThink", self, "projectileThinker", PROJECTILE_THINK)
end

function ProjectileHandler:ProjectileThink()
	if not GameRules:IsGamePaused() then
		for id, projectile in pairs( self.projectiles ) do
			local status, err, ret = xpcall (projectile.ProjectileThink, debug.traceback, projectile)
			if not status then
				print(err)
				projectile:Remove()
			end
			projectile.aliveTime = (projectile.aliveTime or 0) + FrameTime()
			projectile.distanceTravelled = (projectile.distanceTravelled or 0) + projectile:GetVelocity():Length2D() * FrameTime()
			if (projectile.aliveTime and projectile.duration and projectile.aliveTime >= projectile.duration) or (projectile.distance and projectile.distanceTravelled and projectile.distance <= projectile.distanceTravelled) then
				local position = projectile:GetPosition()
				local radius = projectile:GetRadius()
				local caster = projectile:GetCaster()

				local status, err, ret = xpcall(projectile.hitBehavior, debug.traceback, projectile, nil, position)
				projectile:Remove()
			end
		end
	end
	return PROJECTILE_THINK
end

PROJECTILE_LINEAR = function(self)
	local position = self:GetPosition()
	local velocity = self:GetVelocity()
	if velocity.z > 0 then velocity.z = 0 end
	self:SetPosition( position + (velocity*FrameTime()) )
end

PROJECTILE_GRAVITY = 300

function ProjectileHandler:CreateProjectile(thinkBehavior, hitBehavior, data)
	local newProjectile = Projectile(thinkBehavior, hitBehavior, data)
	self.projectiles[newProjectile.uniqueProjectileID] = newProjectile
	return newProjectile
end

if not ProjectileHandler.projectiles then 
	ProjectileHandler:start() 
end