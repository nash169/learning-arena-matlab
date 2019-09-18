function [f] = cosine_cross
%COSINE_CROSS Summary of this function goes here
%   Detailed explanation goes here
% Cross Distance-Velocities Cosine Kernel   
%         f = @(x,y,v) sum((repmat(x,size(y,1),1)-repelem(y,size(x,1),1)).*repelem(v,size(x,1),1),2)...
%             ./vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2)./vecnorm(repelem(v,size(x,1),1),2,2);

f = @(x,y,v) sum((repelem(x,size(y,1),1)-repmat(y,size(x,1),1)).*repmat(v,size(x,1),1),2)...
    ./vecnorm(repelem(x,size(y,1),1)-repmat(y,size(x,1),1),2,2)./vecnorm(repmat(v,size(x,1),1),2,2);

if nargout > 1
    error('Gradient not available yet.');
end

if nargout > 2
    error('Hessian not available yet.');
end

end

