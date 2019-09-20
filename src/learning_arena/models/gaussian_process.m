classdef gaussian_process < kernel_expansion
    %GAUSSIAN_PROCESS Summary of this class goes here
    %   Detailed explanation goes here
    
    %=== PUBLIC ===%
    methods
        function obj = gaussian_process(varargin)
            %GAUSSIAN_PROCESS Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@kernel_expansion(varargin{:});
            
            obj.gauss_ = gauss_normal;
        end
        
        function x = optimize(obj, varargin)
            obj.check;
            x0 = obj.h_params_.kernel.v_params(varargin{:});
            fun = @(x) obj.functional(x, varargin{:});
            options = optimoptions('fminunc', ...
                                  'Algorithm', 'quasi-newton', ...
                                  'SpecifyObjectiveGradient', true);
            x = fminunc(fun,x0,options);
%             options = optimoptions('fmincon', ...
%                                   'Algorithm', 'interior-point', ...
%                                   'SpecifyObjectiveGradient', true);
%             x = fmincon(fun,x0,[],[],[],[],[],[], [], options);
            obj.h_params_.kernel.set_v_params(x, varargin{:});
            obj.reset;
        end
        
        function [f,g] = functional(obj, x, varargin)
            obj.h_params_.kernel.set_v_params(x, varargin{:});
            obj.set_gauss;
            f = -obj.likelihood;
            g = -obj.likelihood_grad(varargin{:});
        end
        
        function ll = likelihood(obj)
            obj.check;
            ll = obj.gauss_.logpdf(obj.params_.target');
        end
        
        function ll_grad = likelihood_grad(obj, varargin)
            obj.check;
            
            gauss_grad = obj.gauss_.logpdf_grad(obj.params_.target', 'sigma');
            [dK, n] = obj.h_params_.kernel.pgradient(varargin, ...
                obj.params_.reference, obj.params_.reference);
            
            index = 1;
            ll_grad = zeros(n,1);
            for i = 1 : length(varargin)
                dk_temp = reshape(dK.(varargin{i}), obj.m_, obj.m_, []);
                for j = 1 : size(dk_temp,3)
                    ll_grad(index) = trace(gauss_grad*dk_temp(:,:,j));
                    index = index + 1;
                end
            end
        end
    end
    
    %=== PROTECTED ===% 
    properties (Access = protected)
        gauss_
        variance_
        
        is_weights_
        is_gauss_
        is_variance_
    end
    
    methods (Access = protected)
        function signature(obj)
            obj.h_params_list_ = {'kernel'}; 
            obj.params_list_ = {'reference', 'target'};
        end
        
        function check(obj)
           check@kernel_expansion(obj);
           if ~obj.is_weights_; obj.set_weights; end
           if ~obj.is_gauss_; obj.set_gauss; end
        end
        
        function reset(obj)
           reset@kernel_expansion(obj);
           obj.is_weights_ = false;
           obj.is_variance_ = false;
           obj.is_gauss_ = false;
        end
        
        % Set the weights of the gaussian process based on the training
        % points and the target besides the kernel's parameters
        function set_weights(obj)
%             L = chol(obj.h_params_.kernel.gramian(obj.params_.reference, obj.params_.reference));
%             obj.params_.weights = L'\(L\obj.params_.targets);
            obj.h_params_.weights = obj.h_params_.kernel.gramian(obj.params_.reference, obj.params_.reference)\obj.params_.target;
            obj.is_weights_ = true;
        end
        
        % Get a normal distribution object in order to compute the
        % likelihood and its gradient of the GP
        function set_gauss(obj)
            obj.gauss_.set_params( ...
                    'mean', zeros(1,obj.m_), ...
                    'sigma', obj.h_params_.kernel.gramian(obj.params_.reference, obj.params_.reference) ...
            );
            obj.is_gauss_ = true;
        end
    end
end

