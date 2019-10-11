classdef kernel_eca < manifold_learning
    %KERNEL_ECA Summary of this class goes here
    %   Detailed explanation goes here
    
%=== PUBLIC ===%
    methods
        function obj = kernel_eca(varargin)
            %KERNEL_ECA Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@manifold_learning(varargin{:});
            if  ~isfield(obj.params_, 'kernel')
                obj.params_.kernel = rbf; 
                obj.params_.kernel.set_params('sigma', 5.);
            end
            obj.with_graph_ = false;
        end
        
        function S = entropy(obj)
            if ~obj.is_eigen_
                obj.eigensolve;
            end
            
            S = obj.entropy_;
        end
        
        function fig = plot_entropy(obj, num_eig)
            % Plot entropy contribution
            if nargin < 2; num_eig = 1:10; end
            S = obj.entropy;
            fig = figure;
            plot(num_eig, S(num_eig), '-o')
            grid on
            title(['Entropy contribution ', num2str(num_eig(1)), ' to ', num2str(num_eig(end))])
        end
    end
    
%=== PROTECTED ===%
    properties (Access = protected)
        entropy_
    end
    
    methods (Access = protected)
        function signature(obj)
            obj.params_name_ = {'kernel'};
            obj.type_ = {'graph-less'};
        end
        
        function [V,D,W] = solve(obj)
            S = full(obj.similarity/obj.m_); % Think about eigs for asym sparse matrix
            [V,D,W] = eig(S);
            [obj.entropy_, b] = sort(sum(V*sqrt(D)).^2, 'descend');
            D = D(b,b);
            V = V(:,b);
            W = W(:,b);
        end
    end
end