function [f, df, d2f] = anisotropicRbf_vel(param)
%ANISOTROPICRBF_VEL Summary of this function goes here
%   Detailed explanation goes here
% Non-Stationary Velocity Covariance Oriented Gaussian Kernel
if ~isfield(param,'rot')
    error('Define rotation matrix');
end
if ~isfield(param,'lambda')
    error('Define lambda');
end

if ~isfield(param,'sigma')
    error('Define sigma');
end

f = @(x,y,v,p)...
    exp(-sum((repmat(x,size(y,1),1)-repelem(y,size(x,1),1)) ...
        .*reshape(VelElip2(repmat(v,size(y,1),1),param.rot,repmat(p,size(y,1),1),param.sigma) ...
        \reshape((repmat(x,size(y,1),1)-repelem(y,size(x,1),1))',[],1),size(x,2),[])',2));

if nargout > 1
    df = @(x,y,v,p)...
         2*reshape(VelElip2(repmat(v,size(y,1),1),param.rot,repmat(p,size(y,1),1),param.sigma) ...
         \reshape((repmat(x,size(y,1),1)-repelem(y,size(x,1),1))',[],1),size(x,2),[])' ...
         .* f(x,y,v,p);
end

if nargout > 2
    d2f = @(x,y,v,p)...
          CalcHess2(x,y,v,param.rot,p,param.sigma).*repelem(f(x,y,v,p),size(x,2),1);
end

end

function S = VelElip2(V,R,P,sigma)
%VELELIP Summary of this function goes here
%   Detailed explanation goes here

V_norm = V./vecnorm(V,2,2); %check 2 it might be size(x,2)
V_max = V/max(vecnorm(V,2,2));

V_temp = V_norm;
V_temp(isnan(V_temp)) = 0;

V_norm(isnan(V_norm(:,1)),1) = 1;
V_norm(isnan(V_norm(:,2)),2) = 0;

V_p = V_norm*R;
dt = 0.1;
k = 0.005; %.03

a = 5;
b = 10;

% D = sparse(1:size(V,2)*size(V,1),1:size(V,2)*size(V,1),...
%            reshape([ones(size(V_temp,1),1)*2*sigma^2, ones(size(V_temp,1),1)*20*sigma^2]',[],1),... % 2*(P*dt/k + sigma*exp(-vecnorm(V_max,2,2).^2/1e-5)).^2
%            size(V,2)*size(V,1),size(V,2)*size(V,1));
       
D = sparse(1:size(V,2)*size(V,1),1:size(V,2)*size(V,1),...
           reshape([a*vecnorm(V,2,2), b*vecnorm(V,2,2)]',[],1),... % 2*(P*dt/k + sigma*exp(-vecnorm(V_max,2,2).^2/1e-5)).^2
           size(V,2)*size(V,1),size(V,2)*size(V,1));

U = BlkMatrix(V_norm,V_p);
S = U*D*U';

end

function T = outerProd(x,y)
X = repmat(x,size(y,1),1);
Y = repelem(y,size(x,1),1);
T = repelem(X-Y,1,size(x,2)).*repmat(X-Y,1,size(x,2));
end

function H = CalcHess2(x,y,v,R,p,sigma)
tic;
S = VelElip2(repmat(v,size(y,1),1),R,repmat(p,size(y,1),1),sigma)^-1;
toc;
H = -2*S + 4*S*BlkMatrix(outerProd(x,y))*S;
full(H)
end
