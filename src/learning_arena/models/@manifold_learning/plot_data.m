function fig = plot_data(obj, data, colors, fig)
if nargin > 1 
    obj.set_data(data); 
else
    assert(obj.is_data_, 'Data not present')
end

if nargin > 2
    obj.colors_ = colors;
elseif ~obj.is_colors_
    obj.set_colors(linspace(1,10,obj.m_));
end

if nargin < 4; fig = figure; else; figure(fig); hold on; end

if obj.d_ == 2
    scatter(obj.data_(:,1), obj.data_(:,2), 40, obj.colors_, 'filled','MarkerEdgeColor',[0 0 0])
else
    scatter3(obj.data_(:,1), obj.data_(:,2), obj.data_(:,3), 40, obj.colors_, 'filled','MarkerEdgeColor',[0 0 0])
end
axis equal; grid on
end

