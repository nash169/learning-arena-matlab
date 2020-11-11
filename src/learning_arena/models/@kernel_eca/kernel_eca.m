classdef kernel_eca < manifold_learning
    %KERNEL_ECA Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    methods

        function obj = kernel_eca(varargin)
            %KERNEL_ECA Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@manifold_learning(varargin{:});

            if ~isfield(obj.params_, 'kernel')
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
            grid on; hold on;
            title(['Entropy contribution ', num2str(num_eig(1)), ' to ', num2str(num_eig(end))])
            labels = cellstr(num2str(obj.order_));
            dx = 0.1; dy = 0;
            text(num_eig + dx, S(num_eig) + dy, labels(num_eig))
        end

    end

    %=== PROTECTED ===%
    properties (Access = protected)
        entropy_
        order_
    end

    methods (Access = protected)

        function signature(obj)
            obj.params_name_ = ['kernel', obj.params_name_];
            obj.type_ = {'graph-less'};
        end

        function [V, D, W] = solve(obj)

            switch obj.params_.solver
                case 'sparse'
                    [V, D] = eigs(obj.similarity, obj.params_.num_eigs, 'largestabs', 'Tolerance', 1e-14, 'MaxIterations', 1000); % obj.similarity/obj.m_
                    [obj.entropy_, obj.order_] = sort(diag(D) .* sum(V)'.^2, 'descend');
                    V = V(:, obj.order_);
                    W = V;
                case 'full'
                    [V, D, W] = eig(full(obj.similarity));
                    [obj.entropy_, obj.order_] = sort(sum(V * sqrt(D)).^2, 'descend');
                    D = D(obj.order_, obj.order_);
                    V = V(:, obj.order_);
                    W = W(:, obj.order_);
                otherwise
                    disp('Solver not found')

            end

        end

    end

end
