function v = matrix_transpose(a)
%M Summary of this function goes here
%   Detailed explanation goes here
% It should work also for tensors but I'm not sure...
[m,d] = size(a);
x = permute(reshape(a',d,d,m/d), [1 2 3]);
v = c_reshape(x, [], d);
% y = permute(a, [2 1 3:ndims(a)]);
% 
% in_cell = [num2cell(ones(1,ndims(a))*d), d];
% z = reshape(y, in_cell{:});
% 
% in_cell = [m, num2cell(ones(1,ndims(a)-1)*d)];
% v = c_reshape(z, in_cell{:});
end

