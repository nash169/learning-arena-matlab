function v = matrix_prod(a,b)
%MATRIX_PROD Summary of this function goes here
% It doesn't work tensor

[~, d] = size(a);

x = repelem(a,d,1);
y = repeat_block(matrix_transpose(b),d,d,1);
v = c_reshape(sum(x.*y,2), [], d);

% x = c_reshape(sum(repeat_block(a,d,d,1).*repelem(matrix_transpose(b),d,1),2),[],d);

end

