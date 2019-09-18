function v = repeat_block(a, blksize, rep_num, dir)
%REPEAT_BLOCK Summary of this function goes here
%   It works just for matrices not for tensors
if nargin < 4; dir = 1; end

[m,n] = size(a);

if dir == 1
    x = permute(reshape(a',blksize,n,m/blksize), [2 1 3]);
    y = repmat(x, rep_num, 1, 1);
    v = c_reshape(y, [], n);
elseif dir == 2
    x = reshape(a, m, blksize, n/blksize);
    y = repmat(x, 1, rep_num, 1);
    v = reshape(y, m, []);
end

end

