
if Grid == nil then
	Grid = class({})
	
end




function Grid:Init()

	self.ArrayMap = Grid:InitMap()
	self.VectorMap = {}
	self.PathTargets = Grid:FindPathTargets(0, 6)

end



function Grid:EvenSnapEntityToVectorGrid(location)

	return math.floor(location / 128) * 128 + 64

end

function Grid:OddSnapEntityToVectorGrid(location)

	return math.floor((location + 64) / 128) * 128

end

function Grid:EvenSnapEntityToArrayGrid(location)

	return math.floor(location / 128)

end

function Grid:OddSnapEntityToArrayGrid(location)

	return math.floor(location  / 128) + 19

end
print("Grid tile count: ", Grid.TILE_COUNT)
print("Grid tile count: ", Grid.TILE_COUNT)

function Grid:CenterEntityToGrid(location, parity)

	print("Grid:CenterEntityToGrid successfuly called!")

	if parity == "even" then


		location.x = Grid:EvenSnapEntityToVectorGrid(location.x)
		location.y = Grid:EvenSnapEntityToVectorGrid(location.y)

		print("DEBUG: Vector Coordinate X: ", location.x)
		print("DEBUG: Vector Coordinate Y: ", location.y) 
		
		return location

	elseif parity == "odd" then


		location.x = Grid:OddSnapEntityToVectorGrid(location.x)
		location.y = Grid:OddSnapEntityToVectorGrid(location.y)

		print("DEBUG: Vector Coordinate X: ", location.x)
		print("DEBUG: Vector Coordinate Y: ", location.y) 
		
		return location		

	end

	
	
end



function Grid:BlockNavigationSquare(location, parity)

	if parity == "even" then

		


		local x = Grid:EvenSnapEntityToArrayGrid(location.x)
		local y = Grid:EvenSnapEntityToArrayGrid(location.y)


		self.ArrayMap[y][x] = 1

		print("DEBUG: Grid Index X: ", x)
		print("DEBUG: Grid Index Y: ", y)

		

	elseif parity == "odd" then

		local x = Grid:OddSnapEntityToArrayGrid(location.x)
		local y = Grid:OddSnapEntityToArrayGrid(location.y)

		self.ArrayMap[y][x] = 1

		print("DEBUG: Grid Index X: ", x)
		print("DEBUG: Grid Index Y: ", y)

	end

end

function Grid:FreeNavigationSquare(location, parity)

	if parity == "even" then


		local x = Grid:EvenSnapEntityToArrayGrid(location.x)
		local y = Grid:EvenSnapEntityToArrayGrid(location.y)


		self.ArrayMap[y][x] = 0

		print("DEBUG: Grid Index X: ", x)
		print("DEBUG: Grid Index Y: ", y)

	elseif parity == "odd" then

		local x = Grid:OddSnapEntityToArrayGrid(location.x)
		local y = Grid:OddSnapEntityToArrayGrid(location.y)

		print("Coords to free.", x,y)

		self.ArrayMap[y][x] = 0

		print("DEBUG: Grid Index X: ", x)
		print("DEBUG: Grid Index Y: ", y)

	end
	



end

	
	
function Grid:CheckIfSquareIsBlocked(location, caster)

	
	local isGridBlocked = false
	local entity = Entities:FindInSphere(nil, Grid:CenterEntityToGrid(location, "odd"), 32)


	
	if entity then

		if entity:GetName() == "gem_blocker" then

			print("DEBUG: Found Entity: ", entity:GetName())
			caster:AddSpeechBubble(1, "Can't build outside of Arena!", 2, 0, -15)

			isGridBlocked = true

			return isGridBlocked


		elseif entity:GetName() == "gem_castle_blocker" then


			print("DEBUG: Found Entity: ", entity:GetName())
			caster:AddSpeechBubble(1, "Can't build around Gem base!", 2, 0, -15)

			isGridBlocked = true

			return isGridBlocked

		elseif entity:GetName() == "gem_spawn_blocker" then


			print("DEBUG: Found Entity: ", entity:GetName())
			caster:AddSpeechBubble(1, "Can't build around spawn area!", 2, 0, -15)

			isGridBlocked = true

			return isGridBlocked


		elseif entity:GetName() == "gem_path_blocker" then


			print("DEBUG: Found Entity: ", entity:GetName())
			caster:AddSpeechBubble(1, "Can't build on path checkpoint!", 2, 0, -15)

			isGridBlocked = true

			return isGridBlocked

		else

			caster:AddSpeechBubble(1, "Tile is already occupied!", 2, 0, -15)

			isGridBlocked = true

			return isGridBlocked

		end

	else

		isGridBlocked = false
		return isGridBlocked
		

	end
	
