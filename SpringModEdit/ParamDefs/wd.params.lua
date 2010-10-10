-- $Id: wd.params.lua 3171 2008-11-06 09:06:29Z det $
local intMap = {
  beamTTL                  = true, -- wdTable -- beamTTL --
  beamlaser                = true, -- wdTable -- beamlaser --
  burst                    = true, -- wdTable -- burst --
  color                    = true, -- wdTable -- color --
  color2                   = true, -- wdTable -- color2 --
  flightTime               = true, -- wdTable -- flightTime --
  id                       = true, -- wdTable -- id --
  interceptType            = true, -- shTable -- interceptType --
  interceptedByShieldType  = true, -- wdTable -- interceptedByShieldType --
  interceptor              = true, -- wdTable -- interceptor --
  lodDistance              = true, -- wdTable -- lodDistance --
  numbounce                = true, -- wdTable -- numbounce --
  paralyzeTime             = true, -- wdTable -- paralyzeTime --
  projectiles              = true, -- wdTable -- projectiles --
  renderType               = true, -- wdTable -- renderType --
  shieldInterceptType      = true, -- wdTable -- shieldInterceptType --
  stages                   = true, -- wdTable -- stages --
  targetable               = true, -- wdTable -- targetable --
  visibleHitFrames         = true, -- shTable -- visibleHitFrames --
  visibleShieldHitFrames   = true, -- wdTable -- visibleShieldHitFrames --
}

local boolMap = {
  alwaysVisible            = true, -- wdTable -- alwaysVisible --
  avoidFeature             = true, -- wdTable -- avoidFeature --
  avoidFriendly            = true, -- wdTable -- avoidFriendly --
  ballistic                = true, -- wdTable -- ballistic --
  beamWeapon               = true, -- wdTable -- beamWeapon --
  beamburst                = true, -- wdTable -- beamburst --
  burnblow                 = true, -- wdTable -- burnblow --
  canattackground          = true, -- wdTable -- canattackground --
  collideFeature           = true, -- wdTable -- collideFeature --
  collideFriendly          = true, -- wdTable -- collideFriendly --
  commandfire              = true, -- wdTable -- commandfire --
  dropped                  = true, -- wdTable -- dropped --
  dynDamageInverted        = true, -- wdTable -- dynDamageInverted --
  exterior                 = true, -- shTable -- exterior --
  exteriorShield           = true, -- wdTable -- exteriorShield --
  fireSubmersed            = true, -- wdTable -- fireSubmersed --
  fixedLauncher            = true, -- wdTable -- fixedLauncher --
  groundbounce             = true, -- wdTable -- groundbounce --
  guidance                 = true, -- wdTable -- guidance --
  hardstop                 = true, -- wdTable -- hardstop --
  isShield                 = true, -- wdTable -- isShield --
  largeBeamLaser           = true, -- wdTable -- largeBeamLaser --
  lineOfSight              = true, -- wdTable -- lineOfSight --
  manualBombSettings       = true, -- wdTable -- manualBombSettings --
  noExplode                = true, -- wdTable -- noExplode --
  noGap                    = true, -- wdTable -- noGap --
  noSelfDamage             = true, -- wdTable -- noSelfDamage --
  paralyzer                = true, -- wdTable -- paralyzer --
  repulser                 = true, -- shTable -- repulser --
  selfprop                 = true, -- wdTable -- selfprop --
  shieldRepulser           = true, -- wdTable -- shieldRepulser --
  smart                    = true, -- shTable -- smart --
  smartShield              = true, -- wdTable -- smartShield --
  smokeTrail               = true, -- wdTable -- smokeTrail --
  soundTrigger             = true, -- wdTable -- soundTrigger --
  stockpile                = true, -- wdTable -- stockpile --
  submissile               = true, -- wdTable -- submissile --
  sweepfire                = true, -- wdTable -- sweepfire --
  toAirWeapon              = true, -- wdTable -- toAirWeapon --
  tracks                   = true, -- wdTable -- tracks --
  turret                   = true, -- wdTable -- turret --
  twoPhase                 = true, -- wdTable -- twoPhase --
  visible                  = true, -- shTable -- visible --
  visibleRepulse           = true, -- shTable -- visibleRepulse --
  visibleShield            = true, -- wdTable -- visibleShield --
  visibleShieldRepulse     = true, -- wdTable -- visibleShieldRepulse --
  vlaunch                  = true, -- wdTable -- vlaunch --
  waterWeapon              = true, -- wdTable -- waterWeapon --
  waterbounce              = true, -- wdTable -- waterbounce --
}

