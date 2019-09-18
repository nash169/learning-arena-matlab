classdef laplacian_eigenmaps < manifold_learning
    %LAPLACIAN_EIGENMAPS Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function obj = laplacian_eigenmaps(varargin)
            %LAPLACIAN_EIGENMAPS Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@manifold_learning(varargin{:});
            if  ~isfield(obj.params_, 'kernel')
                obj.params_.kernel = rbf; 
                obj.params_.kernel.set_params('sigma', 5.);
            end
            obj.with_graph_ = true;
            obj.graph_options = {'eps-neighborhoods', 'r', 2*5.};
        end
        
        function D = deegre(obj)        
            if ~obj.is_degree_
                obj.degree_ = deegre@manifold_learning(obj);
                obj.is_degree_ = true;
            end
            
            if nargout > 0; D = obj.degree_; end
        end
        
        function L = laplacian(obj)
            if ~obj.is_laplacian_
                obj.laplacian_ = obj.degree - obj.similarity;
                obj.is_laplacian_ = true;
            end
            
            if nargout > 0; L = obj.laplacian_; end
        end
    end
    
    methods (Access = protected)
        function signature(obj)
            obj.params_name_ = {'kernel'};
            obj.type_ = {'graph-based'};
        end
        
        function reset(obj)
            reset@manifold_learning(obj);
            obj.is_degree_ = false;
            obj.is_laplacian_ = false;
        end
        
        function [V,D,W] = solve(obj)
            L = obj.laplacian;
            D = obj.degree;
            
            [V,D,W] = eig(L,D);
            
            [a, b] = sort(diag(D),'ascend');
            D = diag(a);
            V = V(:,b);
            W = W(:,b);
        end
    end
    
    properties (Access = protected)
        degree_
        is_degree_
        
        laplacian_
        is_laplacian_
    end
end

