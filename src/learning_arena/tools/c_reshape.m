function v = c_reshape(x, varargin)
%C_RESHAPE Summary of this function goes here
%   It should work also for tensors but I'm not sure...

% y = permute(x, [2, 1, 3:ndims(x)]);
% v = reshape(y, varargin{end:-1:1})';

% y = permute(x, [2, 1, 3:ndims(x)]);
% z = reshape(y, varargin{end:-1:1});
% v = permute(z, [2, 1, 3:ndims(z)]);

% y = reshape(x, varargin{end:-1:1});
% v = permute(y, ndims(y):-1:1);

% y = permute(x, ndims(x):-1:1);
% v = reshape(y, varargin{end:-1:1});

y = permute(x, [2 1 3:ndims(x)]); % x.';
z = reshape(y, varargin{end:-1:1});
v = permute(z, ndims(z):-1:1);
end