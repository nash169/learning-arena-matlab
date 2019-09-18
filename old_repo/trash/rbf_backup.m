classdef rbf < abstract_kernel
    %ANISOTROPIC_RBF Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function obj = rbf(varargin)    
            obj = obj@abstract_kernel(varargin{:});
        end

        function set_params(obj, varargin)
            set_params@abstract_kernel(obj, varargin{:});          
            if logical(sum(strcmp(varargin(1:2:end), 'sigma')))
                obj.is_sigma_ = false;
            end
        end

        function set_data(obj, varargin)
            set_data@abstract_kernel(obj, varargin{:});
            obj.is_sigma_ = false;
        end
    end
        
    methods (Access = protected)
        function signature(obj)
             obj.type_ = {'scalar_valued'};
             obj.params_name_ = ['sigma', obj.params_name_];
        end
        
        function check(obj)
            check@abstract_kernel(obj);
            if ~obj.is_sigma_
                obj.set_sigma;
                obj.is_sigma_ = true;
            end
        end
        
        function d = num_params(obj, name)
            d = length(name);
            if logical(sum(strcmp(name, 'sigma')))
                d = d - 1 + obj.sigma_h_params_;
            end
        end
        
        function counter = set_pvec(obj, name, vec, counter)
            obj.set_params(name, vec(counter+1:counter+obj.sigma_h_params_)); % name = 'sigma'
            counter = counter + obj.sigma_h_params_;
        end
        
        function [vec, counter] = pvec(obj, name, vec, counter)
           vec(counter+1:counter+obj.sigma_h_params_) = ...
               c_reshape(obj.params_.(name), [], 1); % name = 'sigma'
           counter = counter + obj.sigma_h_params_; 
        end

        function k = calc_kernel(obj)
