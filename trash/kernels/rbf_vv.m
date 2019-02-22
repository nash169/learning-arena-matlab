function f = rbf_vv(x,y,sigma)
%RBF_KERNEL Summary of this function goes here
%   Detailed explanation goes here
v = (x-y);
[m,n] = size(v);

V = repmat(reshape(eye(n),1,[]),m,1);
f = V*exp(-vecnorm(v,2,2).^2/2/sigma^2);

end


