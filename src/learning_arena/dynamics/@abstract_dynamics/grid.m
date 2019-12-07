function grid = grid(obj)
%GRID Summary of this function goes here
%   Detailed explanation goes here
assert(obj.is_grid_, "Grid not present")
grid = obj.grid_;
end

