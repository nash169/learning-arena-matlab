classdef process_demo < handle
    %PROCESS_DEMO Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    properties
        data_list_ = {'dimension', 'demo', 'structure'}
        options_list_ = {'calc_vel', 'calc_step', 'tol_cutting', 'center_data', 'smooth_window', 'reduce_factor', 'init_cut', 'end_cut'}
    end

    methods

        function obj = process_demo(varargin)
            %PROCESS_DEMO Construct an instance of this class
            %   Detailed explanation goes here

            if nargin > 0; obj.set_data(varargin{:}); end
        end

        function set_data(obj, varargin)

            for i = 1:2:length(varargin)

                switch varargin{i}
                    case 'demo'
                        obj.demo_ = varargin{i + 1};
                    case 'structure'
                        obj.demo_struct_ = varargin{i + 1};
                    case 'dimension'
                        obj.dimension_ = varargin{i + 1};
                    otherwise
                        error('Error')
                end

            end

        end

        function set_options(obj, varargin)

            for i = 1:2:length(varargin)

                if logical(sum(strcmp(obj.options_list_, varargin{i})))
                    obj.options_.(varargin{i}) = varargin{i + 1};
                else
                    error('"%s" parameter not present', varargin{i})
                end

            end

        end

        function [Data, x0, xT] = process_data(obj, varargin)
            if nargin > 1; obj.set_data(varargin{:}); end

            obj.init;

            num_trajs = length(obj.demo_);

            x0 = zeros(num_trajs, obj.dimension_);
            xT = zeros(num_trajs, obj.dimension_);
            Data = [];

            for i = 1:length(obj.demo_)

                data = obj.demo_{i};

                % Initial data cut
                if isfield(obj.options_, 'init_cut')

                    data = obj.init_cut(data);

                end

                % End data cut
                if isfield(obj.options_, 'end_cut')

                    data = obj.end_cut(data);

                end

                % Center positions
                if isfield(obj.options_, 'center_data')

                    if isfield(obj.indices_, 'position')
                        data = obj.center_data(data);
                    else
                        error("Position not available")
                    end

                end

                % Smoothen positions
                if isfield(obj.options_, 'smooth_window')

                    data = obj.smooth_data(data);

                    % Adjust velocities
                    if isfield(obj.indices_, 'velocity')
                        magnitude = vecnorm(data(obj.indices_.('velocity'), 1:end-1),2,1);
                        direction = data(obj.indices_.('position'), 2:end) - data(obj.indices_.('position'), 1:end - 1);
                        vel = direction./vecnorm(direction,2,1).*magnitude;
                        data(obj.indices_.('velocity'), :) = [vel, zeros(obj.dimension_, 1)];
                    end
                    
                    % Adjust time
                    if isfield(obj.indices_, 'time')
                        vel = vecnorm(data(obj.indices_.('velocity'), 1:end-1),2,1);
                        space = vecnorm(data(obj.indices_.('position'), 2:end) - data(obj.indices_.('position'), 1:end - 1),2,1);
                        steps = space./vel;
                        
                        time = 0;
                        data(obj.indices_.('time'),i) = 0;

                        for i = 1 : length(data(obj.indices_.('time'),:)) - 1
                            time = time + steps(i);
                            data(obj.indices_.('time'),i+1) = time;
                        end
                    end

                end

                % Reduce data
                if isfield(obj.options_, 'reduce_factor')

                    data = obj.reduce_data(data);

                end

                % Calculate velocities
                if isfield(obj.options_, 'calc_vel')

                    if isfield(obj.indices_, 'position') && isfield(obj.indices_, 'time')
                        data = obj.calc_velocity(data);
                    else
                        error("Position or time step not available")
                    end

                end

                % Trim velocities
                if isfield(obj.options_, 'tol_cutting')

                    if isfield(obj.indices_, 'velocity')
                        data = obj.trim_velocity(data);
                    else
                        error("Velocity not available")
                    end

                end

                % Set final velocity to zero
                if isfield(obj.indices_, 'velocity')
                    data(obj.indices_.('velocity'), end) = zeros(obj.dimension_, 1);
                end

                % Calculate steps
                if isfield(obj.options_, 'calc_step')

                    data = obj.calc_step(data);

                end

                x0(i, :) = data(obj.indices_.('position'), 1);
                xT(i, :) = data(obj.indices_.('position'), end);
                Data = [Data, data];
            end

        end

    end

    %=== PROTECTED ===%
    properties (Access = protected)
        options_

        dimension_

        demo_

        demo_struct_

        indices_
    end

    methods (Access = protected)

        function init(obj)

            if isempty(obj.dimension_)
                error("Dimension not available")
            end

            if isempty(obj.demo_)
                error("Demo not available")
            end

            if isempty(obj.demo_struct_)
                error("Demo structure not available")
            end

            obj.data_indices;

        end

        function data_indices(obj)
            obj.indices_ = struct;
            curr_index = 1;

            for i = 1:length(obj.demo_struct_)

                switch obj.demo_struct_{i}
                    case 'time'
                        obj.indices_.('time') = curr_index;
                        curr_index = curr_index + 1;
                    case 'position'
                        obj.indices_.('position') = curr_index:curr_index + obj.dimension_ - 1;
                        curr_index = curr_index + obj.dimension_;
                    case 'velocity'
                        obj.indices_.('velocity') = curr_index:curr_index + obj.dimension_ - 1;
                        curr_index = curr_index + obj.dimension_;
                    case 'labels'
                        obj.indices_.('label') = curr_index;
                        curr_index = curr_index + 1;
                    otherwise
                        error('Error')
                end

            end

        end

        function data = center_data(obj, data)

            data(obj.indices_.('position'), :) = data(obj.indices_.('position'), :) - data(obj.indices_.('position'), end);

        end

        function data = smooth_data(obj, data)

            for i = obj.indices_.('position')
                data(i, :) = smooth(data(i, :), obj.options_.('smooth_window'));
            end

        end

        function data = reduce_data(obj, data)

            data = data(:, 1:obj.options_.('reduce_factor'):end);

        end

        function data = trim_velocity(obj, data)

            trim_index = vecnorm(data(obj.indices_.('velocity'), :), 2, 1) <= obj.options_.('tol_cutting');
            data(:, trim_index) = [];

        end

        function data = calc_velocity(obj, data)

            vel = [(data(obj.indices_.('position'), 2:end) - data(obj.indices_.('position'), 1:end - 1)) ./ (data(obj.indices_.('time'), 2:end) - data(obj.indices_.('time'), 1:end - 1)), zeros(obj.dimension_, 1)];

            if isfield(obj.indices_, 'velocity')
                data(obj.indices_.('velocity'), :) = vel;
            else
                obj.indices_.('velocity') = size(data, 1) + 1:size(data, 1) + obj.dimension_;
                data = [data; vel];
            end

        end

        function data = calc_step(obj, data)

            if isfield(obj.indices_, 'time')
                data = [data; data(obj.indices_.('time'), 2:end) - data(obj.indices_.('time'), 1:end - 1), 0];
            elseif isfield(obj.indices_, 'position') && isfield(obj.indices_, 'velocity')
                dist = vecnorm(data(obj.indices_.('position'), 2:end) - data(obj.indices_.('position'), 1:end - 1), 2, 1);
                vel = vecnorm(data(obj.indices_.('velocity'), 1:end - 1), 2, 1);
                data = [data; dist ./ vel, 0];
            else
                error("Not possible to calculate time steps")
            end

        end

        function data = init_cut(obj, data)
            data = data(:, obj.options_.('init_cut'):end);
        end

        function data = end_cut(obj, data)
            data = data(:, 1:end - obj.options_.('end_cut'));
        end

    end

end
