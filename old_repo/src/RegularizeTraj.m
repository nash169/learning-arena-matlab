function [demo] = RegularizeTraj(demo)
%REGULARIZETRAJ Summary of this function goes here
%   Detailed explanation goes here
label = 0;
for i = 1:length(demo)
    if demo{i}(4,1) ~= label
       label = demo{i}(4,1);
       ref = demo{i}(3,:);
    elseif length(demo{i}(3,:)) < length(ref)
       ref = demo{i}(3,:);
    end
    
    ppx = spline(demo{i}(3,:),demo{i}(1:2,:));
    demo{i} = [ppval(ppx,ref); ref; label*ones(1,length(ref))];
end

end
