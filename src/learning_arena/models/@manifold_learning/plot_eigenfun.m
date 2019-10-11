function varargout = plot_eigenfun(obj, space, varargin)
% Plot eigenfunctions
if nargin < 2; space = 1; end

options = struct;
if nargin > 2
    for i = 1 : 2 : length(varargin)
        options.(varargin{i}) = varargin{i+1};
    end
end

if ~obj.is_eigen_; obj.eigensolve; end
varargout = cell(length(space),1);

for i = 1 : length(space)
    obj.expansion_.set_params('weights', obj.right_vec_(:,space(i)));
    varargout{i} = figure;
    subplot(1,2,1)
    obj.expansion_.plot(options, varargout{i});
    title(['Eigenfunction ', num2str(space(i)), ' surface'])
    axis square
    subplot(1,2,2)
    obj.expansion_.contour(options, varargout{i});
    title(['Eigenfunction ', num2str(space(i)), ' contour'])
    axis square
end
end
