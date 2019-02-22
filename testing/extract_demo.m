function [X, targets] = extract_demo(demos)

d = length(demos);
X = [];
targets = 0;

for i=1:d
   X = [X [demos{i}.pos; demos{i}.vel; ones(1, length(demos{i}.pos))]];
   targets = targets + demos{i}.pos(:,end);
end

targets = targets'/d;

end