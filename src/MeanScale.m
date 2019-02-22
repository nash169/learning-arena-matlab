function X_mod = MeanScale(X, operation)
%MEANSCALE Summary of this function goes here
%   Detailed explanation goes here
switch operation
    case 'center'
        X_mod = X - repmat(mean(X), size(X,1),1);
    case 'scale'
        X_mod = X./repmat(std(X), size(X,1),1);
    otherwise
        error('Error');
end
end