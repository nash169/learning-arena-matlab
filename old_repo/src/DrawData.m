function [varargout] = DrawData(data, targets, options)

if nargin == 3 && isfield(options,'plot_pos') 
    plot_pos = options.plot_pos;
else
    plot_pos = true;
end

if nargin == 3 && isfield(options,'plot_vel') 
    plot_vel = options.plot_vel;
else
    plot_vel = false;
end

%% Plot Recorded data
plot_options.is_eig     = false;
plot_options.labels     = data(end,:);

[m,n] = size(targets);

if plot_pos
    plot_options.title      = 'Position';
    varargout{1} = PlotData(data(1:n,:)',plot_options);
    axis square;
    hold on
    if n == 2
        for i = 1:m
            plot(targets(i,1), targets(i,2),'xk','markersize',30);
        end
%         quiver(data(1,:)',data(2,:)',data(3,:)',data(4,:)');
    else
        for i = 1:m
            plot3(targets(i,1), targets(i,2), targets(i,3), 'xk','markersize',30);
        end
    end
end

if plot_vel
    plot_options.title      = 'Velocity';
    varargout{2} = PlotData(data(n+1:2*n,:)', plot_options);
    axis equal;
end

end

