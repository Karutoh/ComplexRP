WT_PRIMARY = 1
WT_SECONDARY = 2
WT_EQUIPMENT = 3
WT_MISC = 4

SWEP.Category = "Other"
SWEP.WeaponType = WT_PRIMARY
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.PrintName = "base"
SWEP.m_WeaponDeploySpeed = 1
SWEP.Author = "Arron David Nelson"
SWEP.Cotact = "NelsonArron@outlook.com"
SWEP.Purpose = "A tool weapon."
SWEP.Instructions = "weapon base"
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

--[[
function SWEP:Deploy(newOwner)
end

function SWEP:Holster(weapon)
end

function SWEP:OnDrop()
end

function SWEP:Reload()
end

function SWEP:PrimaryAttack()
end

function SWEP:Equip(newOwner)
end

function SWEP:SecondaryAttack()
end
]]--
function SWEP:GetWeaponType()
    return self.WeaponType
end