local floatMap = {
  accuracy                 = true, -- wdTable -- accuracy --
  alpha                    = true, -- shTable -- alpha --
  alphaDecay               = true, -- wdTable -- alphaDecay --
  areaOfEffect             = true, -- wdTable -- areaOfEffect --
  beamDecay                = true, -- wdTable -- beamDecay --
  beamTime                 = true, -- wdTable -- beamTime --
  bouncerebound            = true, -- wdTable -- bouncerebound --
  bounceslip               = true, -- wdTable -- bounceslip --
  burstrate                = true, -- wdTable -- burstrate --
  cameraShake              = true, -- wdTable -- cameraShake --
  collisionSize            = true, -- wdTable -- collisionSize --
  collisionSize            = true, -- wdTable -- collisionSize --
  collisionSize            = true, -- wdTable -- collisionSize --
  collisionSize            = true, -- wdTable -- collisionSize --
  coreThickness            = true, -- wdTable -- coreThickness --
  coverage                 = true, -- wdTable -- coverage --
  craterBoost              = true, -- wdTable -- craterBoost --
  craterMult               = true, -- wdTable -- craterMult --
  cylinderTargetting       = true, -- wdTable -- cylinderTargetting --
  dance                    = true, -- wdTable -- dance --
  default                  = true, -- dmgTable -- default --
  duration                 = true, -- wdTable -- duration --
  dynDamageExp             = true, -- wdTable -- dynDamageExp --
  dynDamageMin             = true, -- wdTable -- dynDamageMin --
  dynDamageRange           = true, -- wdTable -- dynDamageRange --
  edgeEffectiveness        = true, -- wdTable -- edgeEffectiveness --
  energyUse                = true, -- shTable -- energyUse --
  energypershot            = true, -- wdTable -- energypershot --
  explosionSpeed           = true, -- wdTable -- explosionSpeed --
  fallOffRate              = true, -- wdTable -- fallOffRate --
  fireStarter              = true, -- wdTable -- fireStarter --
  flameGfxTime             = true, -- wdTable -- flameGfxTime --
  force                    = true, -- shTable -- force --
  heightBoostFactor        = true, -- wdTable -- heightBoostFactor --
  heightMod                = true, -- wdTable -- heightMod --
  heightMod                = true, -- wdTable -- heightMod --
  heightMod                = true, -- wdTable -- heightMod --
  impulseBoost             = true, -- wdTable -- impulseBoost --
  impulseFactor            = true, -- wdTable -- impulseFactor --
  intensity                = true, -- wdTable -- intensity --
  intensity                = true, -- wdTable -- intensity --
  laserFlareSize           = true, -- wdTable -- laserFlareSize --
  leadBonus                = true, -- wdTable -- leadBonus --
  leadLimit                = true, -- wdTable -- leadLimit --
  maxSpeed                 = true, -- shTable -- maxSpeed --
  metalpershot             = true, -- wdTable -- metalpershot --
  minIntensity             = true, -- wdTable -- minIntensity --
  movingAccuracy           = true, -- wdTable -- movingAccuracy --
  myGravity                = true, -- wdTable -- myGravity --
  power                    = true, -- shTable -- power --
  powerRegen               = true, -- shTable -- powerRegen --
  powerRegenEnergy         = true, -- shTable -- powerRegenEnergy --
  predictBoost             = true, -- wdTable -- predictBoost --
  proximityPriority        = true, -- wdTable -- proximityPriority --
  pulseSpeed               = true, -- wdTable -- pulseSpeed --
  radius                   = true, -- shTable -- radius --
  range                    = true, -- wdTable -- range --
  reloadtime               = true, -- wdTable -- reloadtime --
  scrollSpeed              = true, -- wdTable -- scrollSpeed --
  separation               = true, -- wdTable -- separation --
  shieldAlpha              = true, -- wdTable -- shieldAlpha --
  shieldEnergyUse          = true, -- wdTable -- shieldEnergyUse --
  shieldForce              = true, -- wdTable -- shieldForce --
  shieldMaxSpeed           = true, -- wdTable -- shieldMaxSpeed --
  shieldPower              = true, -- wdTable -- shieldPower --
  shieldPowerRegen         = true, -- wdTable -- shieldPowerRegen --
  shieldPowerRegenEnergy   = true, -- wdTable -- shieldPowerRegenEnergy --
  shieldRadius             = true, -- wdTable -- shieldRadius --
  shieldStartingPower      = true, -- wdTable -- shieldStartingPower --
  size                     = true, -- wdTable -- size --
  size                     = true, -- wdTable -- size --
  size                     = true, -- wdTable -- size --
  sizeDecay                = true, -- wdTable -- sizeDecay --
  sizeGrowth               = true, -- wdTable -- sizeGrowth --
  sizeGrowth               = true, -- wdTable -- sizeGrowth --
  soundHitVolume           = true, -- wdTable -- soundHitVolume --
  soundStartVolume         = true, -- wdTable -- soundStartVolume --
  sprayAngle               = true, -- wdTable -- sprayAngle --
  startVelocity            = true, -- wdTable -- startVelocity --
  startingPower            = true, -- shTable -- startingPower --
  targetBorder             = true, -- wdTable -- targetBorder --
  targetMoveError          = true, -- wdTable -- targetMoveError --
  thickness                = true, -- wdTable -- thickness --
  thickness                = true, -- wdTable -- thickness --
  tileLength               = true, -- wdTable -- tileLength --
  tolerance                = true, -- wdTable -- tolerance --
  trajectoryHeight         = true, -- wdTable -- trajectoryHeight --
  turnRate                 = true, -- wdTable -- turnRate --
  weaponAcceleration       = true, -- wdTable -- weaponAcceleration --
  weaponTimer              = true, -- wdTable -- weaponTimer --
  weaponVelocity           = true, -- wdTable -- weaponVelocity --
  weaponVelocity           = true, -- wdTable -- weaponVelocity --
  wobble                   = true, -- wdTable -- wobble --
}

