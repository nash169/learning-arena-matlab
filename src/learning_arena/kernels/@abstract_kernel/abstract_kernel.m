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
        
        % Set parmeters
        set_params(obj, varargin)
        
        % Set data
        set_data(obj, varargin)
        
        % Get parameters
        [params, params_aux] = params(obj, parameter)
        
        % Get data
        data = data(obj)
        
        % Set hyper-parameters through vector
        set_v_params(obj, vec, varargin)
        
        % Get vector of hyper-parameters
        x = v_params(obj, varargin)
        
        % Get kernel evaluation
        k = kernel(obj, varargin)
        
        % Get gradient evaluation
        dk = gradient(obj, varargin)
        
        % Get hessian evaluation
        d2k = hessian(obj, varargin)
        
        % Get gradient wrt hyper-parameters
        [dp, n] = pgradient(obj, param, varargin)
        
        % Get gramian
        K = gramian(obj, varargin)
        
        % Plot gramian
        fig = plot_gramian(obj, varargin)
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
        
        debug = false
    end
    
    methods (Access = protected)
        % Check data and parameters
        check(obj)
        
        % Reset bools
        reset(obj)

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
        calc_gradient(obj)
        % Calculate hessian
        calc_hessian(obj)
        % Calculate params derivative
        calc_pgradient(obj, name)
    end
end

