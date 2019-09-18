function [f, df] = rbf_lyapunov(param)
%LYAPUNOVRBF Summary of this function goes here
%   Detailed explanation goes here
if ~isfield(param,'sigma')
    error('Define sigma');
end

if isfield(param, 'lyap_type')
    lyap_type = param.lyap_type;
else
    lyap_type = 'standard';
end

[k,dk,d2k] = rbf(param);

switch lyap_type
    case 'standard'
        f = @(x,y,v) k(x,y) + sum(dk(x,y).*repelem(v,size(x,1),1),2);
        
        if nargout > 1
            error('Gradient not available.');
        end
        
    case 'transpose'
        f = @(x,y,v) 0*k(x,y) + sum(-dk(x,y).*repmat(v,size(y,1),1),2);
        
        if nargout > 1
            df = @(x,y,v) dk(x,y) + ...
                 squeeze(sum(reshape(-d2k(x,y).*repmat(repmat(v,size(y,1),1),1,size(x,2)),size(x,1)*size(y,1),size(x,2),[]),2));
        end
        
    case 'asymmetric'
        f = @(x,y,v_x,v_y) k(x,y) + sum(-dk(x,y).* ...
                       (repmat(v_x, size(y,1),1).*(repmat((1:size(x,1))',size(y,1),1) <= repelem((1:size(y,1))',size(x,1),1)) + ...
                       repelem(v_y, size(x,1),1).*(repmat((1:size(x,1))',size(y,1),1) >= repelem((1:size(y,1))',size(x,1),1))) ...
                       ,2);
        if nargout > 1
            error('Gradient not available.');
        end
        
    otherwise
        error('Fottiti');     
end

if nargout > 2
    error('Hessian not available yet.');
end

end

