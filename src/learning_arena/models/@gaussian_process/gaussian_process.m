classdef gaussian_process < kernel_expansion
    %GAUSSIAN_PROCESS Summary of this class goes here
    %   Detailed explanation goes here
    
    %=== PUBLIC ===%
    methods
        function obj = gaussian_process(varargin)
            %GAUSSIAN_PROCESS Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@kernel_expansion(varargin{:});
        end
        
        set_params(obj, varargin)
        
        x = optimize(obj, varargin)
        
        [f,g] = functional(obj, x, varargin)
        
        ll = likelihood(obj)
        
        ll_grad = likelihood_grad(obj, varargin)
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
        signature(obj);
        
        check(obj);
        
        reset(obj);
        
        set_weights(obj);
        
        set_gauss(obj);
    end
end

