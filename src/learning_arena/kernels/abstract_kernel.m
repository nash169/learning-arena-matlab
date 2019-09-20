classdef abstract_kernel < handle
    %ABSTRACT_KERNEL Summary of this class goes here
    %   Detailed explanation goes here
    
%=== PUBLIC ===%
    properties
        type_
        h_params_list_ = {'sigma_f', 'sigma_n'}
        params_list_ = {'compact'}
    end
    
    methods
        % In the constructor you can pass the parameters defining the
        % kernel. You can pass all of them or a part and set the rest using
        % the apposite function "set_params"
        function obj = abstract_kernel(varargin)
            obj.signature;
            if nargin > 0; obj.set_params(varargin{:}); end
            if ~isfield(obj.h_params_, 'sigma_f'); obj.h_params_.sigma_f = 1; end
            if ~isfield(obj.h_params_, 'sigma_n'); obj.h_params_.sigma_n = 1e-8; end
            if ~isfield(obj.params_, 'compact'); obj.params_.compact = false; end
            
            obj.is_data_ = false;
            obj.is_params_ = false;
            obj.reset;
        end
        
        % Set the parameters of the kernel. Set the parameters
        % that you like. Every time you set a parameters the kernel will be
        % recalculated
        function set_params(obj, varargin)
            for i = 1 : 2 : length(varargin)
                if logical(sum(strcmp(obj.h_params_list_, varargin{i})))
                    obj.h_params_.(varargin{i}) = varargin{i+1};
                elseif logical(sum(strcmp(obj.params_list_, varargin{i})))
                    obj.params_.(varargin{i}) = varargin{i+1};
                else
                    error('"%s" parameter not present', varargin{i})
                end
            end
            
            obj.is_params_ = false;
            obj.reset;
        end
        
        % Set the data. Here you have to pass all the data at
        % once. You can't set just part of the data right now. Maybe it
        % will be made more flexible in the future.
        function set_data(obj, varargin)
            [obj.m_, obj.d_] = size(varargin{1});
            [obj.n_, d_check] = size(varargin{2});
            assert(obj.d_ == d_check, 'Dimension not compatible');
            
            obj.data_ = varargin;
            obj.Data_{1} = repmat(varargin{1},obj.n_,1);
            obj.Data_{2} = repelem(varargin{2},obj.m_,1);
            obj.diff_ = obj.Data_{1}-obj.Data_{2};
            
            obj.is_data_ = true;
            obj.reset;
        end
        
        % Get the parameters of the kernel
        function [params, params_aux] = params(obj, parameter)
            assert(logical(sum(strcmp(obj.h_params_list_, parameter))), ...
                '"%s" parameter not present', parameter)
            if nargin < 2 
                params = obj.h_params_;
                if nargout > 1; params_aux = obj.params_; end
            else
                assert(nargout < 2, 'Just one output allowed')
                
                if logical(sum(strcmp(obj.h_params_list_, parameter)))
                    params = obj.h_params_.(parameter);
                elseif logical(sum(strcmp(obj.params_list_, parameter)))
                    params = obj.params_.(parameter);
                else
                    error('"%s" parameter not present', parameter)
                end
                
            end
        end
        
        % Get the data of the kernel
        function data = data(obj)
            data = obj.data_;
        end
        
        % Set hyper-parameters through vector
        function set_v_params(obj, vec, varargin)
            if nargin < 3; varargin = obj.h_params_list_(1:end-3); end
            
            counter = 0;
            for i = 1 : length(varargin)
                assert(logical(sum(strcmp(obj.h_params_list_, varargin{i}))), ...
                    '"%s" parameter not present', varargin{i});
                switch varargin{i}
                    case 'sigma_f'
                        obj.set_params('sigma_f', vec(counter+1));
                        counter = counter + 1;
                    case 'sigma_n'
                        obj.set_params('sigma_n', vec(counter+1));
                        counter = counter + 1;
                    otherwise
                        counter = obj.set_pvec(varargin{i}, vec, counter);
                end
            end
            
            obj.reset;
        end
        
        % Get vector of hyper-parameters
        function x = v_params(obj, varargin)
            if nargin < 2; varargin = obj.h_params_list_(1:end-3); end
            
            d = length(varargin);
            x = zeros(obj.num_params(varargin),1);
            counter = 0;
            
            for i = 1 : d
                assert(logical(sum(strcmp(obj.h_params_list_, varargin{i}))), ...
                    '"%s" parameter not present', varargin{i});
                switch varargin{i}
                    case 'sigma_f'
                        x(counter+1) = obj.h_params_.sigma_f;
                        counter = counter + 1;
                    case 'sigma_n'
                        x(counter+1) = obj.h_params_.sigma_n;
                        counter = counter + 1;
                    otherwise
                        [x, counter] = obj.pvec(varargin{i}, x, counter);
                end
            end
        end
        
        % This function return the kernel evaluation. You can pass the data
        % directly here if you want.
        function k = kernel(obj, varargin)
            if nargin > 1; obj.set_data(varargin{:}); end
            obj.check;
           
            if ~obj.is_kernel_
                obj.k_ = obj.h_params_.sigma_f^2*obj.calc_kernel + obj.h_params_.sigma_n^2*(vecnorm(obj.diff_,2,2)==0);
                if obj.params_.compact % It might be necessary to create a bool variable for this
                    obj.k_ = (obj.k_ >= obj.params_.compact).*obj.k_;
                end
                obj.is_kernel_ = true;
            end
           
            k = obj.k_;
        end
        
        % This function return the gradient evaluation. You can pass the data
        % directly here if you want.
        function dk = gradient(obj, varargin)
            if nargin > 1; obj.set_data(varargin{:}); end
            obj.check;
            
            if ~obj.is_gradient_
                obj.dk_ = obj.h_params_.sigma_f^2*obj.calc_gradient;
                obj.is_gradient_ = true;
            end
            
            dk = obj.dk_;
        end
        
        % This function return the hessian evaluation. You can pass the data
        % directly here if you want.
        function d2k = hessian(obj, varargin)
            if nargin > 1; obj.set_data(varargin{:}); end
            obj.check;
            
            if ~obj.is_hessian_
                obj.d2k_ = obj.h_params_.sigma_f^2*obj.calc_hessian;
                obj.is_hessian_ = true;
            end 
            
            d2k = obj.d2k_;
        end
        
        % This function calculates the derivatives of the kernel with
        % respect to the parameters.
        function [dp, n] = pgradient(obj, param, varargin)
            if nargin < 2; param = obj.h_params_list_; end
            if nargin > 2; obj.set_data(varargin{:}); end
            obj.check;
            
            for i = 1 : length(param)
                if ~isfield(obj.dp_, param{i})
                    switch param{i}
                        case 'sigma_f'
                            obj.dp_.sigma_f = 2*obj.h_params_.sigma_f*obj.calc_kernel;
                        case 'sigma_n'
                            obj.dp_.sigma_n = 2*obj.h_params_.sigma_n*(vecnorm(obj.diff_,2,2)==0);
