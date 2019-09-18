classdef gaussian_process < kernel_expansion
    %GAUSSIAN_PROCESS Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = gaussian_process(varargin)
            %GAUSSIAN_PROCESS Construct an instance of this class
            %   Detailed explanation goes here
            obj.params_name_ = {'kernel', 'targets'};
            if nargin > 0; obj.set_params(varargin{:}); end
        end
        
        function x = optimize(obj, varargin)
            obj.check;
            x0 = obj.params_.kernel.v_params(varargin{:});
            fun = @(x) obj.functional(x, varargin{:});
            options = optimoptions('fminunc', ...
                                  'Algorithm', 'quasi-newton', ...
                                  'SpecifyObjectiveGradient', true);
            x = fminunc(fun,x0,options);
%             options = optimoptions('fmincon', ...
%                                   'Algorithm', 'interior-point', ...
%                                   'SpecifyObjectiveGradient', true);
%             x = fmincon(fun,x0,[],[],[],[],[],[], [], options);
            obj.params_.kernel.set_v_params(x, varargin{:});
            obj.reset;
        end
        
        function [f,g] = functional(obj, x, varargin)
            obj.params_.kernel.set_v_params(x, varargin{:});
            obj.get_gauss;
            f = -obj.likelihood;
            g = -obj.likelihood_grad(varargin{:});
        end
        
        function ll = likelihood(obj)
            obj.check;
            ll = obj.gauss_.logpdf(obj.params_.targets');
        end
        
        function ll_grad = likelihood_grad(obj, varargin)
            obj.check;
            gauss_grad = obj.gauss_.logpdf_grad(obj.params_.targets', 'sigma');
            [dK, n] = obj.params_.kernel.pgradient(varargin, obj.data_, obj.data_);
            
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
    
    methods (Access = protected)
        function check(obj)
           check@kernel_expansion(obj);
           if ~obj.is_weights_; obj.get_weights; end
           if ~obj.is_gauss_; obj.get_gauss; end
        end
        
        function get_gauss(obj)
            obj.gauss_.set_params( ...
                    'mean', zeros(1,obj.m_), ...
                    'sigma', obj.params_.kernel.gramian(obj.data_, obj.data_) ...
            );
            obj.is_gauss_ = true;
        end
        
        function get_weights(obj)
%             L = chol(obj.params_.kernel.gramian(obj.data_, obj.data_));
%             obj.params_.weights = L'\(L\obj.params_.targets);
            obj.params_.weights = obj.params_.kernel.gramian(obj.data_, obj.data_)\obj.params_.targets;
            obj.is_weights_ = true;
        end
        
        function reset(obj)
           reset@kernel_expansion(obj);
           obj.is_weights_ = false;
           obj.is_variance_ = false;
           obj.is_gauss_ = false;
        end
    end
    
    properties (Access = public)
        gauss_ = gauss_normal
        
        variance_
        
        is_weights_ = false
        is_gauss_ = false
        
        is_variance_ = false
    end
end

