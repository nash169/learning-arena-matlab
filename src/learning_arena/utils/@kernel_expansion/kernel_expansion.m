classdef kernel_expansion < handle
    %KERNEL_EXPANSION Summary of this class goes here
    %   Limited to two inputs kernels right now

    %=== PUBLIC ===%
    properties
        % List of hyper-parameters.
        h_params_list_

        % List of parameters.
        params_list_
    end

    methods
        % Constructor. In the constructor you can pass the parameters
        % defining the kernel. You can pass all of them or a part and set
        % the rest using the apposite function "set_params".
        function obj = kernel_expansion(varargin)
            %KERNEL_EXPANSION Construct an instance of this class
            %   Detailed explanation goes here

            % Define the parameters of the model.
            obj.signature;

            % Set the parameters if present.
            if nargin > 0; obj.set_params(varargin{:}); end

            % Set default parameters
            if~isfield(obj.params_, 'order'); obj.params_.order = 'ref-test'; end

            % Init bool variables.
            obj.is_params_ = false;
            obj.is_data_ = false;
            obj.is_grid_ = false;
            obj.is_input_ = false;
            obj.is_fig_options_ = false;
            obj.reset;
        end

        set_params(obj, varargin)

        set_data(obj, varargin)

        [params, params_aux] = params(obj, parameter)

        data = data(obj)

        psi = expansion(obj, varargin)

        dpsi = gradient(obj, varargin)

        d2psi = hessian(obj, varargin)

        [dp, n] = pgradient(obj, param, data)

        fig = plot(obj, options, fig, varargin)

        fig = contour(obj, options, fig)
    end

    %=== PROTECTED ===%
    properties (Access = protected)
        % Hyper-parameters. Inside this struct there are all the parameters
        % with respect to it is possible to derive the model.
        h_params_

        % Parameters. Inside the struct there are all the parmeters, that
        % can be optional or not, to characterize the model. It is not
        % possible to derive the model with respect to these parameters.
        params_

        % Test point for evaluating the model. The gradient and the hessian
        % of the model are taken with respect to this variable.
        data_

        % Variable the store the test points in a grid for plotting
        % purpose.
        grid_

        % Number of reference points.
        m_

        % Number of test points.
        n_

        % Dimension of the space.
        d_

        % Kernel expansion evaluated at the test points.
        psi_

        % Gradient of the kernel expansion evaluated at the test points.
        dpsi_

        % Hessian of the kernel expansion evaluated at the test points.
        d2psi_

        % Gradient of the kernel expansion with respect to the
        % hyper-parameters
        dp_

        % Figure's options
        fig_options_

        % Bool variable to assess if all the parameters have been set.
        % correctly.
        is_params_

        % Bool variable to assess if the test points have been set.
        is_data_

        % Bool variable to assess if a grid for plotting is present or not.
        is_grid_

        % Bool variable to assess if tigure's option are set or not.
        is_fig_options_

        % Bool variable to assess if the evaluation of the expansion is
        % already available or not.
        is_psi_

        % Bool variable to assess if the evaluation of the expansion's
        % gradient is already available or not.
        is_dpsi_

        % Bool variable to assess if the evaluation of the expansion's
        % hessian is already available or not.
        is_d2psi_

        input_
        is_input_
        dev_
        is_kernel_input_
    end

    methods (Access = protected)
        signature(obj)

        check(obj)

        input(obj)

        reset(obj)

        k_sum = sum_kernels(obj, v)

        calc_pgradient(param)

        fig_options(obj, options)
    end

end
