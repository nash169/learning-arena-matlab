function fig = plot_data(obj, data, fig)
if nargin > 1 
    obj.set_data(data); 
else
    assert(obj.is_data_, 'Data not present')
end

obj.check;

colors_data = hsv(length(unique(obj.labels_)));
colors_data = colors_data(obj.labels_,:);

colors_centroids = hsv(length(unique(1:obj.params_.cluster)));
colors_centroids = colors_centroids(1:obj.params_.cluster,:);

if nargin < 4; fig = figure; else; figure(fig); hold on; end

if obj.d_ == 2
    scatter(obj.data_(:,1), obj.data_(:,2), 40, colors_data, 'filled','MarkerEdgeColor',[0 0 0])
    hold on
    scatter(obj.centroids_(:,1), obj.centroids_(:,2), 150, colors_centroids, 'filled','MarkerEdgeColor',[0 0 0], 'LineWidth',2)
else
    scatter3(obj.data_(:,1), obj.data_(:,2), obj.data_(:,3), 40, colors_data, 'filled','MarkerEdgeColor',[0 0 0])
    hold on
    scatter3(obj.centroids_(:,1), obj.centroids_(:,2), obj.centroids_(:,3), 100, colors_centroids, 'filled','MarkerEdgeColor',[0 0 0], 'LineWidth',2)
end

if ~obj.params_.soft
    title("K-Means")
else
    title("Soft K-Means")
end
axis square; grid on
end

