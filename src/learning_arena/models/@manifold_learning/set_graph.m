function set_graph(obj, varargin)
    % Set graph. For each manifold learning algorithm it is
    % possible to set the graph. The weights of the edges will be
    % define by the similarity matrix. Whereas there is no edege the
    % weight is 0
    obj.with_graph_ = true;

    if length(varargin) == 1

        if issparse(varargin{1})
            obj.graph_ = varargin{1};
        else
            obj.graph_ = sparse(varargin{1});
        end

        obj.is_graph_ = true;
    else
        obj.graph_options_ = varargin;
        obj.is_graph_ = false;
    end

    obj.reset;
end
