function fig = GraphDraw(X, W, fig)
%GRAPHDRAW Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
    fig = figure;
else
    figure(fig);
end

hold on;

[p1, p2] = find(W~=0);

for i = 1:length(p1)
   plot([X(p1(i),1), X(p2(i),1)], [X(p1(i),2), X(p2(i),2)], 'k'); 
end

end