%             k = exp(-sum(obj.diff_.*c_reshape(obj.sigma_*reshape(obj.diff_',[],1), [], obj.d_),2)/2);
            switch obj.type_cov_
                case 1
                    k = exp(-sum(obj.diff_.^2.*obj.sigma_inv_,2)/2);
                    disp('kernel: type 1')
                case 2
                    k = exp(-sum(obj.diff_.*(obj.sigma_inv_*obj.diff_')',2)/2); 
                    disp('kernel: type 2')
                case 3
                    k = exp(-sum(obj.diff_.*c_reshape(sum(obj.sigma_inv_.*repelem(obj.diff_, obj.d_, 1),2),[], obj.d_),2)/2);
                    disp('kernel: type 3')
            end  
        end
          
        function dk = calc_gradient(obj, var)
            switch obj.type_cov_
                case 1
                    dk = obj.sigma_inv_.*obj.diff_.*obj.kernel;
                    disp('grad: type 1')
                case 2
                    dk = (obj.sigma_inv_*obj.diff_')'.*obj.kernel;
                    disp('grad: type 2')
                case 3
                    dk = c_reshape(sum(obj.sigma_inv_.*repelem(obj.diff_, obj.d_, 1),2),[], obj.d_).*obj.kernel;
                    disp('grad: type 3')
            end
%             switch var
%                 case 1
%                     dk = c_reshape(-obj.sigma_*reshape(obj.diff_',[],1), [], obj.d_).*obj.calc_kernel;
%                 case 2
%                     dk = c_reshape(obj.sigma_*reshape(obj.diff_',[],1), [], obj.d_).*obj.calc_kernel;    
%                 otherwise
%                     error("First derivative not present");
%             end
        end
        
        function d2k = calc_hessian(obj, var)
            switch obj.type_cov_
                case 1
                    a = obj.diff_.*obj.sigma_inv_;
                    I = repmat(eye(obj.d_),obj.m_*obj.n_,1).*c_reshape(obj.sigma_inv_.*ones(obj.m_*obj.n_,obj.d_), [],1);
                    dev = (I + 2*outer_product(a,a)).*repelem(obj.kernel, obj.d_,1);                   
                case 2                                  
                    S = repmat(obj.sigma_inv_, obj.m_*obj.n_, 1);
                    x = (obj.sigma_inv_*obj.diff_')';
                    xt = obj.diff_*obj.sigma_inv_;
                    dev = (S + 2*outer_product(x,xt)).*repelem(obj.kernel, obj.d_,1);      
                case 3
                    O = outer_product(obj.diff_,obj.diff_);
                    dev = (obj.sigma_inv_ + 2*matrix_prod(obj.sigma_inv_,matrix_prod(O, obj.sigma_inv_))) ...
                        .*repelem(obj.kernel, obj.d_,1);     
            end
            d2k = dev;
%             d2k = zeros(size(dev,1), size(dev,2), 4);
%             d2k(:,:,1) = -dev; d2k(:,:,1) = dev; d2k(:,:,1) = dev; d2k(:,:,1) = -dev;
            
%             switch var
%                 case 1
%                     d2k = -(-obj.sigma_ ...
%                             -2*obj.sigma_*blk_matrix(outer_product(obj.diff_,obj.diff_))*obj.sigma_) ...
%                             .*repelem(obj.calc_kernel, obj.d_,1);
%                 case 2
%                     d2k = (obj.sigma_ ...
%                             +2*obj.sigma_*blk_matrix(outer_product(obj.diff_,obj.diff_))*obj.sigma_) ...
%                             .*repelem(obj.calc_kernel, obj.d_,1);
%                 case 3
%                     d2k = (obj.sigma_ ...
%                             + 4*obj.sigma_*blk_matrix(outer_product(obj.diff_,obj.diff_))*obj.sigma_) ...
%                             .*repelem(obj.calc_kernel, obj.d_,1);
%                 case 4
%                     d2k = (-obj.sigma_ ...
%                             -2*obj.sigma_*blk_matrix(outer_product(obj.diff_,obj.diff_))*obj.sigma_) ...
%                             .*repelem(obj.calc_kernel, obj.d_,1);
%                 otherwise
%                     error("Second derivative not present");
%             end
        end
        
        function dp = calc_pgradient(obj, name)
            assert(strcmp(name,'sigma'), 'Parameter not found')
            
            switch obj.type_cov_
                case 1
                    dp = obj.diff_.^2./obj.params_.sigma.^3.*obj.kernel;
                    if size(obj.params_.sigma,2) == 1; dp = sum(dp,2); end
                case 2
                    x = (obj.sigma_inv_*obj.diff_')';
                    xt = obj.diff_*obj.sigma_inv_;
                    dp = -outer_product(x,xt)/2.*repelem(obj.kernel, obj.d_,1);
                case 3
                    O = outer_product(obj.diff_,obj.diff_);
                    dp = -matrix_prod(obj.sigma_inv_,matrix_prod(O, obj.sigma_inv_))/2 ...
                        .*repelem(obj.kernel, obj.d_,1);
            end
            
%             switch obj.cov_type_
%                 case 'spherical'
%                     dp = sum(obj.diff_.*c_reshape(obj.sigma_*obj.sigma_dev_*obj.sigma_ ...
%                         *reshape(obj.diff_',[],1), [], obj.d_),2)/2 ...
%                         .*obj.calc_kernel;
%                 case 'diagonal'
%                     
%                 case 'full'
%                     [M,x_i,y_i] = blk_matrix(outer_product(obj.diff_,obj.diff_));
%                     dp = obj.sigma_*M*obj.sigma_/2.*repelem(obj.calc_kernel, obj.d_,1);
%                     dp = c_reshape(full(dp(sub2ind(size(dp),x_i(:),y_i(:)))), [], obj.d_^2);
%                 otherwise
%                     error('Type not present')
%             end
        end
        
        % Automatically establishes the type of covariace matrix depending
        % on what has been as 'sigma' of the structure params_
        function set_sigma(obj)
            obj.sigma_h_params_ = numel(obj.params_.sigma);
            obj.type_cov_ = 1;
            switch obj.sigma_h_params_
                % Spherical covariance matrix (isotropic RBF)
                case 1
                    obj.cov_type_ = 'spherical';
                    obj.sigma_ = speye(obj.m_*obj.n_*obj.d_)/obj.params_.sigma^2;
                    obj.sigma_dev_ = speye(obj.m_*obj.n_*obj.d_)*2*obj.params_.sigma;
                    
                    % New test
                    obj.sigma_inv_ = 1/obj.params_.sigma^2;
                    
                % Spherical m-points dependent
                case obj.m_
                    obj.cov_type_ = 'spherical';
                    obj.sigma_ = spdiags(repelem(repmat(1./obj.params_.sigma.^2, obj.n_, 1),obj.d_,1), ...
                        0 , obj.m_*obj.n_*obj.d_, obj.m_*obj.n_*obj.d_);
                    obj.sigma_dev_ = spdiags(repelem(repmat(2*obj.params_.sigma, obj.n_, 1),obj.d_,1), ...
                        0 , obj.m_*obj.n_*obj.d_, obj.m_*obj.n_*obj.d_);
                    
                    % New test
                    a = c_reshape(obj.params_.sigma, obj.m_, 1);
                    obj.sigma_inv_ = repmat(1./a.^2, obj.n_, 1);
                
                % Spherical m-points dependent
                case obj.n_
                    % New test
                    a = c_reshape(obj.params_.sigma, obj.n_, 1);
                    obj.sigma_inv_ = repelem(1./a.^2, obj.m_, 1);
                    
                % Spherical mn-points dependent    
                case obj.m_*obj.n_
                    obj.cov_type_ = 'spherical';
                    obj.sigma_ = spdiags(repelem(1./obj.params_.sigma.^2,obj.d_,1), ...
                        0 , obj.m_*obj.n_*obj.d_, obj.m_*obj.n_*obj.d_);
                    obj.sigma_dev_ = spdiags(repelem(2*obj.params_.sigma,obj.d_,1), ...
                        0 , obj.m_*obj.n_*obj.d_, obj.m_*obj.n_*obj.d_);
                    
                    % New test
                    a = c_reshape(obj.params_.sigma, obj.m_*obj.n_, 1);
                    obj.sigma_inv_ = 1./a.^2;
                    
                % Diagonal covariance matrix
                case obj.d_
                    obj.cov_type_ = 'diagonal';
                    obj.sigma_ = spdiags(repmat(1./obj.params_.sigma.^2, obj.m_*obj.n_, 1), ...
                        0 , obj.m_*obj.n_*obj.d_, obj.m_*obj.n_*obj.d_);
                    obj.sigma_dev_ = spdiags(repmat(2*obj.params_.sigma, obj.m_*obj.n_, 1), ...
                        0 , obj.m_*obj.n_*obj.d_, obj.m_*obj.n_*obj.d_);
                    
                    % New test
                    a = c_reshape(obj.params_.sigma, 1, obj.d_);
                    obj.sigma_inv_ = 1./a.^2;
                    
                % Diagonal m-points dependent    
                case obj.m_*obj.d_
                    obj.cov_type_ = 'diagonal';
                    obj.sigma_ = spdiags(repmat(1./obj.params_.sigma.^2, obj.n_, 1), ...
                        0 , obj.m_*obj.n_*obj.d_, obj.m_*obj.n_*obj.d_);
                    obj.sigma_dev_ = spdiags(repmat(2*obj.params_.sigma, obj.n_, 1), ...
                        0 , obj.m_*obj.n_*obj.d_, obj.m_*obj.n_*obj.d_);
                    
                    % New test
                    a = c_reshape(obj.params_.sigma, obj.m_, obj.d_);
                    obj.sigma_inv_ = repmat(1./a.^2, obj.n_, 1);
                    
                % Diagonal n-points dependent
                case obj.n_*obj.d_
                    % New test
                    a = c_reshape(obj.params_.sigma, obj.n_, obj.d_);
                    obj.sigma_inv_ = repelem(1./a.^2, obj.m_, 1);
                    
                % Diagonal mn-points dependent    
                case obj.m_*obj.n_*obj.d_
                    obj.cov_type_ = 'diagonal';
                    obj.sigma_ = spdiags(1./obj.params_.sigma.^2, ...
                        0 , obj.m_*obj.n_*obj.d_, obj.m_*obj.n_*obj.d_);
                    obj.sigma_dev_ = spdiags(2*obj.params_.sigma, ...
                        0 , obj.m_*obj.n_*obj.d_, obj.m_*obj.n_*obj.d_);
                    
                    % New test
                    a = c_reshape(obj.params_.sigma, obj.m_*obj.n_, obj.d_);
                    obj.sigma_inv_ = 1./a.^2;
                
                % Full covariance matrix (anisotropic RBF)
                case obj.d_^2
                    obj.cov_type_ = 'full';
                    if obj.sigma_h_params_ == length(obj.params_.sigma)
                        obj.params_.sigma = c_reshape(obj.params_.sigma, [], obj.d_);
                    end
                    obj.sigma_ = blk_matrix(repmat(obj.params_.sigma, obj.m_*obj.n_, 1));
                    
                    % New test
                    obj.sigma_inv_ = obj.params_.sigma; % sigma is meant to be already the inverse (to change)
                    obj.type_cov_ = 2;
                
                % Full m-points dependent    
                case obj.m_*obj.d_^2
                    obj.cov_type_ = 'full';
                    if obj.sigma_h_params_ == length(obj.params_.sigma)
                        obj.params_.sigma = c_reshape(obj.params_.sigma, [], obj.d_);
                    end
                    obj.sigma_ = blk_matrix(repmat(obj.params_.sigma, obj.n_, 1));
                    
                    a = c_reshape(obj.params_.sigma, obj.m_*obj.d_, obj.d_);
                    obj.sigma_inv_ = repmat(a, obj.n_, 1);
                    obj.type_cov_ = 3;
                    
                % Full n-points dependent
                case obj.n_*obj.d_^2
                    a = c_reshape(obj.params_.sigma, obj.n_*obj.d_, obj.d_);
                    obj.sigma_inv_ = repelem(a, obj.m_, 1);
                    obj.type_cov_ = 3;
                    
                % Full mn-points dependent   
                case obj.m_*obj.n_*obj.d_^2
                    obj.cov_type_ = 'full';
                    if obj.sigma_h_params_ == length(obj.params_.sigma)
                        obj.params_.sigma = c_reshape(obj.params_.sigma, [], obj.d_);
                    end
                    obj.sigma_ = blk_matrix(obj.params_.sigma);
                    
                    a = c_reshape(obj.params_.sigma, obj.m_*obj.n_*obj.d_, obj.d_);
                    obj.sigma_inv_ = a;
                    obj.type_cov_ = 3;
                    
                otherwise
                    error('Case not recognized');
            end
        end
    end
    
    properties (Access = protected)
       sigma_;
       sigma_h_params_;
       sigma_dev_;
       is_sigma_;   
       cov_type_;
       
       sigma_inv_;
       type_cov_;
    end
end

%             flip = false;
%             
%             for i = 1 : length(varargin)
%                 if ~flip
%                     obj.Data_{i} = repmat(varargin{i},obj.n_,1);
%                     flip = true;
%                 else
%                     obj.Data_{i} = repelem(varargin{i},obj.m_,1);
%                     flip = false;
%                 end     
%             end

