function M = sparse_eye(V)
    %BLK_MATRIX Summary of this function goes here
    %   At the moment it works just for matrices not for tensors
    m = size(V, 1);

    index = 1:m;

    M = sparse(index, index, V);

end
