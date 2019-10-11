function f = calc_field(obj, x)
%CALC_FIELD Summary of this function goes here
%   Detailed explanation goes here

f = (obj.params_.a_matrix*(x-obj.params_.attractor)')';

end