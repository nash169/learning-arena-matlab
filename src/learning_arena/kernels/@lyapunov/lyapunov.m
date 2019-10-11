classdef lyapunov < abstract_kernel
    %LYAPUNOV Summary of this class goes here
    %   Detailed explanation goes here
    
%=== PUBLIC ===%
    methods
        function obj = lyapunov(varargin)
            %LYAPUNOV Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@abstract_kernel(varargin{:});
            
            if ~isfield(obj.h_params_, 'sym_weight'); obj.h_params_.sym_weight = 1; end
            if ~isfield(obj.h_params_, 'asym_weight'); obj.h_params_.asym_weight = 1; end
            
            if ~isfield(obj.params_, 'normalize'); obj.params_.normalize = false; end
            if ~isfield(obj.params_, 'isnan'); obj.params_.isnan = 1; end
            
            obj.is_field_ = false;
            obj.is_k_input_ = false;
        end
        
        function set_params(obj, varargin)
            set_params@abstract_kernel(obj, varargin{:});
            if logical(sum(strcmp(obj.h_params_list_, 'v_field')))
                obj.is_field_ = false;
            end
            
            if logical(sum(strcmp(obj.h_params_list_, 'kernel')))
                obj.is_k_input_ = false;
            end
        end
        
        function set_data(obj, varargin)
            set_data@abstract_kernel(obj, varargin{:});
            obj.is_k_input_ = false;
        end
    end
    
%=== PROTECTED ===%
    properties (Access = protected)
        v_field_;
        is_field_;
        is_k_input_;
    end
    
    methods (Access = protected)
        function signature(obj)
            obj.type_ = {'scalar_valued'};
            obj.h_params_list_ = ['kernel', 'v_field', 'sym_weight', 'asym_weight', obj.h_params_list_];
            obj.params_list_ = ['normalize', 'isnan', obj.params_list_];
        end
        
        function check(obj)
            check@abstract_kernel(obj);
            if ~obj.is_field_
                obj.v_field_ = repmat(obj.h_params_.v_field,obj.n_,1);
                obj.is_field_ = true;
            end
            
            if ~obj.is_k_input_
                obj.h_params_.kernel.set_data(obj.data_{:});
                obj.is_k_input_ = true;
            end
        end
        
        function d = num_params(obj, name)
        end
        
        function counter = set_pvec(obj, name, vec, counter)
        end
        
        function [vec, counter] = pvec(obj, name, vec, counter)
        end
        
        function k = calc_kernel(obj)
            % Define symmetric part
            sym = obj.h_params_.sym_weight*obj.h_params_.kernel.kernel;
            
            % Get gradient of the kernel (this can be changed and 
            % influences the type fo kernel; switch necessary)
            kernel_grad = obj.h_params_.kernel.gradient;
            kernel_grad = kernel_grad(:,:,1);
            
            % Define asymmetric part
            asym = obj.h_params_.asym_weight*sum(kernel_grad.*obj.v_field_,2);
            if obj.params_.normalize
                asym = asym./vecnorm(kernel_grad,2,2)./vecnorm(obj.v_field_,2,2);
                asym(isnan(asym)) = obj.params_.isnan;
            end
            
            k = sym + asym;
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

