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

G = digraph(obj.graph);
nodes = {'XData', data(:,1), 'YData', data(:,2)};
if size(data,2) > 2; nodes = [nodes, 'ZData', data(:,3)]; end

fig = figure;
plot(G, nodes{:});
title(['Graph in ', space_type, ' space']);
end
