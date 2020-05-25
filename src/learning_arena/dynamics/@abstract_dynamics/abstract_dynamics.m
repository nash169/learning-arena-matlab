classdef abstract_dynamics < handle
    %ABSTRACT_DYNAMICS Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    properties
        params_list_ = {'space'}
    end

    methods

        function obj = abstract_dynamics(varargin)
            %ABSTRACT_DYNAMICS Construct an instance of this class
            %   Detailed explanation goes here

            % Define object structure
            obj.signature;

            % Set parameters
            if nargin > 0; obj.set_params(varargin{:}); end

            % Defaults
            if ~isfield(obj.params_, 'space'); obj.params_.space = 'euclidean'; end

            % Reset bools
            obj.is_data_ = false;
            obj.is_params_ = false;
            obj.is_grid_ = false;
            obj.reset
        end

        set_params(obj, varargin)

        set_data(obj, varargin)

        params = params(obj, parameter)

        data = data(obj)

        grid = grid(obj)

        X = field(obj, data)

        J = jacobian(obj, data)

        S = sample(obj, num_traj, sampling_center, time_window)

        h = plot_field(obj, options, fig, vararing)
    end

    %=== PROTECTED ===%
    properties (Access = protected)
        d_

        data_

        grid_

        params_

        X_

        J_

        samples_

        fig_options_

        is_data_

        is_params_

        is_grid_

        is_field_

        is_jacobian_

        is_sampled_
    end

    methods (Access = protected)
        check(obj);

        reset(obj);
    end

    %=== ABSTRACT ===%
    methods (Abstract = true, Access = protected)
        signature(obj)

        calc_field(obj)
    end

end