end



--///////////////////////////////////////////////////////////////////////////--
function Grid:InitMap()

	local map = {}
	
	for i = 1, 37 do
		
		map[i] = {}
		
		for j = 1, 37 do 
		
			map[i][j] = 0
		
		end
	
	end
	
	return map
	
end

function Grid:FindPathTargets(pathStart, pathEnd)

  local targets = {}
  local path


  for i = pathStart, pathEnd do

  path = Entities:FindByName(nil, tostring("path"..i)):GetAbsOrigin()
  table.insert(targets, path)

  end

  return targets

end

function Grid:IsPathTraversible()

 
  local walkable = 0


  local Grid = require ("jumper.grid") 
  local Pathfinder = require ("jumper.pathfinder")


  local grid = Grid(self.ArrayMap) 
  local myFinder = Pathfinder(grid, 'JPS', walkable)

  local pathCount = 0

  for i = 1,6 do 


    --to replace with function
    local startCoordX  = math.floor((self.PathTargets[i].x)     / 128) + 19
    local startCoordY  = math.floor((self.PathTargets[i].y)     / 128) + 19
    local endCoordX    = math.floor((self.PathTargets[i + 1].x) / 128) + 19
    local endCoordY    = math.floor((self.PathTargets[i + 1].y) / 128) + 19

 
    local path = myFinder:getPath(startCoordX, startCoordY, endCoordX, endCoordY)
  
    if path then

      --print("Path found!")

    else


      return false

    end

  end

  return true

end


function Grid:FindPath()

   for k, v in pairs(self.VectorMap) do

    self.VectorMap[k] = nil

  end


  local walkable = 0


  local Grid = require ("jumper.grid") 
  local Pathfinder = require ("jumper.pathfinder")


  local grid = Grid(self.ArrayMap) 
  local myFinder = Pathfinder(grid, 'JPS', walkable)

   
   for i = 1,6 do 

    local startCoordX     = math.floor((self.PathTargets[i].x)     / 128) + 19
    local startCoordY     = math.floor((self.PathTargets[i].y)     / 128) + 19 
    local endCoordX       = math.floor((self.PathTargets[i + 1].x) / 128) 	+ 	19 
    local endCoordY       = math.floor((self.PathTargets[i + 1].y) / 128) 	+ 	19 
 
    local path = myFinder:getPath(startCoordX, startCoordY, endCoordX, endCoordY)

      
    for node, count in path:nodes() do

		print("Printing node...", node)

      local vector = Vector(ConvertToVector(node:getX() - 19),ConvertToVector(node:getY() - 19), 192)
      table.insert(self.VectorMap, vector)

	  end

  end

end




function ConvertToVector(index)

	local vector = (index * 128)
	return vector


end


function Grid:ClearPath()

  for k, v in pairs(self.VectorMap) do

    self.VectorMap[k] = nil

  end

end

function Grid:MoveUnit(unitNPC)

	local unit = unitNPC
	unit.Step = 1

	Timers(function()

			if unit:IsNull() then

				print("DEBUG: Unit has been deleted!")
			
			else
	
				unit:SetThink(function() unit:MoveToPosition(self.VectorMap[unit.Step]) end)
				
				if (unit:GetAbsOrigin() - self.VectorMap[unit.Step]):Length2D() < 32 then

					unit.Step = unit.Step + 1

				end
    	
			return 0.1

			end

	end)
	

end