local float3Map = {
  badColor                 = true, -- shTable -- badColor --
  goodColor                = true, -- shTable -- goodColor --
  rgbColor                 = true, -- wdTable -- rgbColor --
  rgbColor                 = true, -- wdTable -- rgbColor --
  rgbColor                 = true, -- wdTable -- rgbColor --
  rgbColor2                = true, -- wdTable -- rgbColor2 --
  shieldBadColor           = true, -- wdTable -- shieldBadColor --
  shieldGoodColor          = true, -- wdTable -- shieldGoodColor --
}

local stringMap = {
  bounceExplosionGenerator = true, -- wdTable -- bounceExplosionGenerator --
  cegTag                   = true, -- wdTable -- cegTag --
  colormap                 = true, -- wdTable -- colormap --
  explosionGenerator       = true, -- wdTable -- explosionGenerator --
  filename                 = true, -- wdTable -- filename --
  model                    = true, -- wdTable -- model --
  name                     = true, -- wdTable -- name --
  soundHit                 = true, -- wdTable -- soundHit --
  soundStart               = true, -- wdTable -- soundStart --
  texture1                 = true, -- wdTable -- texture1 --
  texture2                 = true, -- wdTable -- texture2 --
  texture3                 = true, -- wdTable -- texture3 --
  texture4                 = true, -- wdTable -- texture4 --
  weaponType               = true, -- wdTable -- weaponType --
}

return {
  intMap    = intMap,
  boolMap   = boolMap,
  floatMap  = floatMap,
  float3Map = float3Map,
  stringMap = stringMap,
}

-- SubTable: 	const LuaTable rootTable = game->defsParser->GetRoot().SubTable("WeaponDefs");
-- SubTable: 		const LuaTable wdTable = rootTable.SubTable(wd.name);
-- SubTable: 	const LuaTable dmgTable = wdTable.SubTable("damage");
-- SubTable: 	LuaTable shTable = wdTable.SubTable("shield");
-- SubTable: 	LuaTable texTable = wdTable.SubTable("textures");
