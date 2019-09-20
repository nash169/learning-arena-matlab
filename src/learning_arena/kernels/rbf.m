classdef rbf < abstract_kernel
    %ANISOTROPIC_RBF Summary of this class goes here
    %   Detailed explanation goes here
    
%=== PUBLIC ===%
    methods
        function obj = rbf(varargin)    
            obj = obj@abstract_kernel(varargin{:});
            obj.is_data_dep_ = true;
            obj.is_sigma_inv_ = false;
            obj.is_chol_ = false;
            if ~isfield(obj.params_, 'sigma_inv'); obj.params_.sigma_inv = false; end
        end

        function set_params(obj, varargin)
            set_params@abstract_kernel(obj, varargin{:});          
            if logical(sum(strcmp(varargin(1:2:end), 'sigma'))) || ...
               logical(sum(strcmp(varargin(1:2:end), 'sigma_inv')))
                obj.is_sigma_inv_ = false;
            end
        end

        function set_data(obj, varargin)
            set_data@abstract_kernel(obj, varargin{:});
            if obj.is_data_dep_; obj.is_sigma_inv_ = false; end
        end
    end
    
%=== PROTECTED ===% 
    properties (Access = protected)
        type_cov_;      % Type of covariance matrix 
        num_h_params_;  % Number of hyperparameters
        
        sigma_inv_;     % Inverse of covariance matrix
        is_sigma_inv_;  % Bool presence of the covariance matrix
        
        chol_;          % Cholesy decomposition of the covariace matrix
        is_chol_;       % Bool presence cholesky L matrix
        
        is_data_dep_;   % Check if the covariance matrix is data dependent
    end
    
    methods (Access = protected)
        function signature(obj)
             obj.type_ = {'scalar_valued'};
             obj.h_params_list_ = ['sigma', obj.h_params_list_];
             obj.params_list_ = ['sigma_inv', obj.params_list_];
        end
        
        function check(obj)
            check@abstract_kernel(obj);
            if ~obj.is_sigma_inv_; obj.set_sigma; end
        end
        
        function d = num_params(obj, name)
            d = length(name);
            if logical(sum(strcmp(name, 'sigma')))
                d = d - 1 + obj.num_h_params_;
            end
        end
        
        function counter = set_pvec(obj, name, vec, counter)
            obj.set_params(name, vec(counter+1:counter+obj.num_h_params_)); % name = 'sigma'
            counter = counter + obj.num_h_params_;
        end
        
        function [vec, counter] = pvec(obj, name, vec, counter)
           vec(counter+1:counter+obj.num_h_params_) = ...
               c_reshape(obj.h_params_.(name), [], 1); % name = 'sigma'
           counter = counter + obj.num_h_params_; 
        end

        function k = calc_kernel(obj)
            switch obj.type_cov_
                case 1
                    k = exp(-sum(obj.diff_.^2.*obj.sigma_inv_,2)/2);
                case 2
                    if obj.is_chol_
                        k = exp(-sum(obj.diff_.*(obj.chol_'\(obj.chol_\obj.diff_'))',2)/2);
%                         k =
%                         exp(-sum(obj.diff_.*(obj.sigma_\obj.diff_')',2)/2);
%                         There is also this option
                    else
                        k = exp(-sum(obj.diff_.*(obj.sigma_inv_*obj.diff_')',2)/2);
                    end
                case 3
                    % This case is difficult to handle without the inverse
                    % matrix and/or with cholesky decomposition because the
                    % vectorized version of the inverse product is not
                    % available yet
                    k = exp(-sum(obj.diff_.*c_reshape(sum(obj.sigma_inv_.*repelem(obj.diff_, obj.d_, 1),2),[], obj.d_),2)/2);
            end  
        end
          
        function dk = calc_gradient(obj)
            switch obj.type_cov_
                case 1
                    grad = obj.sigma_inv_.*obj.diff_.*obj.kernel;
                case 2
                    if obj.is_chol_
                        grad = (obj.chol_'\(obj.chol_\obj.diff_'))'.*obj.kernel;
%                         dev = (obj.sigma_\obj.diff_')'.*obj.kernel; There
%                         is also this option
                    else
                        grad = (obj.sigma_inv_*obj.diff_')'.*obj.kernel;
                    end
                case 3
                    % This case is difficult to handle without the inverse
                    % matrix and/or with cholesky decomposition because the
                    % vectorized version of the inverse product is not
                    % available yet
                    grad = c_reshape(sum(obj.sigma_inv_.*repelem(obj.diff_, obj.d_, 1),2),[], obj.d_).*obj.kernel;
            end
            dk = zeros(size(grad,1), size(grad,2), 2);
            dk(:,:,1) = -grad; dk(:,:,2) = grad;
        end
        
        function d2k = calc_hessian(obj)
            switch obj.type_cov_
                case 1
                    a = obj.diff_.*obj.sigma_inv_;
                    I = repmat(eye(obj.d_),obj.m_*obj.n_,1).*c_reshape(obj.sigma_inv_.*ones(obj.m_*obj.n_,obj.d_), [],1);
                    hess = (I - outer_product(a,a)).*repelem(obj.kernel, obj.d_,1);                   
                case 2
                    % Here it is necessary to check the a couple things but
                    % it should be easy to add the cholesky decomposition
                    % or the derivation of the hessian through matlab
                    % inverse operation
                    S = repmat(obj.sigma_inv_, obj.m_*obj.n_, 1);
                    x = (obj.sigma_inv_*obj.diff_')';
                    xt = obj.diff_*obj.sigma_inv_;
                    hess = (S - 2*outer_product(x,xt)).*repelem(obj.kernel, obj.d_,1);      
                case 3
                    % This case is difficult to handle without the inverse
                    % matrix and/or with cholesky decomposition because the
                    % vectorized version of the inverse product is not
                    % available yet
                    O = outer_product(obj.diff_,obj.diff_);
                    hess = (obj.sigma_inv_ - 2*matrix_prod(obj.sigma_inv_,matrix_prod(O, obj.sigma_inv_))) ...
                        .*repelem(obj.kernel, obj.d_,1);
                    % For matrices product to consider sparse block matrix
                    % product with sparse matrices built using the function
                    % 'sparse' not others
            end
            d2k = zeros(size(hess,1), size(hess,2), 4);
            d2k(:,:,1) = -hess; d2k(:,:,2) = hess; d2k(:,:,3) = hess; d2k(:,:,4) = -hess;
        end
        
        function dp = calc_pgradient(obj, name)
            assert(strcmp(name,'sigma'), 'Parameter not found')
            
            switch obj.type_cov_
                case 1
                    dp = obj.diff_.^2./obj.h_params_.sigma.^3.*obj.kernel;
                    if size(obj.h_params_.sigma,2) == 1; dp = sum(dp,2); end
                case 2
                    x = (obj.sigma_inv_*obj.diff_')';
                    xt = obj.diff_*obj.sigma_inv_;
                    dp = -outer_product(x,xt)/2.*repelem(obj.kernel, obj.d_,1);
                case 3
                    O = outer_product(obj.diff_,obj.diff_);
                    dp = -matrix_prod(obj.sigma_inv_,matrix_prod(O, obj.sigma_inv_))/2 ...
                        .*repelem(obj.kernel, obj.d_,1);
            end
        end
        
        % Automatically establishes the type of covariace matrix depending
        % on what has been as 'sigma' of the structure params_
        function set_sigma(obj)
            if obj.params_.sigma_inv
                obj.num_h_params_ = numel(obj.params_.sigma_inv);
            else
                obj.num_h_params_ = numel(obj.h_params_.sigma);
            end
            obj.type_cov_ = 1;
            obj.is_sigma_inv_ = true;
            
            switch obj.num_h_params_
                % Spherical covariance matrix (isotropic RBF)
                case 1
                    obj.sigma_inv_ = 1/obj.h_params_.sigma^2;
                    obj.is_data_dep_ = false;      
                % Spherical m-points dependent
                case obj.m_
                    obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.m_, 1);
                    obj.sigma_inv_ = repmat(1./obj.h_params_.sigma.^2, obj.n_, 1);      
                % Spherical m-points dependent
                case obj.n_
                    obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.n_, 1);
                    obj.sigma_inv_ = repelem(1./obj.h_params_.sigma.^2, obj.m_, 1);     
                % Spherical mn-points dependent    
                case obj.m_*obj.n_
                    obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.m_*obj.n_, 1);
                    obj.sigma_inv_ = 1./obj.h_params_.sigma.^2;           
                % Diagonal covariance matrix
                case obj.d_
                    obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, 1, obj.d_);
                    obj.sigma_inv_ = 1./obj.h_params_.sigma.^2;
                    obj.is_data_dep_ = false;          
                % Diagonal m-points dependent    
                case obj.m_*obj.d_
                    obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.m_, obj.d_);
                    obj.sigma_inv_ = repmat(1./obj.h_params_.sigma.^2, obj.n_, 1);
                % Diagonal n-points dependent
                case obj.n_*obj.d_
                    obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.n_, obj.d_);
                    obj.sigma_inv_ = repelem(1./obj.h_params_.sigma.^2, obj.m_, 1); 
                % Diagonal mn-points dependent    
                case obj.m_*obj.n_*obj.d_
                    obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.m_*obj.n_, obj.d_);
                    obj.sigma_inv_ = 1./obj.h_params_.sigma.^2;
                % Full covariance matrix (anisotropic RBF)
                case obj.d_^2
                    if obj.params_.sigma_inv
                        if obj.num_h_params_ == length(obj.params_.sigma_inv)
                            obj.params_.sigma_inv = c_reshape(obj.params_.sigma_inv, obj.d_, obj.d_);
                        end
                        obj.sigma_inv_ = obj.params_.sigma_inv;
                    else
                        if obj.num_h_params_ == length(obj.h_params_.sigma)
                            obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.d_, obj.d_);
                        end
                        obj.sigma_ = obj.h_params_.sigma; % The store is sigma migh useless
                        % Try cholesky decomposition of the matrix
                        obj.chol_ = chol(obj.sigma_);
                        obj.is_chol_ = true;
                    end
                    obj.type_cov_ = 2;
                    obj.is_data_dep_ = false;  
                % Full m-points dependent    
                case obj.m_*obj.d_^2
                    if obj.params_.sigma_inv
                        if obj.num_h_params_ == length(obj.params_.sigma_inv)
                            obj.params_.sigma_inv = c_reshape(obj.params_.sigma_inv, obj.m_*obj.d_, obj.d_);
                        end
                        obj.sigma_inv_ = repmat(obj.params_.sigma_inv, obj.n_, 1);
                    else
                        if obj.num_h_params_ == length(obj.h_params_.sigma)
                            obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.m_*obj.d_, obj.d_);
                        end
                        obj.sigma_ = repmat(obj.h_params_.sigma, obj.n_, 1); % The store is sigma migh useless
                        error('Cholesky decomposition for multiple covariance matrices')
                    end
                    obj.type_cov_ = 3;     
                % Full n-points dependent
                case obj.n_*obj.d_^2
                    if obj.params_.sigma_inv
                        if obj.num_h_params_ == length(obj.params_.sigma_inv)
                            obj.params_.sigma_inv = c_reshape(obj.params_.sigma_inv, obj.n_*obj.d_, obj.d_);
                        end
                        obj.sigma_inv_ = repelem(obj.params_.sigma_inv, obj.m_, 1);
                    else
                        if obj.num_h_params_ == length(obj.h_params_.sigma)
                            obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.n_*obj.d_, obj.d_);
                        end
                        obj.sigma_ = repelem(obj.h_params_.sigma, obj.m_, 1); % The store is sigma migh useless
                        error('Cholesky decomposition for multiple covariance matrices')
                    end
                    obj.type_cov_ = 3;             
                % Full mn-points dependent   
                case obj.m_*obj.n_*obj.d_^2
                    if obj.params_.sigma_inv
                        if obj.num_h_params_ == length(obj.params_.sigma_inv)
                            obj.params_.sigma_inv = c_reshape(obj.params_.sigma_inv, obj.m_*obj.n_*obj.d_, obj.d_);
                        end
                        obj.sigma_inv_ = obj.params_.sigma_inv;
                    else
                        if obj.num_h_params_ == length(obj.h_params_.sigma)
                            obj.h_params_.sigma = c_reshape(obj.h_params_.sigma, obj.m_*obj.n_*obj.d_, obj.d_);
                        end
                        obj.sigma_ = obj.h_params_.sigma; % The store is sigma migh useless
                        error('Cholesky decomposition for multiple covariance matrices')
                    end
                    obj.type_cov_ = 3;
                % Unknown cases                
                otherwise
                    error('Case not recognized');
            end
        end
    end
end

