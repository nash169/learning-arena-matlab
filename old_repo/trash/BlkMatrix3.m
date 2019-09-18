function M = BlkMatrix2(x,y)
%BLKMATRIX2 Summary of this function goes here
%   Detailed explanation goes here

A = mat2cell([reshape(x',1,[])', reshape(y',1,[])'], repmat(size(x,2),1,size(x,1)), size(x,2));
M = sparse(blkdiag(A{:}));

end
