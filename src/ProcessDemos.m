function [Data, x0, xT, targets, index] = ProcessDemos(demos, demo_struct, dim, options)
%
% This function preprocess raw data creating the dataset suitable for
% manifold learning. If requested, it computes the velocities given the
% positions and the time intervall. In addition it is possible to trim data
% having velocities module below a certain threshold. The function gives
% back the training dataset and the position of the targets.
%
% [Data, x0, xT, targets, index] = ProcessDemos(demos, demo_struct, dim,
% options)
%
% Inputs -----------------------------------------------------------------
%
%
%   o demos:   A variable containing all demonstrations (only
%              trajectories). The variable 'demos' should follow the
%              following format:
%              - demos{n}: d x T^n matrix representing the d dimensional
%                          trajectories. T^n is the number of datapoint in
%                          this demonstration (1 < n < N)
%
%   o dim: 
%       Dimensionality of the demonstrations.
%
%   o demo_struct: 
%       Array of strings containing the demo's structure legend.
%
%   o options:
%       - tol_cutting: A small positive scalar that is used to trim data.
%       It removes the redundant datapoint from the begining and the end of
%       each demonstration that their first time derivative is less than
%       'tol_cutting';
%       
%       - center_data: If set to 'true' the function will center the data
%       to the target;
%
%       - calc_vel: If set to 'true' and time is provided it calculates the
%       velocities given the positions;
%       
%       - smooth_window
%
%       - reduce_factor
%
%
% Outputs ----------------------------------------------------------------
%
%   o x0:      d x 1 array representing the mean of all demonstration's
%              initial points.
%
%   o xT:      d x 1 array representing the mean of all demonstration's
%              final point (target point).
%
%   o Data:    A 2d x N_Total matrix containing all demonstration data points.
%              Rows 1:d corresponds to trajectories and the rows d+1:2d
%              are their first time derivatives. Each column of Data stands
%              for a datapoint. All demonstrations are put next to each other 
%              along the second dimension. For example, if we have 3 demos
%              D1, D2, and D3, then the matrix Data is:
%                               Data = [[D1] [D2] [D3]]
%
%   o index:   A vector of N+1 components defining the initial index of each
%              demonstration. For example, index = [1 T1 T2 T3] indicates
%              that columns 1:T1-1 belongs to the first demonstration,
%              T1:T2-1 -> 2nd demonstration, and T2:T3-1 -> 3rd
%              demonstration.
%

%% Read Demo struct
time_index = 0;
pos_index = 0;
vel_index = 0;
label_index = 0;
curr_start = 1;

for i = 1:length(demo_struct)
    switch demo_struct{i}
        case 'time'
            time_index = curr_start;
            curr_start = curr_start + 1;
        case 'position'
            pos_index = curr_start:curr_start+dim-1;
            curr_start = curr_start + dim;
        case 'velocity'
            vel_index = curr_start:curr_start+dim-1;
            curr_start = curr_start + dim;
        case 'labels'
            label_index = curr_start;
        otherwise
            error('Error')
    end
end

if ~pos_index
    error('At least the position is necessary')
end

%% Check the options
if nargin > 3 && isfield(options,'calc_vel')
    calc_vel = options.calc_vel;
else
    calc_vel = false;
end

if nargin > 3 && isfield(options,'tol_cutting')
    if ~vel_index
        if ~time_index
            error('Velocity & Time are missing')
        else
            calc_vel = true;            
        end
    else
        calc_vel = false;
    end
    
    tol_cutting = options.tol_cutting;
    trim = true;
else
    trim = false;
end

if nargin > 3 && isfield(options,'center_data')
    center_data = options.center_data;
else
    center_data = false;
end

if nargin > 3 && isfield(options,'smooth_window')
    smooth_window = options.smooth_window;
    smooth_data = true;
else
    smooth_data = false;
end

if nargin > 3 && isfield(options,'reduce_factor')
    reduce_factor = options.reduce_factor;
    reduce_data = true;
else
    reduce_data = false;
end

%% Preprocess Data
Data=[];
x0 = [];
xT = [];
index = 1;
curr_label = 1;

for i=1:length(demos)
    clear tmp tmp_d
    demo_data=[];
    tmp = demos{i};
    
    if label_index
        curr_label = tmp(label_index,1);
    end
    
    % de-noising data (not necessary)
    if smooth_data
        for j=pos_index
            tmp(j,:) = smooth(tmp(j,:),smooth_window); 
        end
    end
    
    % Reduce data (remove this part)
    if reduce_data
        tmp = tmp(:,1:reduce_factor:end);
    end
    
    % computing the first time derivative
    if calc_vel
        pos_d = (tmp(pos_index,2:end) - tmp(pos_index,1:end-1))./(tmp(time_index,2:end) - tmp(time_index,1:end-1));
        if trim
            trim_index = vecnorm(pos_d,2,1) <= tol_cutting;
            tmp(:,trim_index) = [];
            pos_d(:,trim_index) = [];
        end
        pos_d = [pos_d zeros(dim,1)];
    elseif vel_index
        if trim
            trim_index = vecnorm(tmp(vel_index,:),2,1) <= tol_cutting;
            tmp(:,trim_index) = [];
        end
    end
    
    % Saving the initial point of each demo
    x0 = [x0 [demos{i}(pos_index,1); curr_label]];
    
    % Saving the final point (target) of each demo
    xT = [xT [demos{i}(pos_index,end); curr_label]];
    
    % Centering Data
    if center_data
        % shifting demos to the origin
        tmp(pos_index,:) = tmp(pos_index,:) - repmat(xT(1:dim,end),1,size(tmp,2));
    end
    
    % Store Positions
    demo_data = [demo_data; tmp(pos_index,:)];
    
    % Store Velocities
    if calc_vel
         demo_data = [demo_data; pos_d];
    elseif vel_index
         demo_data = [demo_data; tmp(vel_index,:)];
    end
    
    % Store Time
    if time_index
        demo_data = [demo_data; tmp(time_index,:)];
    end
    
    % Store Labels
    demo_data = [demo_data; curr_label*ones(1, size(demo_data,2))];
    
    % Saving Data
    Data = [Data demo_data];
    
    % Saving demos next to each other
    index = [index size(Data,2)+1];
end

targets = [];

for i = 1:max(xT(end,:))
    targets = [targets; sum(xT(1:end-1, xT(end,:)==i),2)'/sum(xT(end,:)==i)];
end