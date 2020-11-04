SWEP.Catergory = "Other"
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

function SWEP:Deploy(newOwner)
    local tool = TOOLS.list[player_manager.RunClass(self.Owner, "GetCurrentTool")]

    if tool.Deploy then
        tool:Deploy(newOwner)
    end
end

function SWEP:Holster(weapon)
    local tool = TOOLS.list[player_manager.RunClass(self.Owner, "GetCurrentTool")]

    if tool.Holster != nil then
        tool:Holster(weapon)
    end
end

function SWEP:OnDrop()
    local tool = TOOLS.list[player_manager.RunClass(self.Owner, "GetCurrentTool")]

    if tool.OnDrop != nil then
        tool:OnDrop()
    end
end

function SWEP:PrimaryAttack()
    local tool = TOOLS.list[player_manager.RunClass(self.Owner, "GetCurrentTool")]

    if tool.PrimaryAttack != nil then
        tool:PrimaryAttack(self.Owner)
    end
    
    self:EmitSound(tool.Primary.Sound)
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

    self:SetNextPrimaryFire(CurTime() + tool.Primary.Delay)
end

function SWEP:SecondaryAttack()
    local tool = TOOLS.list[player_manager.RunClass(self.Owner, "GetCurrentTool")]

    if tool.SecondaryAttack != nil then
        tool:SecondaryAttack(self.Owner)
    end

    self:EmitSound(tool.Secondary.Sound)
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

    self:SetNextSecondaryFire(CurTime() + tool.Secondary.Delay)
end