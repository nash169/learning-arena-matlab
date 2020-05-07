classdef lyapunov_directed < abstract_kernel
    %LYAPUNOV_DIRECTED Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    methods

        function obj = lyapunov_directed(varargin)
            %LYAPUNOV_DIRECTED Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@abstract_kernel(varargin{:});

            if ~isfield(obj.params_, 'isnan'); obj.params_.isnan = 1; end
            obj.is_field_ = false;
        end

        function set_params(obj, varargin)
            set_params@abstract_kernel(obj, varargin{:});

            if logical(sum(strcmp(varargin, 'sigma')))
                obj.rbf_.set_params('sigma', obj.h_params_.sigma);
            end

            if logical(sum(strcmp(varargin, 'angle')))
                obj.alpha_ = 2 / (1 - cos(obj.h_params_.angle));
            end

        end

        function set_data(obj, varargin)
            set_data@abstract_kernel(obj, varargin{:});
            obj.rbf_.set_data(obj.data_{:});
        end

    end

    %=== PROTECTED ===%
    properties (Access = protected)
        alpha_;

        v_field_;
        is_field_;

        rbf_;
    end

    methods (Access = protected)

        function signature(obj)
            obj.type_ = {'scalar_valued'};
            obj.h_params_list_ = ['sigma', 'v_field', 'angle', obj.h_params_list_];
            obj.params_list_ = ['isnan', obj.params_list_];

            obj.rbf_ = rbf;
        end

        function check(obj)
            check@abstract_kernel(obj);

            % if ~obj.is_field_
            %     obj.v_field_ = repmat(obj.h_params_.v_field, obj.n_, 1);
            %     obj.is_field_ = true;
            % end

        end

        function d = num_params(obj, name)
        end

        function counter = set_pvec(obj, name, vec, counter)
        end

        function [vec, counter] = pvec(obj, name, vec, counter)
        end

        function k = calc_kernel(obj)
            x_i = obj.Data_{1};
            x_j = obj.Data_{2};
            v_i = repmat(obj.h_params_.v_field{1}, obj.n_, 1);
            v_j = repelem(obj.h_params_.v_field{2}, obj.m_, 1);

            cross_i = abs(sum((x_j - x_i) .* v_i, 2) ./ vecnorm(x_j - x_i, 2, 2) ./ vecnorm(v_i, 2, 2));
            cross_j = abs(sum((x_i - x_j) .* v_j, 2) ./ vecnorm(x_i - x_j, 2, 2) ./ vecnorm(v_j, 2, 2));

            cross_i(isnan(cross_i)) = obj.params_.isnan;
            cross_j(isnan(cross_j)) = obj.params_.isnan;

            k = obj.rbf_.kernel .* exp((-obj.map(cross_i).^2 -obj.map(cross_j).^2) / 2 / obj.h_params_.sigma^2);

            % cross_cos = -sum(obj.diff_ .* obj.v_field_, 2) ./ vecnorm(obj.diff_, 2, 2) ./ vecnorm(obj.v_field_, 2, 2);
            % cross_cos(isnan(cross_cos)) = obj.params_.isnan;
            % q = obj.alpha_ * (1 - cross_cos) * 1.5 * obj.h_params_.sigma;
            % k = obj.rbf_.kernel .* exp(-q);
        end

        function dk = calc_gradient(obj)
        end

        function d2k = calc_hessian(obj)
        end

        function dp = calc_pgradient(obj, name)
        end

        function y = map(obj, x)
            y = 3 * obj.h_params_.sigma * (1 - x) / (1 - cos(obj.h_params_.angle));
        end

    end

end
