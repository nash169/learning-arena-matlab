function V = DistanceVector(X,Y)
[m, dim] = size(X);
[n, ~] = size(Y);

X = reshape(permute(reshape(repmat(X, 1, n),...
    m,dim,[]),...
    [1,3,2]),...
    [],dim);

Y = reshape(permute(reshape(repmat(reshape(Y', 1, n*dim),... % reshape
    m,1),...                                                 % repmat
    m,dim,[]),...                                            % reshape
    [1,3,2]),...                                             % permute
    [],dim);                                                 % reshape
% Just discovered 'repelem'... just do Y = repelem(Y,m,1)

V = X-Y; % V = Y-X;
end