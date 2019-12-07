function M = blk_reshape(M, blk_dim, dir)
%BLK_RESHAPE Summary of this function goes here
%   Detailed explanation goes here
[m,n] = size(M);

if dir == 1
    M = reshape(permute(reshape(M', n, blk_dim, []), [1,3,2]), [], blk_dim)';
else
    M = reshape(permute(reshape(M, m, blk_dim, []), [1,3,2]), [], blk_dim);
end

end

