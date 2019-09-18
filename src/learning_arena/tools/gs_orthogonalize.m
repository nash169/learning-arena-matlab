function [U, X, Y] = gs_orthogonalize(v)
%GS_ORTHOGONALIZE Summary of this function goes here
%   At the moment it works just for matrices not for tensors
[m,d] = size(v);

V = [reshape(v',[],1), rand(m*d,d-1)];

[U, X, Y] = blk_matrix(V);

[U,~] = qr(U);
U = -U;
end

