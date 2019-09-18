function M = BlkMatrix(varargin)
%BLKMATRIX Summary of this function goes here
%   This function automatically creates a block diagonal matrix starting
%   from an array list ordered in the following way.
%   For 2x2 3-blocks diagonal matrix:
%   (3x4) matrix B = [a1, a2, a3 , a4;
%                     b1, b2, b3 , b4;
%                     c1, c2, c3 , c4]
%   M = BlkMatrix(B) = [a1, a2,  0,  0,  0,  0;
%                       a3, a4,  0,  0,  0,  0;
%                        0,  0, b1, b2,  0,  0; 
%                        0,  0, b3, b4,  0,  0;
%                        0,  0,  0,  0, c1, c2;
%                        0,  0,  0,  0, c3, c4]
% For 3x3 blocks
% [a1, a2, a3, a4, a5, a6, a7, a8, a9]
% to
% [a1, a2, a3;
%  a4, a5, a6;
%  a7, a8, a9;]
% and so on.


if length(varargin) == 1
    d = sqrt(size(varargin{1},2));
    V = reshape(reshape(varargin{1}',1,[])',d,[])';
else
    d = length(varargin);
    V = reshape(reshape(cat(1,varargin{:})',1,[]),[],d);
end

m = size(V,1);

[~, Y] = meshgrid(1:d,1:m);
% X = X + repelem((0:d:m-d+1)',d,1);


X = reshape(permute(reshape(Y',d,d,[]),[2,1,3]),d,m)';

M = sparse(reshape(Y,[],1), reshape(X,[],1), reshape(V,[],1), m, m);
end