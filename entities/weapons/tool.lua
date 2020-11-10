SWEP.Category = "Other"
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.PrintName = "Tool"
SWEP.m_WeaponDeploySpeed = 1
SWEP.Author = "Arron David Nelson"
SWEP.Cotact = "NelsonArron@outlook.com"
SWEP.Purpose = "A tool weapon."
SWEP.Instructions = "Press F4 to open menu, and then click on the \"tools\" tab."
SWEP.ViewModel = "models/weapons/c_toolgun.mdl"
SWEP.ViewModelFlip = false;
SWEP.ViewModelFlip1 = false;
SWEP.ViewModelFlip2 = false;
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
SWEP.AutoSwitchFrom = false
SWEP.AutoSwitchTo = false
SWEP.Weight = 5
SWEP.BobScale = 1
SWEP.SwayScale = 1
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.RenderGroup = RENDERGROUP_OPAQUE
SWEP.Slot = 0
SWEP.SotPos = 0
--SWEP.SpeechBubbleLid = surface.GetTextureID("gui/speech_lid")
--SWEP.WepSelectIcon = surface.GetTextureID("weapons/swep")
SWEP.CSMuzzleFlashes = false
SWEP.CSMuzzleX = false

SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = ""
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false

SWEP.UseHands = true
SWEP.AccurateCrosshair = false
SWEP.DisableDuplicator = true
SWEP.ScriptedEntityType = "weapon"
SWEP.m_bPlayPickupSound = true
SWEP.LastOwner = nil

function SWEP:Deploy(newOwner)
    local current = player_manager.RunClass(self.Owner, "GetCurrentTool")
    if current == nil then
        return true
    end

    if current.Deploy then
        current:Deploy(newOwner)
    end
end

function SWEP:Holster(weapon)
    local current = player_manager.RunClass(self.Owner, "GetCurrentTool")
    if current == nil then
        return true
    end

    if current.Holster != nil then
        current:Holster(weapon)
    end

    return true
end

function SWEP:OnDrop()
    if self.LastOwner == nil then
        return
    end

    local current = player_manager.RunClass(self.Owner, "GetCurrentTool")
    if current == nil then
        return
    end

    if current.OnDrop != nil then
        current:OnDrop()
    end
end

function SWEP:Reload()
    local current = player_manager.RunClass(self.Owner, "GetCurrentTool")
    if current == nil then
        return
    end

    if current.Reload != nil then
        current:Reload()
    end
end

function SWEP:Equip(newOwner)
    if newOwner:IsPlayer() then
        self.LastOwner = newOwner
    end
end

function SWEP:PrimaryAttack()
    local current = player_manager.RunClass(self.Owner, "GetCurrentTool")
    if current == nil then
        return
    end

    if current.PrimaryAttack != nil then
        current:PrimaryAttack(self.Owner)
    end
    
    self:EmitSound(current.primary.sound)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation(PLAYER_ATTACK1)

	local tr = util.GetPlayerTrace(self.Owner)
	tr.mask = bit.bor(CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX)
    local trace = util.TraceLine(tr)

    if !trace.Hit || !IsFirstTimePredicted() then
        return
    end

    local effectdata = EffectData()
	effectdata:SetOrigin(trace.HitPos)
	effectdata:SetNormal(trace.HitNormal)
	effectdata:SetEntity(trace.Entity)
	effectdata:SetAttachment(trace.PhysicsBone)
	util.Effect("selection_indicator", effectdata)

	local effectdata = EffectData()
	effectdata:SetOrigin(trace.HitPos)
	effectdata:SetStart(self.Owner:GetShootPos())
	effectdata:SetAttachment(1)
	effectdata:SetEntity(self)
	util.Effect("ToolTracer", effectdata)

    self:SetNextPrimaryFire(CurTime() + current.primary.delay)
end

function SWEP:SecondaryAttack()
    local current = player_manager.RunClass(self.Owner, "GetCurrentTool")
    if current == nil then
        return
    end

    if current.SecondaryAttack != nil then
        current:SecondaryAttack(self.Owner)
    end

    self:EmitSound(current.secondary.sound)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation(PLAYER_ATTACK1)

	local tr = util.GetPlayerTrace(self.Owner)
	tr.mask = bit.bor(CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX)
    local trace = util.TraceLine(tr)

    if !trace.Hit || !IsFirstTimePredicted() then
        return
    end

    local effectdata = EffectData()
	effectdata:SetOrigin(trace.HitPos)
	effectdata:SetNormal(trace.HitNormal)
	effectdata:SetEntity(trace.Entity)
	effectdata:SetAttachment(trace.PhysicsBone)
	util.Effect("selection_indicator", effectdata)

	local effectdata = EffectData()
	effectdata:SetOrigin(trace.HitPos)
	effectdata:SetStart(self.Owner:GetShootPos())
	effectdata:SetAttachment(1)
	effectdata:SetEntity(self)
	util.Effect("ToolTracer", effectdata)

    self:SetNextSecondaryFire(CurTime() + current.secondary.delay)
end