function [intersect] = Intersect2Lines(points1, points2)
%INTERSECT2LINES Summary of this function goes here
%   Detailed explanation goes here

A = [points1(1,:)'-points1(2,:)', points2(2,:)'-points2(1,:)'];
b = points2(1,:)' - points1(1,:)';

x = A\b;

intersect = A(:,1)*x(1) + points1(1,:)';

end

