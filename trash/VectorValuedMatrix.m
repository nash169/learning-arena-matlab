function Kv = VectorValuedMatrix(K,n)
%VECTORVALUEDMATRIX Summary of this function goes here
%   Detailed explanation goes here
[m,z,d] = size(K);

if n ~= sqrt(d)
    if d == n
        K_temp = zeros(m,z,n^2);
        index = 1;
        for i = 1:n
            K_temp(:,:,index) = K(:,:,i);
            index = index + (n+1);
        end
        K = K_temp;
    else
        error('Vector dimension does not match matrix depth');
    end
end

Kv = zeros(m*n,z*n);

for i = 1:m
    for j = 1:z
        Kv((i-1)*n + 1 : i*n, (j-1)*n + 1 : j*n) = ...
            reshape(permute(reshape(K(i,j,:),1,n,[]),[1,3,2]),[],n);
    end
end

end

