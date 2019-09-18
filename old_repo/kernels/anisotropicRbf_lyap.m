function [f, df] = anisotropicRbf_lyap(param)
%ANISOTROPICRBF_LYAP Summary of this function goes here
%   Detailed explanation goes here

[k,dk,d2k] = anisotropicRbf_vel(param);

f = @(x,y,v,p) k(x,y,v,p) + sum(-dk(x,y,v,p).*repmat(v,size(y,1),1),2);
        
if nargout > 1
    df = @(x,y,v,p) dk(x,y,v,p) + ...
                  reshape(-d2k(x,y,v,p)*reshape(repmat(v,size(y,1),1)',[],1),size(x,2),[])';
end

if nargout > 2
    error('Hessian not available yet.');
end

end