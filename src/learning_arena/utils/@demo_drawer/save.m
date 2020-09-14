function save(obj, file)
%SAVE Summary of this function goes here
%   Detailed explanation goes here
demo = obj.demo_;
demo_struct = obj.demo_struct_;

save(file, 'demo', 'demo_struct');
end

