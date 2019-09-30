function varargout = plot_eigenvec(obj, space, type)
% Plot eigenvectors
if nargin < 2; space = 1; end
if nargin < 3; type = 'right'; end

if ~obj.is_eigen_; obj.eigensolve; end
varargout = cell(length(space),1);

for i = 1 : length(space)
    varargout{i} = figure;
    switch type
        case 'right'
            plot(1:length(obj.right_vec_(:,space(i))), obj.right_vec_(:,space(i)), '-o')
        case 'left'
            plot(1:length(obj.right_vec_(:,space(i))), obj.left_vec_(:,space(i)), '-o')
        otherwise
            error('Case not found')
    end
    title(['Eigenvector ', num2str(space(i)), ' - ', type])
end
end

