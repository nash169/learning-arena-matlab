function [A] = blk_revert(A,d)
%BLK_REVERT Summary of this function goes here
%   Detailed explanation goes here

m = size(A,1);

[X,~] = meshgrid(1:m,1:d);

Y = reshape(permute(reshape(X,d,d,[]), [2,1,3]),d,m);

A = full(c_reshape(A(sub2ind(size(A),X(:),Y(:))), [], d)); % d^2

end

