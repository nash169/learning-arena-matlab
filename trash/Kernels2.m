function [f, varargout] = Kernels2(type, param)
%KERNELS Summary of this function goes here
%   Detailed explanation goes here

switch type
    case 'gauss'
        % par{1} = sigma;
        if ~isfield(param,'sigma')
            error('Define sigma');
        end
        
        f = @(x,y) exp(-vecnorm(x-y,2,2).^2/2/param.sigma^2);
        
        % Gradient
        if nargout > 1
            varargout{1} = @(x,y) (x-y)/param.sigma^2.*f(x,y);    
        end
        
        % Hessian
        if nargout > 2          
            varargout{2} = @(x,y) (-repmat(reshape(eye(size(x,2)),1,[]),size(x,1),1)...
                                 +(repelem(x-y,1,size(x,2)).*repmat(x-y,1,size(x,2)))/param.sigma^2)...
                                  /param.sigma^2.*f(x,y);
        end
        
    case 'gauss_compact'
        if ~isfield(param,'sigma')
            error('Define sigma');
        end
        if ~isfield(param,'r')
            error('Define r');
        end

        k = Kernels2('gauss', param);
        
        f = @(x,y) (vecnorm(x-y,2,2) <= param.r).*k(x,y);
        
        % Gradient
        if nargout > 1
            varargout{1} = @(x,y) -(x-y)/param.sigma^2.*f(x,y);    
        end
        
        % Hessian
        if nargout > 2          
            varargout{2} = @(x,y) (repmat(reshape(eye(size(x,2)),1,[]),size(x,1),1)...
                                 -(repelem(x-y,1,size(x,2)).*repmat(x-y,1,size(x,2)))/param.sigma^2)...
                                  /param.sigma^2.*f(x,y);
        end
        
    case 'gauss_vect'
        if ~isfield(param,'sigma')
            error('Define sigma');
        end
        
        k = Kernels2('gauss', param);
        f = @(x,y) repmat(reshape(eye(size(x,2)),1,[]),size(x,1),1).*k(x,y);
        
    case 'curl_free'
        if ~isfield(param,'sigma')
            error('Define sigma');
        end
        
        [~,~,d2k] = Kernels2('gauss', param);
        f = @(x,y) d2k(x,y);
        
    case 'cosine'
        f = @(x,y) sum(x.*y,2)./vecnorm(x,2,2)./vecnorm(y,2,2);
        
    case 'poly_hom'
        if ~isfield(param,'degree')
            error('Define polynomial degree');
        end
        f = @(x,y) diag(x*y').^param.degree;
        
    case 'poly_inhom'
        if ~isfield(param,'degree')
            error('Define polynomial degree');
        end
        if ~isfield(param,'const')
            error('Define polynomial constant');
        end
        f = @(x,y) (diag(x*y') + param.const).^param.degree;
        
    case 'euclid_dist'
        f = @(x,y) vecnorm(x-y,2,2).^2;
        
    case 'gauss_vel'
        if ~isfield(param,'sigma')
            error('Define sigma');
        end
        
        k = Kernels2('gauss', param);
        f = @(x,y,v) k(repmat(x,size(y,1),1),repelem(y,size(x,1),1)).*...
                       exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma);
        
        % Gradient
        if nargout > 1
            varargout{1} = @(x,y,v) (repmat(x,size(y,1),1)-repelem(y,size(x,1),1))/...
                                    param.sigma^2.*f(x,y,v);    
        end
        
        % Hessian
        if nargout > 2          
            varargout{2} = @(x,y,v)...
                           (-repmat(reshape(eye(size(x,2)),1,[]),size(x,1)*size(y,1),1)+...
                           (repelem(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),1,size(x,2)).*...
                           repmat(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),1,size(x,2)))/param.sigma^2)/...
                           param.sigma^2.*f(x,y,v);
        end
        
    otherwise
        error('Error');
end
end