function S = similarity(obj, data)
% Get the similarity matrix. The graph is automatically applied to
% the similarity if present
if nargin > 1; obj.set_data(data); end
obj.check;

if ~obj.is_similarity_
    obj.similarity_ = obj.params_.kernel.gramian(obj.data_,obj.data_);
    if obj.with_graph_
        obj.similarity_ = obj.similarity_.*obj.graph;
    end
    obj.is_similarity_ = true;
end

if nargout > 0; S = obj.similarity_; end
end

