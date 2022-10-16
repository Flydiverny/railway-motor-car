local flib = require "__flib__.data-util"
local utils = require("prototypes.utils")

function merge_table(table1, table2)
	for _, value in ipairs(table2) do
		table1[#table1+1] = value
	end
	return table1
end

-- check for modded locomotives and create equipment & entity for them
for prototype_name, prototype in pairs(data.raw["locomotive"]) do
  if prototype_name ~= "locomotive" and not shared.is_a_motorcar(prototype_name)
    and not utils.table_contains(railway_motorcar_ignored, prototype_name)
  then
    -- use item with the same name
    local prototype_item = data.raw["item-with-entity-data"][prototype_name]
    -- search item otherwise
    if not prototype_item or prototype_item.place_result ~= prototype_name then
      for _, rec in pairs(data.raw["item-with-entity-data"]) do
        if rec.place_result == prototype_name then
          prototype_item = rec
          break
        end
      end
    end

    -- cannot create the recipe without the item
    if prototype_item then
      log("Creating motorcar for " .. prototype_name)

      local name = shared.motorcar_prefix .. prototype_name
      local motorcar = utils.create_entity(prototype_name, name, true)
      motorcar.localised_name = merge_table(merge_table({"", {"entity-name." .. shared.base_motorcar}, " ("}, {prototype_item.localised_name or {"entity-name." .. prototype_name}}), {")"})
      data:extend {motorcar}

      local equipment = utils.create_equipment(name, true)
      equipment.localised_name = motorcar.localised_name

      local item = utils.create_item(name)
      item.localised_name = motorcar.localised_name
      item.localised_description = {"item-description." .. shared.base_motorcar}
      local motorcar_icon = {
        {
          icon = shared.root .. "/graphics/equipment/motorcar_overlay.png",
          icon_size = 64,
          tint = {r=1, g=1, b=1, a=1}
        }
      }
      -- Generate icons with overlay
      item.icons = flib.create_icons(prototype, motorcar_icon) or motorcar_icon
      item.icon_size = nil

      local recipe = {
        type = "recipe",
        name = name,
        localised_name = motorcar.localised_name,
        normal = {
          enabled = false,
          ingredients = {
            {"advanced-circuit", 10},
            {prototype_item.name, 1},
          },
          result = name,
          energy_consumption = 4,
        },
        order = "g-h-a"
      }

      -- add recipe to the nuclear tech
      local technology = data.raw["technology"][shared.nuclear_motorcar]
      table.insert(technology.effects, {type = "unlock-recipe", recipe = name})

      data:extend {equipment, item, recipe, technology}
    else
      log("No item found to create " .. prototype_name .. ", cannot use as a motorcar")
    end
  end
end
