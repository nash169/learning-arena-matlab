classdef kernel_pca < manifold_learning
    %KERNEL_PCA Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function obj = kernel_pca(varargin)
            %KERNEL_PCA Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@manifold_learning(varargin{:});
            if  ~isfield(obj.params_, 'kernel')
                obj.params_.kernel = rbf; 
                obj.params_.kernel.set_params('sigma', 5.);
            end
            obj.with_graph_ = false;
        end
    end
    
    methods (Access = protected)
        function signature(obj)
            obj.params_name_ = {'kernel'};
            obj.type_ = {'graph-less'};
        end
        
        function [V,D,W] = solve(obj)
            S = obj.normalize/obj.m_;
            S = obj.similarity/obj.m_;
            [V,D,W] = eig(S);
            [a, b] = sort(diag(D),'descend');
            D = diag(a);
            V = V(:,b);
            W = W(:,b);
        end
        
        function K = normalize(obj)
            K = obj.similarity;
            
            column_sums = sum(K,1) / obj.m_;
            total_sum = sum(column_sums, 2) / obj.m_;
            C = repmat(column_sums, obj.m_, 1, 1);
            K = K - C - permute(C, [2,1,3]);
            K = K + total_sum;
            
            obj.similarity_ = K;
        end
    end
end

