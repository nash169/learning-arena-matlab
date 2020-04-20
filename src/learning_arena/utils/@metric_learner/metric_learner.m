classdef metric_learner < handle
    %METRIC_LEARNER Summary of this class goes here
    %   Detailed explanation goes here
    methods
        % Construct - Possible to set parameters directly, not data
        function obj = metric_learner(varargin)
            %METRIC_LEARNER Construct an instance of this class
            %   Detailed explanation goes here
            if nargin > 0; obj.set_params(varargin{:}); end

            if ~isfield(obj.params_, "kernel")
                obj.params_.kernel = rbf;

                if ~isfield(obj.params_, "epsilon")
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
        set_params(obj, varargin)

        % Get the parameters. Not very useful at the moment
        params = params(obj, parameter)

        [h, h_inv] = metric(obj)

        f = embedding(obj)
    end

    methods (Access = protected)
        check(obj)

        reset(obj)

        metric_invert(obj, metric_inv)
    end

    properties
        params_name_ = {'manifold', 'space', 'dim', 'kernel', 'epsilon'}
    end

    properties (Access = protected)
        params_
        laplace_
        metric_
        metric_inv_
        eigs_
        embedding_

        is_params_
        is_laplace_
        is_metric_
        is_embedding_
    end

end
