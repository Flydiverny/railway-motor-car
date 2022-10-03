shared = require "shared"

-- ignore some locomotives for dynamic motor cars
railway_motorcar_ignored = {
  "ee-super-locomotive", -- EditorExtensions
  "cargo_ship_engine", -- Cargo ships mod
  "boat_engine", -- Cargo ships mod
}

require "prototypes.motorcar"
require "prototypes.equipment"
