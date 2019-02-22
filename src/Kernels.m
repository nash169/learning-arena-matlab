function [f, varargout] = Kernels(type, param)
%KERNELS Summary of this function goes here
%   Detailed explanation goes here

switch type      
    % RBF Gauss Kernel: exp(-||x-y||/2*sigma^2)
    % This is the classical Gaussian Kernel
    % Required parameters: sigma
    case 'gauss'
        if ~isfield(param,'sigma')
            error('Define sigma');
        end    
        f = @(x,y)...
            exp(-vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2).^2/...
            2/param.sigma^2);
        % Gradient
        if nargout > 1
            varargout{1} = @(x,y)...
                           (repmat(x,size(y,1),1)-repelem(y,size(x,1),1))/...
                            param.sigma^2.*f(x,y);     
        end   
        % Hessian
        if nargout > 2          
            varargout{2} = @(x,y)...
                           (-repmat(reshape(eye(size(x,2)),1,[]),size(x,1)*size(y,1),1)+...
                           (repelem(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),1,size(x,2)).*...
                           repmat(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),1,size(x,2)))/param.sigma^2)/...
                           param.sigma^2.*f(x,y);
        end
        
    % RBF Compact Gauss Kernel: exp(-||x-y||/2*sigma^2) if ||x-y||<=r
    % This is the classical Gaussian Kernel with compact support. Besides
    % 'sigma' it needs the support 'r' of the function so that the kernel
    % is equal to zero if ||x-y||>r
    % Required parameters: sigma, r
    case 'gauss_compact'
        if ~isfield(param,'sigma')
            error('Define sigma');
        end
        if ~isfield(param,'r')
            error('Define r');
        end
        [k,~,~] = Kernels('gauss', param);
        f = @(x,y)...
            (vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2) <= param.r)...
            .*k(x,y);
        % Gradient
        if nargout > 1
            [~,dk,~] = Kernels('gauss', param);
            varargout{1} = @(x,y)...
                           (vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2) <= param.r)...
                           .*dk(x,y);    
        end
        % Hessian
        if nargout > 2  
            [~,~,d2k] = Kernels('gauss', param);
            varargout{2} = @(x,y)...
                           (vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2) <= param.r)...
                           .*d2k(x,y);
        end
        
    % Velocity modified RBF Gauss Kernel: (1+lambda*exp(-|||f(x)||/sigma_vel))*exp(-||x-y||/2*sigma^2)
    % This is the standard Gaussian Kernel premultiplied by a decreasing
    % exponential whose argument is a function of data x (a modulating
    % factor 'lambda' regulates the intensity of this exponential while
    % 'sigma_vel' regulates the locality). This is basically the velocity 
    % at point x. It is a non-symmetric kernel dependent on values related
    % to the points x.
    % Required parameters: sigma, sigma_vel, lambda
    case 'gauss_vel'
        if ~isfield(param,'sigma')
            error('Define sigma');
        end   
        if ~isfield(param,'sigma_vel')
            error('Define sigma for velocity');
        end
        if ~isfield(param,'lambda')
            error('Define lambda');
        end
        [k,~,~] = Kernels('gauss', param);
        f = @(x,y,v)...
            (1 + param.lambda*exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
            k(x,y);
        % Gradient
        if nargout > 1
            [~,dk,~] = Kernels('gauss', param);
            varargout{1} = @(x,y,v)...
                           (1 + param.lambda*exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
                           dk(x,y);   
        end
        % Hessian
        if nargout > 2
            [~,~,d2k] = Kernels('gauss', param);
            varargout{2} = @(x,y,v)...
                           (1 + param.lambda*exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
                           d2k(x,y);
        end
    
    % Velocity modified RBF Gauss Kernel - Conformal Transformation
    case 'gauss_vel_conf'
        if ~isfield(param,'sigma')
            error('Define sigma');
        end   
        if ~isfield(param,'sigma_vel')
            error('Define sigma for velocity');
        end
        if ~isfield(param,'lambda')
            error('Define lambda');
        end
        [k,~,~] = Kernels('gauss', param);
        f = @(x,y,v)...
            (1 + param.lambda*exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
            k(x,y).*...
            (1 + param.lambda*exp(-vecnorm(repelem(v,size(x,1),1),2,2)/param.sigma_vel));
        % Gradient
        if nargout > 1
            [~,dk,~] = Kernels('gauss', param);
            varargout{1} = @(x,y,v)...
                           (1 + param.lambda*exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
                           dk(x,y).*...
                           (1 + param.lambda*exp(-vecnorm(repelem(v,size(x,1),1),2,2)/param.sigma_vel));   
        end
        % Hessian
        if nargout > 2
            [~,~,d2k] = Kernels('gauss', param);
            varargout{2} = @(x,y,v)...
                           (1 + param.lambda*exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
                           d2k(x,y).*...
                           (1 + param.lambda*exp(-vecnorm(repelem(v,size(x,1),1),2,2)/param.sigma_vel));
        end
        
    % Attractor distance modified RBF Gauss Kernel - Conformal Transformation
    case 'gauss_attract_conf'
        if ~isfield(param,'sigma')
            error('Define sigma');
        end   
        if ~isfield(param,'sigma_attract')
            error('Define sigma for attractor kernel');
        end
        if ~isfield(param,'lambda')
            error('Define lambda scaling');
        end
        
        par_attr.sigma = param.sigma_attract;
        
        [k,~,~] = Kernels('gauss', param);
        [k_a,~,~] = Kernels('gauss', par_attr);
        
        f = @(x,y,x_a)...
            repmat((1 + param.lambda*sum(reshape(k_a(x_a,x), size(x_a,1), [])))',size(y,1),1).*...
            k(x,y).*...
            repelem((1 + param.lambda*sum(reshape(k_a(x_a,y), size(x_a,1), [])))',size(x,1),1);
        % Gradient
        if nargout > 1
            [~,dk,~] = Kernels('gauss', param);
            [~,dk_a,~] = Kernels('gauss', par_attr);
            varargout{1} = @(x,y,x_a) ...
                           repmat((1 + param.lambda*sum(reshape(k_a(x_a,x), size(x_a,1), [])))',size(y,1),1).* ...
                           dk(x,y).*...
                           repelem((1 + param.lambda*sum(reshape(k_a(x_a,y), size(x_a,1), [])))',size(x,1),1) + ...
                           repmat((1 + param.lambda*sum(reshape(k_a(x_a,x), size(x_a,1), [])))',size(y,1),1).* ...
                           k(x,y).*...
                           repelem(squeeze(sum(reshape(dk_a(x_a,y)',size(y,2),size(x_a,1),[]),2))',size(x,1),1);
        end
        % Hessian
%         if nargout > 2
%             [~,~,d2k] = Kernels('gauss', param);
%             [~,~,d2k_a] = Kernels('gauss', par_attr);
%             varargout{2} = @(x,y,v)...
%                            (1 + exp(-vecnorm(repmat(v,size(y,1),1),2,2)/param.sigma_vel)).*...
%                            d2k(x,y).*...
%                            (1 + exp(-vecnorm(repelem(v,size(x,1),1),2,2)/param.sigma_vel));
%         end

% x_a = x_i(vecnorm(xdot_i,2,2)==0,:);
% [rbf_a, drbf_a] = Kernels('gauss_attract_conf', kpar);
% rbf_a = @(x,y) rbf_a(x,y,x_a);
% drbf_a = @(x,y) drbf_a(x,y,x_a);
        
    % Attractor distance modified RBF Gauss Kernel - Conformal Transformation
    case 'gauss_var_hyper'
        if ~isfield(param,'sigma')
            error('Define sigma');
        end
        f = @(x,y,v)...
            exp(-vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2).^2/...
            2/vecnorm(repmat(v,size(y,1),1))^2);
        % Gradient
        if nargout > 1
            varargout{1} = @(x,y,v)...
                           (repmat(x,size(y,1),1)-repelem(y,size(x,1),1))/...
                            vecnorm(repmat(v,size(y,1),1))^2.*f(x,y,v);   
        end
        % Hessian
        if nargout > 2
            varargout{2} = @(x,y,v)...
                           (-repmat(reshape(eye(size(x,2)),1,[]),size(x,1)*size(y,1),1)+...
                           (repelem(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),1,size(x,2)).*...
                           repmat(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),1,size(x,2)))/vecnorm(repmat(v,size(y,1),1))^2)/...
                           vecnorm(repmat(v,size(y,1),1))^2.*f(x,y,v);
        end
        
    % Non-Stationary Velocity Covariance Oriented Gaussian Kernel 
    case 'gauss_ns'
        if ~isfield(param,'rot')
            error('Define rotation matrix');
        end
        if ~isfield(param,'lambda')
            error('Define lambda');
        end
        if ~isfield(param,'sigma')
            error('Define sigma');
        end
        f = @(x,y,v)...
            exp(-VelElip(x,y,v,param.rot,param.lambda)); % /2/param.sigma^2
        
    % Non-Stationary Covariance Oriented Gaussian Kernel 
    case 'gauss_ns_std'
        if ~isfield(param,'epsilon')
            error('Define epsilon');
        end
        f = @(x,y)...
            exp(-CovCenter(x,y)/param.epsilon);
        
    % Non-Stationary Covariance Oriented Gaussian Kernel with training points 
    case 'gauss_ns_std_train'
        if ~isfield(param,'epsilon')
            error('Define epsilon');
        end
        f = @(x,y,x_i)...
            exp(-CovCenter2(x,y,x_i)/param.epsilon);
                      
    % Positions (Velocities) Cosine Kernel
    case 'cosine'
        f = @(x,y) sum(repmat(x,size(y,1),1).*repelem(y,size(x,1),1),2)...
            ./vecnorm(repmat(x,size(y,1),1),2,2)./vecnorm(repelem(y,size(x,1),1),2,2);
    
    % Cross Distance-Velocities Cosine Kernel   
    case 'cosine_cross'
%         f = @(x,y,v) sum((repmat(x,size(y,1),1)-repelem(y,size(x,1),1)).*repelem(v,size(x,1),1),2)...
%             ./vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2)./vecnorm(repelem(v,size(x,1),1),2,2);
        f = @(x,y,v) sum((repelem(x,size(y,1),1)-repmat(y,size(x,1),1)).*repmat(v,size(x,1),1),2)...
            ./vecnorm(repelem(x,size(y,1),1)-repmat(y,size(x,1),1),2,2)./vecnorm(repmat(v,size(x,1),1),2,2);
    
    % Homogeneous Polynomial Kernel
    case 'poly_hom'
        if ~isfield(param,'degree')
            error('Define polynomial degree');
        end
        f = @(x,y) sum(repmat(x,size(y,1),1).*repelem(y,size(x,1),1),2)...
                   .^param.degree;
    
    % Inhomogeneous Polynomial Kernel
    case 'poly_inhom'
        if ~isfield(param,'degree')
            error('Define polynomial degree');
        end
        if ~isfield(param,'const')
            error('Define polynomial constant');
        end
        f = @(x,y) (sum(repmat(x,size(y,1),1).*repelem(y,size(x,1),1),2) + param.const)...
            .^param.degree;
    
    % Euclidian Distance
    case 'euclid_dist'
        f = @(x,y) vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2).^2;
    
    % Vector-Valued Gauss Kernel
    case 'gauss_vv'
        if ~isfield(param,'sigma')
            error('Define sigma');
        end
        
        k = Kernels('gauss', param);
        f = @(x,y)...
            repmat(reshape(eye(size(x,2)),1,[]),size(x,1)*size(y,1),1)...
            .*k(x,y);
    
    % Vector-Valued Curl Free Kernel
    case 'curl_free'
        if ~isfield(param,'sigma')
            error('Define sigma');
        end
        
        [~,~,d2k] = Kernels('gauss', param);
        f = @(x,y) -d2k(x,y);
        
    otherwise
        error('Error');
end
end