%                             obj.dp_.sigma_n = 2*obj.h_params_.sigma_n^2*(vecnorm(obj.diff_,2,2)==0); % I don't understand this
                        otherwise
                            obj.dp_.(param{i}) = obj.h_params_.sigma_f^2*obj.calc_pgradient(param{i});
                    end
                end
            end
            
            dp = obj.dp_;
            
            if nargout > 1; n = obj.num_params(param); end
        end
        
        % This function return the gramian evaluation. You can pass the data
        % directly here if you want.
        function K = gramian(obj, varargin)
            if ~obj.is_gramian_
                obj.K_ = reshape(obj.kernel(varargin{:}), obj.m_, obj.n_);
            end
            K = obj.K_;
        end
        
        % This function plot the gramian a colored matrix. You can pass the data
        % directly here if you want.
        function fig = plot_gramian(obj, varargin)
           K = obj.gramian(varargin{:});
           fig = figure;
           pcolor([K, zeros(size(K,1), 1); zeros(1, size(K,2)+1)])
           axis image
           axis ij
           colorbar
        end
    end % methods
    
%=== PROTECTED ===%
    properties (Access = protected)
        % Data length in the first term of comparison
        m_
        
        % Data length in the second term of comparison
        n_
        
        % Data dimension
        d_
        
        % Raw data
        data_
        
        % Expanded data
        Data_
        
        % Data difference
        diff_
        
        % Kernel hyper-parameters
        h_params_
        
        % Kernel (optional) parameters       
        params_
        
        % Kernel evaluation
        k_
        
        % Gradient evaluation
        dk_
        
        % Hessian evaluation
        d2k_
        
        % Gramian evaluation
        K_
        
        % Gradient with respect to params
        dp_
        
        % Bool variables for necessary stuff
        is_data_
        is_params_
        
        % Bool variables for calculated stuff
        is_kernel_
        is_gradient_
        is_hessian_
        is_gramian_
    end
    
    methods (Access = protected)
        % Check data and parameters.
        function check(obj)
            assert(obj.is_data_, "Data not present");
            
            if ~obj.is_params_
                for i  = 1 : length(obj.h_params_list_)
                   assert(isfield(obj.h_params_,obj.h_params_list_{i}), ...
                       "Define %s", obj.h_params_list_{i});
                end
                
                for i  = 1 : length(obj.params_list_)
                   assert(isfield(obj.params_,obj.params_list_{i}), ...
                       "Define %s", obj.params_list_{i});
                end
                
                if ~obj.h_params_.sigma_n; obj.h_params_.sigma_n = 1e-8; end
                
                obj.is_params_ = true;
            end
        end
        
        % Reset bools
        function reset(obj)
            obj.is_kernel_ = false;
            obj.is_gradient_ = false;
            obj.is_hessian_ = false;
            obj.is_gramian_ = false;
            obj.dp_ = struct;
        end
    end
    
%=== ABSTRACT ===% 
    methods (Abstract = true, Access = protected)
        % Define type and parameters of the vector
        signature(obj)
        % Get the number of parameters
        num_params(obj, name)
        % Set parameters by vector
        set_pvec(obj, name, vec, counter)
        % Get parameters by vector
        pvec(obj, name, vec, counter)
        % Calculate kernel
        calc_kernel(obj)
        % Calculate gradient
        calc_gradient(obj,var)
        % Calculate hessian
        calc_hessian(obj,var)
        % Calculate params derivative
        calc_pgradient(obj,var)
    end
end

