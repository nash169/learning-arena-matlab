function G = graph(obj, data, varargin)
    % Get graph. It returns a logical matrix where entries equal to 1
    % indicates the presence of an edge between nodes.
    if nargin > 1; obj.set_data(data); end
    if nargin > 2; obj.graph_options_ = varargin; end

    if ~obj.is_graph_
        obj.graph_ = graph_build(obj.data_, obj.graph_options_{:});
        obj.is_graph_ = true;
        obj.with_graph_ = true;
    end

    obj.reset;
    if nargout > 0; G = obj.graph_; end
end
