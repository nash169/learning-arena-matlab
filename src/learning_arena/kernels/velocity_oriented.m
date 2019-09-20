classdef velocity_oriented < rbf
    %VELOCITY_ORIENTED Summary of this class goes here
    %   Detailed explanation goes here
    
%=== PUBLIC ===%
    methods
        function obj = velocity_oriented(varargin)
            %VELOCITY_ORIENTED Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@rbf(varargin{:});

            if ~isfield(obj.h_params_, 'weights'); obj.h_params_.weights = [2.5,5]; end
            if ~isfield(obj.h_params_, 'weight_fun'); obj.h_params_.weight_fun = @obj.weighted_norm; end       
        end
        
        function set_params(obj, varargin)
            set_params@abstract_kernel(obj, varargin{:});
            
            if logical(sum(strcmp(varargin(1:2:end), 'v_field'))) || ...
                logical(sum(strcmp(varargin(1:2:end), 'weights'))) || ...
                logical(sum(strcmp(varargin(1:2:end), 'weight_fun')))
                obj.is_sigma_inv_ = false;
            end
        end
    end
    
%=== PROTECTED ===%
    methods (Access = protected)
        function signature(obj)
            obj.type_ = {'scalar_valued'};
            obj.h_params_list_ = {'v_field', 'weights', 'weight_fun', 'sigma_f', 'sigma_n'};
        end
        
        function check(obj)
            check@abstract_kernel(obj);
            if ~obj.is_sigma_inv_
                obj.covariance;
            end
        end
        
        function covariance(obj)
            v_field = repmat(obj.h_params_.v_field,obj.n_,1);
            lambdas = obj.h_params_.weight_fun(v_field, obj.h_params_.weights(1), obj.h_params_.weights(2)); %  obj.h_params_.weight_fun
            D = sparse(1:obj.m_*obj.n_*obj.d_,1:obj.m_*obj.n_*obj.d_, ...
                1./reshape(lambdas',[],1), ...
                obj.m_*obj.n_*obj.d_, obj.m_*obj.n_*obj.d_);
            [U, x_i, y_i] = gs_orthogonalize(v_field);
            S = U'*D*U;
            obj.sigma_inv_ = c_reshape(full(S(sub2ind(size(S),x_i(:),y_i(:)))), [], obj.d_);
            obj.is_sigma_inv_ = true;
            obj.is_data_dep_ = true;
            obj.type_cov_ = 3;
        end
    end
    
    methods (Access = protected, Static = true)
        function V = weighted_norm(v, a, b)
            switch nargin
                case 1
                    a = 0.5;
                    b = 1;
                case 2
                    b = 1;
            end
            v_norm = vecnorm(v,2,2);
            V = [a*v_norm, b*repmat(v_norm, 1, size(v,2) -1)];
        end
    end
end

