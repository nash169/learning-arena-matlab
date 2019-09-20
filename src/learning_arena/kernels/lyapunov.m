classdef lyapunov < abstract_kernel
    %LYAPUNOV Summary of this class goes here
    %   Detailed explanation goes here
    
%=== PUBLIC ===%
    methods
        function obj = lyapunov(varargin)
            %LYAPUNOV Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@abstract_kernel(varargin{:});
        end
    end
    
%=== PROTECTED ===%
    properties (Access = protected)
        v_field_;
        is_field_;
    end
    
    methods (Access = protected)
        function signature(obj)
            obj.type_ = {'scalar_valued'};
            obj.h_params_list_ = ['kernel', 'v_field', obj.h_params_list_];
        end
        
        function check(obj)
            check@abstract_kernel(obj);
            if ~obj.is_field_
                obj.v_field_ = repmat(obj.h_params_.v_field,obj.n_,1);
                obj.is_field_ = true;
            end
        end
        
        function reset(obj)
            reset@abstract_kernel(obj);
            obj.is_field_ = false;
        end
        
        function d = num_params(obj, name)
        end
        
        function counter = set_pvec(obj, name, vec, counter)
        end
        
        function [vec, counter] = pvec(obj, name, vec, counter)
        end
        
        function k = calc_kernel(obj)
            kernel = obj.h_params_.kernel.kernel;
            kernel_grad = obj.h_params_.kernel.gradient;
            k = kernel + sum(kernel_grad(:,:,1).*obj.v_field_,2);
        end
        
        function dk = calc_gradient(obj)
            kernel_grad = obj.h_params_.kernel.gradient;
            kernel_hess = obj.h_params_.kernel.hessian;
            
            dk = zeros(obj.m_*obj.n_, obj.d_, 2);
            dk(:,:,1) = kernel_grad(:,:,1) + c_reshape(sum(kernel_hess(:,:,1).*repelem(obj.v_field_,obj.d_,1),2), [], obj.d_);
            dk(:,:,2) = kernel_grad(:,:,2) + c_reshape(sum(kernel_hess(:,:,2).*repelem(obj.v_field_,obj.d_,1),2), [], obj.d_);
        end
        
        function d2k = calc_hessian(obj)
        end
        
        function dp = calc_pgradient(obj, name)
        end
    end
end

