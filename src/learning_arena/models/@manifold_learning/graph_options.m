function graph_options(obj, varargin)
% Set graph options.
obj.graph_options_ = varargin; % obj.graph_options_ = [obj.graph_options_, varargin];
obj.with_graph_ = true;
obj.is_graph_ = false;
obj.reset;
end

