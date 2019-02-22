function G = ColVelMatrix(X, V, f, norm)
%COLLI Summary of this function goes here
%   Detailed explanation goes here

if nargin < 4
    norm = false;
end

% [m,~] = size(X);
% V = repelem(V,m,1);
% D = DistanceVector(X,X);
% K = GramMatrix(X, X, f, norm);
% G = reshape(sum(D/5^2.*V,2),m,[]).*K;

gram_options = struct('norm', norm,...
                      'vv_rkhs', false);

dK = GramMatrix(f, gram_options, X, X);
X_vel = reshape(permute(repmat(V(:),1,size(V,1)),...
    [2,1]),...
    size(V,1),size(V,1),[]);
G = sum(X_vel.*dK,3);
end

