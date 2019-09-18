function [M,X,Y] = blk_matrix(V)
%BLK_MATRIX Summary of this function goes here
%   At the moment it works just for matrices not for tensors
[m,d] = size(V);

[X,~] = meshgrid(1:m,1:d);

Y = reshape(permute(reshape(X,d,d,[]), [2,1,3]),d,m);

M = sparse(X',Y',V,m,m,m*d);
end