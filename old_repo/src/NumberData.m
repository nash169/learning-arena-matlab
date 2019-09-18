function NumberData(X, delta, fig)
%NUMBERDATA Summary of this function goes here
%   Detailed explanation goes here
figure (fig)
a = [1:size(X,1)]'; b = num2str(a); c = cellstr(b);

switch size(X,2)
    case 1
        dx = delta; dy = delta;
        text(X(:,1)+dx, c);
    case 2
        dx = delta; dy = delta;
        text(X(:,1)+dx, X(:,2)+dy, c);
    case 3
        dx = delta; dy = delta; dz = delta;
        text(X(:,1)+dx, X(:,2)+dy, X(:,3)+dz, c);
    otherwise
        error('Fottiti');     
end

end

