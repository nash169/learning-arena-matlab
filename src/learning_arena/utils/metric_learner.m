classdef metric_learner < handle
    %METRIC_LEARNER Summary of this class goes here
    %   Detailed explanation goes here    
    methods
        % Construct - Possible to set parameters directly, not data
        function obj = metric_learner(varargin)
            %METRIC_LEARNER Construct an instance of this class
            %   Detailed explanation goes here
            if nargin > 0; obj.set_params(varargin{:}); end
            
            if  ~isfield(obj.params_, 'kernel')
               obj.params_.kernel = rbf;
               if  ~isfield(obj.params_, 'epsilon')
                   obj.params_.epsilon = 5.; % epsilon = 5
               end
               obj.params_.kernel.set_params('sigma', sqrt(5/2)); % sigma = sqrt(epsilon/2)
               obj.params_.epsilon = obj.params_.epsilon / 4; % c = 1/4
            end

            obj.laplace_ = diffusion_maps('alpha', 1, 'operator', 'inifinitesimal');
            obj.laplace_.graph_options('type', 'k-nearest', 'k', 10);
            obj.reset;
        end
        
        % Set parameters. It is possible to set just the parameters shown
        % in 'params_name_'
        function set_params(obj, varargin)
            for i = 1 : 2 : length(varargin)
                assert(logical(sum(strcmp(obj.params_name_, varargin{i}))), '"%s" parameter not present', varargin{i})
                obj.params_.(varargin{i}) = varargin{i+1};
            end
            
            obj.is_params_ = false;
            obj.reset;
        end
        
        % Get the parameters. Not very useful at the moment
        function params = params(obj, parameter)
            assert(logical(sum(strcmp(obj.params_name_, parameter))), ...
                '"%s" parameter not present', parameter)
            if nargin < 2 
                params = obj.params_;
            else
                params = obj.params_.(parameter);
            end
        end
        
        function [h, d] = metric(obj)
            obj.check;
            
            if ~obj.is_metric_
                d = length(obj.params_.space);
                f = obj.params_.manifold.embedding(obj.params_.space);
                f_i = repmat(f, 1, d);
                f_j = repelem(f, 1, d);
                L = obj.laplace_.infinitesimal;
                h_inv = (L*(f_i.*f_j) - f_i.*(L*f_j) - f_j.*(L*f_i))/2;
                h_inv = c_reshape(h_inv,[],d);
                obj.metric_ = h_inv;
                obj.metric_ = obj.metric_invert(h_inv);
                obj.is_metric_ = true;
            end
            
            if nargout > 0; h = obj.metric_; end
            if nargout > 1; d = obj.eigs_; end 
        end   
    end
    
    methods (Access = protected)
        function check(obj)            
            if ~obj.is_params_
                for i  = 1 : length(obj.params_name_)
                   assert(isfield(obj.params_,obj.params_name_{i}), ...
                       '"%s" parameter missing', obj.params_name_{i})
                end
                obj.is_params_ = true;
            end
            
            if ~obj.is_laplace_
                data = obj.params_.manifold.data;
                obj.laplace_.set_data(data);
                obj.laplace_.set_params('kernel', obj.params_.kernel, ...
                                        'epsilon', obj.params_.epsilon);
                obj.is_laplace_ = true;
            end
        end
        
        function reset(obj)
            obj.is_laplace_ = false;
            obj.is_metric_ = false;
        end
        
        function h = metric_invert(obj, metric_inv)
            d = size(metric_inv,2);
            [h_inv, x_i, y_i] = blk_matrix(metric_inv);
            h_inv = full(h_inv);
            [U,D] = eig(h_inv);
            obj.eigs_ = c_reshape(diag(D), [], d);
            h = U*(D\U');
            h = c_reshape(h(sub2ind(size(h),x_i(:),y_i(:))), [], d^2);
%             u = c_reshape(full(U(sub2ind(size(U),x_i(:),y_i(:)))), [], d^2);     
        end
    end
    
    properties
        params_name_ = {'manifold', 'space', 'dim', 'kernel', 'epsilon'}
    end
    
    properties (Access = protected)
        params_
        laplace_
        metric_
        eigs_
        
        is_params_
        is_laplace_
        is_metric_
    end
end

