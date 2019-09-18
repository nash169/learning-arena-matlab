function A = outer_product(a,b)
%OUTER_PRODUCT Summary of this function goes here
%   Detailed explanation goes here

[m,d] = size(a);

assert(m==size(b,1), "Datasets have different length.")
assert(d==size(b,2), "Vectors have different dimension.")

V = repelem(a, 1, d).*repmat(b,1,d);

A = c_reshape(V, m*d, d);
end

