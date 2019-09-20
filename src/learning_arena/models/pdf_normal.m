classdef pdf_normal < kernel_expansion
    %PDF Summary of this class goes here
    %   Detailed explanation goes here
    
    %=== PUBLIC ===%
    methods
        function obj = pdf_normal(varargin)
            %PDF Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@kernel_expansion(varargin{:});
        end
        
        function set_params(obj, varargin)
            set_params@kernel_expansion(obj, varargin{:});
            
            if logical(sum(strcmp(varargin, 'mean')))
                obj.params_.('reference') = obj.h_params_.mean;
            end
        end
    end
    
    %=== PROTECTED ===%
    methods (Access = protected)
        function signature(obj)
            obj.h_params_list_ = {'mean', 'std'};
            obj.params_.order = 'test-ref';
        end
        
        function check(obj)
            check@kernel_expansion(obj);
            
            if ~obj.is_kernel_
                obj.h_params_.weights = 1/sqrt((2*pi)^obj.d_*det(obj.h_params_.std*eye(obj.d_)));
                obj.h_params_.kernel = rbf('sigma', obj.h_params_.std);
                obj.is_kernel_ = true;
            end
        end
        
        function reset(obj)
            reset@kernel_expansion(obj);
            obj.is_kernel_ = false;
        end
        
        function calc_pgradient(obj, param)
           switch param
               case 'mean'
                   
               case 'std'
                   
               otherwise
                   error('Derivation not possible')
           end
        end
    end
    
    properties (Access = protected)
        is_kernel_
    end    
end

