function fig = plot_graph(obj, space_type, space)
% Plot graph
assert(obj.is_data_, 'Data not present')

if nargin < 2; space_type = 'original'; end
if nargin < 3; space = 1:obj.d_; end

switch space_type
    case 'original'
        data = obj.data_;
    case 'embedding'
        data = obj.embedding(space);
    otherwise
        error('Space not found')
end

fig = figure;

% G = digraph(obj.graph, 'omitselfloops');
% nodes = {'XData', data(:,1), 'YData', data(:,2)};
% if size(data,2) > 2; nodes = [nodes, 'ZData', data(:,3)]; end
% plot(G, nodes{:}, 'ShowArrows', 'off', 'ArrowPosition', 0.1);

G = logical(obj.graph);
diff = -(repmat(data,obj.m_,1) - repelem(data,obj.m_,1));
nodes = repmat(data,obj.m_,1);

if obj.d_ == 2
    quiver(nodes(G(:),1),nodes(G(:),2), diff(G(:),1), diff(G(:),2), 0)
else
    quiver3(nodes(G(:),1),nodes(G(:),2), nodes(G(:),3), diff(G(:),1), diff(G(:),2), diff(G(:),3), 0)
end

title(['Graph in ', space_type, ' space']);
end
