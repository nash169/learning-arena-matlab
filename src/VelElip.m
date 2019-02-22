function Q = VelElip(x,y,v,R,lambda)
%VELELIP Summary of this function goes here
%   Detailed explanation goes here
X = repmat(x,size(y,1),1);
Y = repelem(y,size(x,1),1);

V = repmat(v,size(y,1),1);
V_norm = V./vecnorm(repmat(v,size(y,1),1),2,2); %check 2 it might be size(x,2)

V_temp = V_norm;
V_temp(isnan(V_temp)) = 0;

V_norm(isnan(V_norm(:,1)),1) = 1;
V_norm(isnan(V_norm(:,2)),2) = 0;

V_p = V_norm*R;
dt = 0.1;
k = 2;

% ones(size(V,1),1)*1, ones(size(V,1),1)*2

D = sparse(1:size(V,2)*size(V,1),1:size(V,2)*size(V,1),...
           reshape([2*(vecnorm(V,2,2)*dt/k + lambda*exp(-vecnorm(V,2,2).^2/1e-5)).^2, ones(size(V_temp,1),1)*2*lambda^2]',[],1),... % exp(vecnorm(V_temp,2,2)/lambda) exp(-vecnorm(V,2,2)/lambda)
           size(V,2)*size(V,1),size(V,2)*size(V,1)); % 5 + 

U = BlkMatrix(V_norm,V_p);
S = U*D*U';

Q = sum((X-Y).*reshape(S\reshape((X-Y)',[],1),size(x,2),[])',2);

end

