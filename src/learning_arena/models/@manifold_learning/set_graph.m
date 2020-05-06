function set_graph(obj, G)
    % Set graph. For each manifold learning algorithm it is
    % possible to set the graph. The weights of the edges will be
    % define by the similarity matrix. Whereas there is no edege the
    % weight is 0
    obj.graph_ = G;
    obj.with_graph_ = true;
    obj.is_graph_ = true;
    obj.reset;
end
