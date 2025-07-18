-- SNAKE SKINS DATA V2.0
-- Complete server-side skin configurations with all categories
-- Includes: Featured, Classic, Premium, VIP Elite, Special, and Gamepasses

local SnakeSkinsData = {
	["Classic"] = {
		HeadColor = Color3.fromRGB(76, 217, 100),
		BodyColors = {
			Color3.fromRGB(60, 180, 80),
			Color3.fromRGB(80, 200, 100),
			Color3.fromRGB(100, 220, 120),
			Color3.fromRGB(80, 200, 100),
			Color3.fromRGB(60, 180, 80),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 1.5,
		GlowRange = 4,
		Price = 0,
		Description = "The original slither.io look!"
	},

	["Lava Red"] = {
		HeadColor = Color3.fromRGB(220, 50, 50),
		BodyColors = {
			Color3.fromRGB(180, 30, 30),
			Color3.fromRGB(200, 50, 50),
			Color3.fromRGB(220, 70, 70),
			Color3.fromRGB(200, 50, 50),
			Color3.fromRGB(180, 30, 30),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.0,
		GlowRange = 6,
		Price = 150,
		Description = "Burn with crimson fire!"
	},

	["Ocean Blue"] = {
		HeadColor = Color3.fromRGB(50, 150, 200),
		BodyColors = {
			Color3.fromRGB(30, 100, 180),
			Color3.fromRGB(40, 120, 190),
			Color3.fromRGB(50, 140, 200),
			Color3.fromRGB(40, 120, 190),
			Color3.fromRGB(30, 100, 180),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 1.8,
		GlowRange = 5,
		Price = 100,
		Description = "Deep as the ocean!"
	},

	["Cyberpunk"] = {
		HeadColor = Color3.fromRGB(0, 255, 150),
		BodyColors = {
			Color3.fromRGB(0, 200, 100),
			Color3.fromRGB(0, 225, 125),
			Color3.fromRGB(0, 255, 150),
			Color3.fromRGB(0, 225, 125),
			Color3.fromRGB(0, 200, 100),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.5,
		GlowRange = 8,
		Price = 2000,
		Description = "From the digital future!"
	},

	["Rainbow Prism"] = {
		HeadColor = Color3.fromRGB(255, 100, 255),
		BodyColors = {
			Color3.fromRGB(255, 0, 0),     -- Red
			Color3.fromRGB(255, 165, 0),   -- Orange
			Color3.fromRGB(255, 255, 0),   -- Yellow
			Color3.fromRGB(0, 255, 0),     -- Green
			Color3.fromRGB(0, 0, 255),     -- Blue
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.5,
		GlowRange = 8,
		Price = 2000,
		Description = "All colors of the rainbow!"
	},

	["Electric Purple"] = {
		HeadColor = Color3.fromRGB(255, 100, 200),
		BodyColors = {
			Color3.fromRGB(200, 50, 150),
			Color3.fromRGB(225, 75, 175),
			Color3.fromRGB(255, 100, 200),
			Color3.fromRGB(225, 75, 175),
			Color3.fromRGB(200, 50, 150),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.2,
		GlowRange = 7,
		Price = 500,
		Description = "Electric energy flows through you!"
	},

	["Dragon Lord"] = {
		HeadColor = Color3.fromRGB(255, 150, 0),
		BodyColors = {
			Color3.fromRGB(200, 100, 0),
			Color3.fromRGB(225, 125, 0),
			Color3.fromRGB(255, 150, 0),
			Color3.fromRGB(225, 125, 0),
			Color3.fromRGB(200, 100, 0),
		},
		HeadSize = Vector3.new(3.5, 3.5, 3.5),
		SegmentSize = Vector3.new(3, 3, 3),
		SegmentSpacing = 2.5,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 3.0,
		GlowRange = 10,
		Price = 5000,
		Description = "Breathe fire like a dragon!"
	},

	["Galaxy"] = {
		HeadColor = Color3.fromRGB(100, 50, 255),
		BodyColors = {
			Color3.fromRGB(50, 0, 150),
			Color3.fromRGB(75, 25, 200),
			Color3.fromRGB(100, 50, 255),
			Color3.fromRGB(75, 25, 200),
			Color3.fromRGB(50, 0, 150),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.0,
		GlowRange = 6,
		Price = 1500,
		Description = "Born from distant galaxies!"
	},

	-- VIP ELITE SKINS (Premium Robux skins)
	["VIP Diamond"] = {
		HeadColor = Color3.fromRGB(255, 255, 255),
		BodyColors = {
			Color3.fromRGB(230, 230, 230),
			Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(240, 240, 240),
			Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(230, 230, 230),
		},
		HeadSize = Vector3.new(3.5, 3.5, 3.5),
		SegmentSize = Vector3.new(3, 3, 3),
		SegmentSpacing = 2.5,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 3.5,
		GlowRange = 12,
		Price = nil, -- Robux only
		RobuxPrice = 299,
		Description = "Shine like a diamond! VIP exclusive skin.",
		VFX = {
			Type = "Sparkle",
			Color = Color3.fromRGB(255, 255, 255),
			ParticleTexture = "rbxasset://textures/particles/sparkles_main.dds"
		}
	},

	["VIP Inferno"] = {
		HeadColor = Color3.fromRGB(255, 100, 0),
		BodyColors = {
			Color3.fromRGB(200, 50, 0),
			Color3.fromRGB(255, 75, 0),
			Color3.fromRGB(255, 100, 0),
			Color3.fromRGB(255, 75, 0),
			Color3.fromRGB(200, 50, 0),
		},
		HeadSize = Vector3.new(3.5, 3.5, 3.5),
		SegmentSize = Vector3.new(3, 3, 3),
		SegmentSpacing = 2.5,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 4.0,
		GlowRange = 15,
		Price = nil, -- Robux only
		RobuxPrice = 399,
		Description = "Burn with the flames of VIP power!",
		VFX = {
			Type = "Fire",
			Color = Color3.fromRGB(255, 100, 0),
			SecondaryColor = Color3.fromRGB(255, 200, 0)
		}
	},

	["VIP Cosmic"] = {
		HeadColor = Color3.fromRGB(150, 100, 255),
		BodyColors = {
			Color3.fromRGB(100, 50, 200),
			Color3.fromRGB(125, 75, 225),
			Color3.fromRGB(150, 100, 255),
			Color3.fromRGB(125, 75, 225),
			Color3.fromRGB(100, 50, 200),
		},
		HeadSize = Vector3.new(3.5, 3.5, 3.5),
		SegmentSize = Vector3.new(3, 3, 3),
		SegmentSpacing = 2.5,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 4.5,
		GlowRange = 18,
		Price = nil, -- Robux only
		RobuxPrice = 499,
		Description = "Harness the power of the cosmos!",
		VFX = {
			Type = "Galaxy",
			Color = Color3.fromRGB(150, 100, 255),
			ParticleTexture = "rbxasset://textures/particles/sparkles_main.dds"
		}
	},

	-- FEATURED SKINS (Hot & Trending)
	["Arctic"] = {
		HeadColor = Color3.fromRGB(200, 240, 255),
		BodyColors = {
			Color3.fromRGB(150, 220, 255),
			Color3.fromRGB(175, 230, 255),
			Color3.fromRGB(200, 240, 255),
			Color3.fromRGB(175, 230, 255),
			Color3.fromRGB(150, 220, 255),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.0,
		GlowRange = 6,
		Price = 750,
		Description = "Ice cold and frosty!",
		VFX = {
			Type = "Frost",
			Color = Color3.fromRGB(200, 240, 255),
			ParticleTexture = "rbxasset://textures/particles/sparkles_main.dds"
		}
	},

	["Emerald"] = {
		HeadColor = Color3.fromRGB(50, 200, 50),
		BodyColors = {
			Color3.fromRGB(30, 150, 30),
			Color3.fromRGB(40, 175, 40),
			Color3.fromRGB(50, 200, 50),
			Color3.fromRGB(40, 175, 40),
			Color3.fromRGB(30, 150, 30),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.2,
		GlowRange = 7,
		Price = 1000,
		Description = "Precious green gemstone!"
	},

	["Void"] = {
		HeadColor = Color3.fromRGB(20, 20, 20),
		BodyColors = {
			Color3.fromRGB(10, 10, 10),
			Color3.fromRGB(15, 15, 15),
			Color3.fromRGB(20, 20, 20),
			Color3.fromRGB(15, 15, 15),
			Color3.fromRGB(10, 10, 10),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 1.0,
		GlowRange = 3,
		Price = 1250,
		Description = "Darkness incarnate!"
	},

	-- PREMIUM SKINS (Enhanced Effects)
	["Shadow"] = {
		HeadColor = Color3.fromRGB(50, 50, 50),
		BodyColors = {
			Color3.fromRGB(30, 30, 30),
			Color3.fromRGB(40, 40, 40),
			Color3.fromRGB(50, 50, 50),
			Color3.fromRGB(40, 40, 40),
			Color3.fromRGB(30, 30, 30),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 1.5,
		GlowRange = 5,
		Price = 800,
		Description = "Lurk in the shadows!"
	},

	-- SPECIAL SKINS (Limited Edition)
	["Golden"] = {
		HeadColor = Color3.fromRGB(255, 215, 0),
		BodyColors = {
			Color3.fromRGB(218, 165, 32),
			Color3.fromRGB(255, 200, 0),
			Color3.fromRGB(255, 215, 0),
			Color3.fromRGB(255, 200, 0),
			Color3.fromRGB(218, 165, 32),
		},
		HeadSize = Vector3.new(3.2, 3.2, 3.2),
		SegmentSize = Vector3.new(2.7, 2.7, 2.7),
		SegmentSpacing = 2.3,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 3.0,
		GlowRange = 10,
		Price = 10000,
		Description = "Pure gold luxury!",
		Special = true
	},

	-- GAMEPASS SKINS (Power-Ups & Boosts)
	["Lightning"] = {
		HeadColor = Color3.fromRGB(255, 255, 100),
		BodyColors = {
			Color3.fromRGB(200, 200, 50),
			Color3.fromRGB(225, 225, 75),
			Color3.fromRGB(255, 255, 100),
			Color3.fromRGB(225, 225, 75),
			Color3.fromRGB(200, 200, 50),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 3.0,
		GlowRange = 10,
		Price = nil, -- Gamepass only
		GamepassId = 123456789, -- Replace with actual gamepass ID
		Description = "Strike with lightning speed!",
		VFX = {
			Type = "Lightning",
			Color = Color3.fromRGB(255, 255, 100)
		}
	},
}

return SnakeSkinsData
