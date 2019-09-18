function W = GraphBuild(X, options)
%GRAPHBUILD Summary of this function goes here
%   Detailed explanation goes here

if isfield(options,'conntype')
    connType = options.conntype;
else
    error('Connection type not defined');
end

if isfield(options,'sim_fun')
    f = options.sim_fun;
else
    f = Kernels('euclid_dist');
end

if isfield(options,'plot_graph')
    plot_graph = options.plot_graph;
else
    plot_graph = false;
end

[m,n] = size(X);
gram_options = struct('norm', false,...
                      'vv_rkhs', false);

if n==4
    x_pos = X(:,1:2);
    x_vel = X(:,3:4);
elseif n==6
    x_pos = X(:,1:3);
    x_vel = X(:,4:6);
else
    x_pos = X;
end

switch connType
    case 'eps-neighbor'
        if isfield(options,'epsilon')
            D = GramMatrix(f, gram_options, x_pos, x_pos);
            W = D < options.epsilon;
        else
            error('Epsilon not deifned');
        end
    case 'n-neighbors'
        if isfield(options,'num_nb')
            D = GramMatrix(f, gram_options, x_pos, x_pos);
            W = zeros(m);
            for i = 1:m
               [~,index] = sort(D(i,:),'ascend');
               W(i,index(1:options.num_nb)) = true;
            end
        else
            error('Neighboors number not defined.');
        end
    otherwise
        error('Error');
end

if plot_graph
    GraphDraw(x_pos, W);
end

end

