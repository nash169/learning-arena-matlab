classdef velocity_directed < abstract_kernel
    %VELOCITY_DIRECTED Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    methods

        function obj = velocity_directed(varargin)
            %VELOCITY_DIRECTED Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@abstract_kernel(varargin{:});

            if ~isfield(obj.params_, 'isnan')
                obj.params_.isnan = 1;
                obj.cosine_.set_params('isnan', obj.params_.isnan);
            end

        end

        function set_params(obj, varargin)
            set_params@abstract_kernel(obj, varargin{:});

            if logical(sum(strcmp(varargin, 'v_field')))
                obj.cosine_.set_data(obj.h_params_.v_field{:});
            end

            if logical(sum(strcmp(varargin, 'sigma')))
                obj.rbf_.set_params('sigma', obj.h_params_.sigma);
            end

            if logical(sum(strcmp(varargin, 'angle')))
                obj.alpha_ = 2 / (1 - cos(obj.h_params_.angle));
            end

            if logical(sum(strcmp(varargin, 'isnan')))
                obj.cosine_.set_params('isnan', obj.params_.isnan);
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

        rbf_;
        cosine_;
    end

    methods (Access = protected)

        function signature(obj)
            obj.type_ = {'scalar_valued'};
            obj.h_params_list_ = ['sigma', 'v_field', 'angle', obj.h_params_list_];
            obj.params_list_ = ['isnan', obj.params_list_];

            obj.rbf_ = rbf;
            obj.cosine_ = cosine;
        end

        function d = num_params(obj, name)
        end

        function counter = set_pvec(obj, name, vec, counter)
        end

        function [vec, counter] = pvec(obj, name, vec, counter)
        end

        function k = calc_kernel(obj)
            % q = obj.alpha_ * (1 - obj.cosine_.kernel) * 1.5 * obj.h_params_.sigma;
            q = 3 * obj.h_params_.sigma * (1 - obj.cosine_.kernel) / (1 - cos(obj.h_params_.angle));
            k = obj.rbf_.kernel .* exp(-q.^2/2 / obj.h_params_.sigma);
        end

        function dk = calc_gradient(obj)
        end

        function d2k = calc_hessian(obj)
        end

        function dp = calc_pgradient(obj, name)
        end

    end

end
